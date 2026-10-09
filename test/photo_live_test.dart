// ignore_for_file: avoid_print
// Uji foto dengan susunan yang sama seperti aplikasi: detektor ONNX, model bahasa dengan mmproj, dan basis pengetahuan.
// Dipakai untuk memeriksa foto bahan yang tidak termasuk kelas detektor. Jalankan:
//   MEIRA_LIVE=1 MEIRA_TEST_PHOTO=/path/foto.jpg \
//   MEIRA_ORT_LIB=../.venv-train/lib/python3.12/site-packages/onnxruntime/capi/libonnxruntime.so.1.30.0 \
//   flutter test test/photo_live_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:meira/app_state.dart';
import 'package:meira/core/history.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/llm/knowledge.dart';
import 'package:meira/runtime/llama.dart';
import 'package:meira/vision/vision.dart';

void main() {
  final live = Platform.environment['MEIRA_LIVE'] == '1';
  final home = Platform.environment['MEIRA_HOME'] ?? '${Platform.environment['HOME']}/MEIRA';
  final photo = Platform.environment['MEIRA_TEST_PHOTO'] ?? '';
  final questions = (Platform.environment['MEIRA_TEST_ASK'] ?? '').split('|').where((q) => q.isNotEmpty).toList();

  test(
    'foto bahan di luar kelas detektor tetap dijawab',
    () async {
      final server = LlamaServer(
        name: 'otak',
        model: '$home/models/app/qwen3.5-0.8b-instruct-Q4_K_M.gguf',
        mmproj: '$home/models/app/qwen3.5-0.8b-instruct-mmproj-F16.gguf',
        lora: (Platform.environment['MEIRA_LORA'] ?? '').isEmpty ? null : Platform.environment['MEIRA_LORA'],
        port: 8398,
        binary: '$home/external/llama.cpp/llama-b11476/llama-server',
        gpuLayers: 99,
      );
      await server.start(maxImageTokens: 256);
      final tmp = await Directory.systemTemp.createTemp('meira_foto');
      sqfliteFfiInit();
      final history = await History.open(at: tmp, factory: databaseFactoryFfi);
      final meira = Meira(
        recipes: parseRecipes(File('assets/resep.md').readAsStringSync()),
        history: history,
        eyes: null,
        vision: IsolateVision(
          const VisionPaths(
            detector: 'assets/models/meira-det.onnx',
            ocrDet: 'assets/models/ppocrv5-det.onnx',
            ocrRec: 'assets/models/ppocrv5-latin-rec.onnx',
            ocrKeys: 'assets/models/ppocrv5-latin-keys.txt',
          ),
        ),
        brain: server.client,
        useLlmIntent: false,
        // MEIRA_NO_SCENE=1 meniru ponsel yang tidak sempat menjalankan model penglihatan
        brainHasVision: Platform.environment['MEIRA_NO_SCENE'] != '1',
        answerStyle: Platform.environment['MEIRA_STYLE'] ?? 'ringkas',
        parallelVision: false,
        knowledge: KnowledgeBase.parse(
          File('assets/pengetahuan.md').readAsStringSync(),
          facts: File('assets/pengetahuan_luas.jsonl').readAsStringSync(),
        ),
      );
      final bytes = await File(photo).readAsBytes();
      final s = Session('foto');
      try {
        for (final (text, url) in [('', 'data:image/jpeg;base64,${base64Encode(bytes)}'), for (final q in questions) (q, null)]) {
          final input = url == null ? null : await AppState.visionInput(bytes);
          final sw = Stopwatch()..start();
          await for (final ev in meira.turn(s, text: text, imageDataUrl: url, visionInput: input)) {
            switch (ev) {
              case DetectionsEvent(:final items):
                print('deteksi: ${items.map((d) => '${d.number}=${d.label}').join(', ')}');
              case SceneEvent(:final mode, :final dish):
                print('jenis: $mode, hidangan: $dish');
              case DoneEvent(:final text, :final source):
                print('[${sw.elapsedMilliseconds} ms, $source] ${text.isEmpty ? '(KOSONG)' : text}');
                expect(text.trim(), isNotEmpty);
              case ErrorEvent(:final text):
                print('galat: $text');
              default:
            }
          }
        }
      } finally {
        await server.stop();
      }
    },
    skip: live && photo.isNotEmpty ? null : 'perlu MEIRA_LIVE=1 dan MEIRA_TEST_PHOTO',
    timeout: const Timeout(Duration(minutes: 6)),
  );
}
