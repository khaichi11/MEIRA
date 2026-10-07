// ignore_for_file: avoid_print
// Uji integrasi dengan model sungguhan. Jalankan:
//   MEIRA_LIVE=1 MEIRA_HOME=/path/MEIRA flutter test test/pipeline_live_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/core/history.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/runtime/llama.dart';

void main() {
  final live = Platform.environment['MEIRA_LIVE'] == '1';
  final home = Platform.environment['MEIRA_HOME'] ?? '${Platform.environment['HOME']}/MEIRA';
  final photo = Platform.environment['MEIRA_TEST_PHOTO'] ?? '/tmp/meira_test/ac4836e92d94b93f.jpg';

  test('foto -> penanda -> resep -> jawaban', () async {
    final server = LlamaServer(
      name: 'otak',
      model: '$home/models/app/qwen3.5-0.8b-instruct-Q4_K_M.gguf',
      mmproj: '$home/models/app/qwen3.5-0.8b-instruct-mmproj-F16.gguf',
      port: 8399,
    );
    final sw = Stopwatch()..start();
    await server.start(maxImageTokens: 256);
    print('llama-server siap dalam ${sw.elapsedMilliseconds} ms');
    final tmp = await Directory.systemTemp.createTemp('meira_live');
    final history = await History.open(at: tmp);
    final recipes = parseRecipes(File('assets/resep.md').readAsStringSync());
    final meira = Meira(recipes: recipes, history: history, eyes: server.client, brain: server.client);
    final bytes = await File(photo).readAsBytes();
    final url = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    final s = Session('uji');
    try {
      await for (final ev in meira.turn(s, text: 'aku mau yang cepat', imageDataUrl: url)) {
        switch (ev) {
          case DetectionsEvent(:final items, :final seconds):
            print('deteksi ${seconds}s: ${items.map((d) => '${d.number}=${d.label}').join(', ')}');
          case SceneEvent(:final mode, :final dish):
            print('jenis: $mode $dish');
          case RecipesEvent():
            print('resep: ${s.candidates.map((m) => m.recipe.name).join(' | ')}');
          case DoneEvent(:final text, :final source):
            print('jawaban [$source]: $text');
          case ErrorEvent(:final text):
            print('galat: $text');
          default:
        }
      }
      await for (final ev in meira.turn(s, text: 'ganti yang lain, jangan pedas')) {
        if (ev is DoneEvent) print('lanjutan: ${ev.text}');
      }
      expect(s.history, isNotEmpty);
    } finally {
      await server.stop();
    }
  }, skip: !live, timeout: const Timeout(Duration(minutes: 5)));
}
