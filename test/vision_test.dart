// ignore_for_file: avoid_print
// Uji penglihatan ONNX (OCR kemasan, detektor bahan) di laptop. Perlu pustaka ONNX Runtime host:
//   MEIRA_ORT_LIB=../.venv-train/lib/python3.12/site-packages/onnxruntime/capi/libonnxruntime.so.1.30.0 \
//   MEIRA_HOME=~/MEIRA flutter test test/vision_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/app_state.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/vision/detector.dart';
import 'package:meira/vision/ocr.dart';

Rgba _fixture(String name) {
  final b = Uint8List.fromList(gzip.decode(File('test/fixtures/$name').readAsBytesSync()));
  final head = ByteData.sublistView(b, 0, 8);
  return Rgba(Uint8List.sublistView(b, 8), head.getUint32(0, Endian.little), head.getUint32(4, Endian.little));
}

void main() {
  final lib = Platform.environment['MEIRA_ORT_LIB'] ?? '';
  final home = Platform.environment['MEIRA_HOME'] ?? '..';
  final skip = lib.isEmpty ? 'perlu MEIRA_ORT_LIB' : null;

  test('OCR membaca tulisan kemasan sama dengan versi Python', () {
    final ocr = PackageOcr.load(
      '$home/external/ocr/PP-OCRv5_mobile_det.onnx',
      '$home/external/ocr/latin_PP-OCRv5_mobile_rec.onnx',
      '$home/external/ocr/ppocrv5_latin_keys.txt',
    );
    final watch = Stopwatch()..start();
    final lines = ocr.read(_fixture('ocr_kemasan.rgba.gz')).map((l) => l.text).toList();
    expect(lines, ['Indomie', 'Mi Goreng Spesial', 'Kecap Manis 135 ml']);
    expect(watch.elapsedMilliseconds, lessThan(3000));
  }, skip: skip);

  test('detektor menandai bahan pada foto uji', () async {
    final det = IngredientDetector.load('assets/models/meira-det.onnx');
    // foto uji pertama yang hanya berisi satu jenis bahan
    final row = File('$home/data/meira-sft/test.jsonl')
        .readAsLinesSync()
        .map((l) => jsonDecode(l) as Map<String, dynamic>)
        .firstWhere((r) => r['task'] == 'ground' && (r['objects'] as List).map((o) => o['key']).toSet().length == 1);
    final input = await AppState.visionInput(File(row['image'] as String).readAsBytesSync());
    final watch = Stopwatch()..start();
    final dets = IngredientDetector.toDetections(det.raw(input.square), det.groundThreshold);
    print('${watch.elapsedMilliseconds} ms: ${dets.map((d) => d.key).toList()} (label ${(row['objects'] as List).first['key']})');
    expect(dets.map((d) => d.key), contains((row['objects'] as List).first['key']));
  }, skip: skip);

  test('tulisan kemasan menjadi penanda bahan', () {
    final lines = [
      const TextLine('Indomie', .9, [.1, .1, .4, .2]),
      const TextLine('Mi Goreng Spesial', .9, [.1, .22, .5, .3]),
      const TextLine('Kecap Manis 135 ml', .9, [.6, .6, .9, .7]),
    ];
    final dets = Meira.packagesFromText(lines, []);
    expect(dets.map((d) => d.key), ['noodle', 'sweet_soy_sauce']);
    expect(dets.every((d) => d.packaged), isTrue);
  });
}
