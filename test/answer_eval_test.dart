// Evaluasi jawaban LLM dengan model sungguhan (gaya "natural"); hasil ditulis untuk dinilai scripts/eval_suite.py.
//   MEIRA_LIVE=1 MEIRA_HOME=~/MEIRA flutter test test/answer_eval_test.dart
// Membandingkan kandidat otak: MEIRA_BRAIN=<berkas gguf> MEIRA_OUT=<folder hasil>.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/core/generated.dart';
import 'package:meira/core/grounding.dart';
import 'package:meira/core/history.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/core/vocab.dart';
import 'package:meira/llm/guardrails.dart';
import 'package:meira/llm/knowledge.dart';
import 'package:meira/runtime/llama.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final live = Platform.environment['MEIRA_LIVE'] == '1';
  final home = Platform.environment['MEIRA_HOME'] ?? '${Platform.environment['HOME']}/MEIRA';
  final brainPath = Platform.environment['MEIRA_BRAIN'] ?? '$home/models/app/qwen3.5-0.8b-instruct-Q4_K_M.gguf';
  final outDir = Platform.environment['MEIRA_OUT'] ?? '$home/runs/eval';

  test('jawaban LLM untuk skenario uji', () async {
    final server = LlamaServer(
      name: 'otak',
      model: brainPath,
      port: 8398,
      binary: Directory('$home/external/llama.cpp').listSync(recursive: true).whereType<File>().firstWhere((f) => f.path.endsWith('/llama-server')).path,
      gpuLayers: int.parse(Platform.environment['MEIRA_GPU_LAYERS'] ?? '0'),
    );
    await server.start();
    sqfliteFfiInit();
    final history = await History.open(at: await Directory.systemTemp.createTemp('meira_ans'), factory: databaseFactoryFfi);
    final recipes = parseRecipes(File('assets/resep.md').readAsStringSync());
    final kb = KnowledgeBase.parse(File('assets/pengetahuan.md').readAsStringSync());
    final natural = Meira(recipes: recipes, history: history, eyes: null, brain: server.client, brainHasVision: false, answerStyle: 'natural', knowledge: kb);
    // pembanding antarmodel: model diminta merangkai ulang catatan, jawaban mentahnya dinilai
    final drafter = Meira(recipes: recipes, history: history, eyes: null, brain: server.client, brainHasVision: false, knowledge: kb, rewriteNotes: true);
    final book = Meira(recipes: recipes, history: history, eyes: null, brain: null, knowledge: kb);
    final sink = (File('$outDir/answers.jsonl')..createSync(recursive: true)).openWrite();
    final kbSink = File('$outDir/kb_answers.jsonl').openWrite();
    try {
      for (final line in File('$home/data/eval/answer_scenarios.jsonl').readAsLinesSync().where((l) => l.trim().isNotEmpty)) {
        final sc = jsonDecode(line) as Map<String, dynamic>;
        Session make() {
          final s = Session(sc['id'])
            ..mode = sc['mode']
            ..imageDataUrl = 'data:image/png;base64,';
          s.detections = number([
            for (final (i, k) in (sc['have'] as List).cast<String>().indexed)
              Detection(key: k, label: displayName(k), rawLabel: displayName(k), box: [i * .15, .2, i * .15 + .12, .5]),
          ]);
          return s;
        }

        final sNat = make(), sRef = make();
        String answer = '', reference = '';
        final watch = Stopwatch()..start();
        await for (final ev in natural.turn(sNat, text: sc['text'])) {
          if (ev is DoneEvent) answer = ev.text;
        }
        watch.stop();
        await for (final ev in book.turn(sRef, text: sc['text'])) {
          if (ev is DoneEvent) reference = ev.text;
        }
        final valid = {for (final d in sNat.detections) d.number};
        final refs = RegExp(r'#(\d+)').allMatches(answer).map((m) => int.parse(m.group(1)!));
        sink.writeln(jsonEncode({
          'id': sc['id'], 'text': sc['text'], 'action': ruleIntent(sc['text']).action, 'answer': answer, 'reference': reference,
          'invalid_refs': refs.where((n) => !valid.contains(n)).toList(), 'ms': watch.elapsedMilliseconds,
        }));
        print('${sc['id']}: ${answer.length > 90 ? answer.substring(0, 90) : answer}');
      }
      // pertanyaan bebas tanpa foto: dijawab dari catatan dapur (RAG), dinilai dari fakta kunci yang muncul
      for (final line in File('$home/data/eval/kb_questions.jsonl').readAsLinesSync().where((l) => l.trim().isNotEmpty)) {
        final q = jsonDecode(line) as Map<String, dynamic>;
        String answer = '', reference = '', source = '';
        final watch = Stopwatch()..start();
        await for (final ev in natural.turn(Session(q['id']), text: q['text'])) {
          if (ev is DoneEvent) (answer, source) = (ev.text, ev.source);
        }
        watch.stop();
        drafter.lastDraft = '';
        final draftWatch = Stopwatch()..start();
        await for (final _ in drafter.turn(Session('${q['id']}-draft'), text: q['text'])) {}
        draftWatch.stop();
        await for (final ev in book.turn(Session('${q['id']}-ref'), text: q['text'])) {
          if (ev is DoneEvent) reference = ev.text;
        }
        kbSink.writeln(jsonEncode({
          'id': q['id'], 'text': q['text'], 'facts': q['facts'], 'answer': answer, 'reference': reference, 'source': source,
          'draft': drafter.lastDraft, 'draft_ms': draftWatch.elapsedMilliseconds,
          'draft_supported': Guardrails.supported(Guardrails.checkOutput(drafter.lastDraft), drafter.lastNotes, question: q['text']),
          'ms': watch.elapsedMilliseconds,
        }));
        print('${q['id']} [$source]: ${answer.length > 90 ? answer.substring(0, 90) : answer}');
      }
      // pemahaman permintaan oleh model (cadangan aturan): akurasi jenis permintaan dalam JSON terstruktur
      final intentSink = File('$outDir/llm_intents.jsonl').openWrite();
      for (final f in ['intents.jsonl', 'intents_holdout.jsonl']) {
        for (final line in File('$home/data/eval/$f').readAsLinesSync().where((l) => l.trim().isNotEmpty)) {
          final r = jsonDecode(line) as Map<String, dynamic>;
          final out = await server.client.json([
            {'role': 'system', 'content': promptIntentSystem},
            {'role': 'user', 'content': r['text']},
          ], intentSchema).timeout(const Duration(seconds: 30), onTimeout: () => null);
          intentSink.writeln(jsonEncode({'text': r['text'], 'gold': r['action'], 'pred': out?['action']}));
        }
      }
      await intentSink.close();
    } finally {
      await sink.close();
      await kbSink.close();
      await server.stop();
    }
  }, skip: !live, timeout: const Timeout(Duration(minutes: 60)));
}
