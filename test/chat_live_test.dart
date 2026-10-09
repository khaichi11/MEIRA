// ignore_for_file: avoid_print
// Percakapan teks dengan model bahasa sungguhan, tanpa foto. Jalankan:
//   MEIRA_LIVE=1 MEIRA_HOME=/path/MEIRA flutter test test/chat_live_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/core/history.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/llm/knowledge.dart';
import 'package:meira/runtime/llama.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const questions = [
  'halo',
  'terima kasih ya',
  'kamu bisa bantu apa aja?',
  'apa bedanya pisang ambon sama pisang kepok?',
  'kenapa tempe bisa pahit?',
  'telur ayam kampung beda nggak sama telur ayam negeri?',
  'apa bedanya rendang sama kalio?',
  'pisang hijau itu pisang apa sih?',
];

void main() {
  final live = Platform.environment['MEIRA_LIVE'] == '1';
  final home = Platform.environment['MEIRA_HOME'] ?? '${Platform.environment['HOME']}/MEIRA';

  test(
    'obrolan teks dijawab oleh model',
    () async {
      final server = LlamaServer(
        name: 'otak',
        // MEIRA_BRAIN memilih model lain untuk dibandingkan, misalnya models/gguf/Qwen3.5-2B-Q4_K_M.gguf
        model: Platform.environment['MEIRA_BRAIN'] ?? '$home/models/app/qwen3.5-0.8b-instruct-Q4_K_M.gguf',
        mmproj: Platform.environment['MEIRA_BRAIN'] == null ? '$home/models/app/qwen3.5-0.8b-instruct-mmproj-F16.gguf' : null,
        port: 8398,
        binary: Directory(
          '$home/external/llama.cpp',
        ).listSync(recursive: true).whereType<File>().firstWhere((f) => f.path.endsWith('/llama-server')).path,
        gpuLayers: 99,
      );
      await server.start(maxImageTokens: 256);
      final tmp = await Directory.systemTemp.createTemp('meira_chat');
      sqfliteFfiInit();
      final history = await History.open(at: tmp, factory: databaseFactoryFfi);
      final meira = Meira(
        recipes: parseRecipes(File('assets/resep.md').readAsStringSync()),
        history: history,
        eyes: null,
        brain: server.client,
        useLlmIntent: false,
        knowledge: KnowledgeBase.parse(File('assets/pengetahuan.md').readAsStringSync()),
      )..userName = 'Khai';
      try {
        for (final q in questions) {
          final s = Session('obrolan');
          final sw = Stopwatch()..start();
          await for (final ev in meira.turn(s, text: q)) {
            if (ev is DoneEvent) print('[$q] (${ev.source}, ${sw.elapsedMilliseconds} ms)\n  ${ev.text}\n');
          }
        }
      } finally {
        await server.stop();
        await tmp.delete(recursive: true);
      }
    },
    skip: live ? null : 'perlu MEIRA_LIVE=1',
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
