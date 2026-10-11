// ignore_for_file: avoid_print
// Jawaban pengetahuan dari catatan dan fakta, persis seperti yang disusun aplikasi sebelum ditulis ulang model. Dipakai
// scripts/make_voice_sft.py di MEIRA-Before untuk membuat data latih gaya natural. Jalankan:
//   MEIRA_DUMP_IN=pertanyaan.jsonl MEIRA_DUMP_OUT=jawaban.jsonl flutter test test/drafts_dump_test.dart
// Setiap baris masukan: {"q": "...", "mode": "resep" atau "gizi", "before": ["pesan sebelumnya", ...]}.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/core/body.dart';
import 'package:meira/core/intake.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/llm/knowledge.dart';

import 'chat_routes_test.dart' show BookData, MemoryHistory;

void main() {
  final input = Platform.environment['MEIRA_DUMP_IN'];
  final output = Platform.environment['MEIRA_DUMP_OUT'];

  test(
    'jawaban pengetahuan sebelum ditulis ulang',
    () async {
      final recipes = parseRecipes(File('assets/resep.md').readAsStringSync());
      final kb = KnowledgeBase.parse(
        File('assets/pengetahuan.md').readAsStringSync(),
        facts: File('assets/pengetahuan_luas.jsonl').readAsStringSync(),
      );
      final foods = [
        for (final f in kb.facts)
          if (f.nutrition)
            if (Nutrients.parse(f.text) case final n?) Food(f.names.first, f.names, n),
      ];
      final out = File(output!).openWrite();
      var kept = 0;
      for (final line in File(input!).readAsLinesSync().where((l) => l.trim().isNotEmpty)) {
        final item = jsonDecode(line) as Map<String, dynamic>;
        final data = BookData(foods, recipes)..body = const BodyProfile(heightCm: 165, weightKg: 60, age: 25, male: false, activity: 'ringan');
        final m = Meira(recipes: recipes, history: MemoryHistory(), eyes: null, brain: null, knowledge: kb, appData: data, needs: data.needs)
          ..chatMode = item['mode'] as String? ?? 'resep';
        final s = Session('draf');
        for (final before in (item['before'] as List?) ?? const []) {
          await m.turn(s, text: before as String).drain<void>();
        }
        await for (final ev in m.turn(s, text: item['q'] as String)) {
          // semua jawaban dicatat beserta sumbernya; yang ditulis ulang model pada gaya natural hanya jawaban catatan
          // dan fakta
          if (ev is DoneEvent) {
            out.writeln(jsonEncode({...item, 'draft': ev.text, 'source': ev.source}));
            kept++;
          }
        }
      }
      await out.close();
      print('$kept jawaban -> $output');
    },
    skip: input == null || output == null ? 'perlu MEIRA_DUMP_IN dan MEIRA_DUMP_OUT' : null,
    timeout: const Timeout(Duration(minutes: 20)),
  );
}
