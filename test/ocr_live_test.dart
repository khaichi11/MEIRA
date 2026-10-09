// ignore_for_file: avoid_print
// Baca tulisan kemasan dan label gizi dari foto sungguhan. Jalankan:
//   MEIRA_ORT_LIB=<libonnxruntime.so> MEIRA_TEST_PHOTOS=/a.jpg,/b.jpg flutter test test/ocr_live_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/app_state.dart';
import 'package:meira/core/label.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/vision/ocr.dart';

void main() {
  final lib = Platform.environment['MEIRA_ORT_LIB'] ?? '';
  final photos = (Platform.environment['MEIRA_TEST_PHOTOS'] ?? '').split(',').where((p) => p.isNotEmpty).toList();
  test('OCR kemasan dan label gizi', () async {
    final ocr = PackageOcr.load('assets/models/ppocrv5-det.onnx', 'assets/models/ppocrv5-latin-rec.onnx', 'assets/models/ppocrv5-latin-keys.txt');
    for (final path in photos) {
      final input = await AppState.visionInput(File(path).readAsBytesSync());
      final sw = Stopwatch()..start();
      final lines = ocr.read(Rgba(input.full, input.width, input.height));
      print('== $path (${sw.elapsedMilliseconds} ms, ${lines.length} baris)');
      print(lines.map((l) => l.text).join(' | '));
      print('kemasan: ${Meira.packagesFromText(lines, const []).map((d) => '${d.key}:${d.rawLabel}').join(', ')}');
      var label = nutritionLabel(lines);
      print('label gizi: ${label?.describe() ?? '-'}');
      // OCR kedua pada potongan di sekitar judul label, seperti di aplikasi
      final header = lines.where((l) => RegExp(r'nilai gizi|nutrition facts', caseSensitive: false).hasMatch(l.text)).toList()
        ..sort((a, b) => (((a.box[0] + a.box[2]) / 2) - .5).abs().compareTo((((b.box[0] + b.box[2]) / 2) - .5).abs()));
      if (header.isNotEmpty) {
        final h = header.first, w = h.box[2] - h.box[0];
        final crop = await AppState.cropInput(File(path).readAsBytesSync(), [
          (h.box[0] - w * .6).clamp(0, 1),
          (h.box[1] - .02).clamp(0, 1),
          (h.box[2] + w * .6).clamp(0, 1),
          (h.box[1] + w * 2.6).clamp(0, 1),
        ]);
        final zoomLines = ocr.read(Rgba(crop!.full, crop.width, crop.height));
        label = nutritionLabel(zoomLines);
        print('zoom (${crop.width}x${crop.height}): ${zoomLines.map((l) => l.text).join(' | ')}');
        print('label gizi (zoom): ${label?.describe() ?? '-'}');
      }
    }
  }, skip: lib.isEmpty || photos.isEmpty ? 'perlu MEIRA_ORT_LIB dan MEIRA_TEST_PHOTOS' : null);
}
