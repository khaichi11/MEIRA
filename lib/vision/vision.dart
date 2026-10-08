/// Penglihatan MEIRA yang terpisah dari model bahasa: detektor bahan (D-FINE) dan OCR kemasan (PP-OCRv5).
/// Model berjalan di isolate tersendiri lewat ONNX Runtime agar antarmuka tetap lancar.
library;

import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import '../core/grounding.dart';
import 'detector.dart';
import 'ocr.dart';

/// Lokasi berkas model di perangkat.
class VisionPaths {
  const VisionPaths({required this.detector, required this.ocrDet, required this.ocrRec, required this.ocrKeys});
  final String detector;
  final String ocrDet;
  final String ocrRec;
  final String ocrKeys;
}

/// Foto yang sudah disiapkan untuk model: RGBA persegi untuk detektor dan RGBA berukuran asli (dibatasi) untuk OCR.
class VisionInput {
  const VisionInput({required this.square, required this.squareSize, required this.full, required this.width, required this.height});
  final Uint8List square;
  final int squareSize;
  final Uint8List full;
  final int width;
  final int height;
}

/// Hasil satu foto. [raw] disimpan agar pertanyaan "apakah ada X?" tidak perlu menjalankan detektor lagi.
class VisionResult {
  VisionResult(this.raw, this.detections, this.groundThreshold, this.verifyThreshold);
  final List<RawBox> raw;
  final List<Detection> detections;
  final double groundThreshold;
  final double verifyThreshold;

  bool present(String key) => raw.any((r) => r.label.replaceAll('*', '') == key && r.score >= verifyThreshold);

  /// Kotak bahan [key] yang lolos ambang verifikasi tetapi belum ditandai (untuk melengkapi penanda saat ditanya).
  List<Detection> extra(String key, List<Detection> existing) => IngredientDetector.toDetections([
    for (final r in raw)
      if (r.label.replaceAll('*', '') == key) r,
  ], verifyThreshold).where((d) => !existing.any((e) => e.key == key && iou(e.box, d.box) > .5)).toList();
}

abstract class Vision {
  Future<VisionResult> detect(VisionInput input, {bool thorough = false});
  Future<List<TextLine>> read(VisionInput input);
  void close();
}

/// Implementasi di isolate: model dimuat sekali saat pertama dipakai.
class IsolateVision implements Vision {
  IsolateVision(this.paths, {this.threads = 2});
  final VisionPaths paths;
  final int threads;
  SendPort? _port;
  Isolate? _isolate;
  final _ready = Completer<void>();
  bool _starting = false;

  Future<SendPort> _worker() async {
    if (!_starting) {
      _starting = true;
      final rp = ReceivePort();
      _isolate = await Isolate.spawn(_main, [rp.sendPort, paths.detector, paths.ocrDet, paths.ocrRec, paths.ocrKeys, threads]);
      _port = await rp.first as SendPort;
      _ready.complete();
    }
    await _ready.future;
    return _port!;
  }

  Future<Object?> _call(List<Object?> msg) async {
    final reply = ReceivePort();
    (await _worker()).send([reply.sendPort, ...msg]);
    final res = await reply.first;
    reply.close();
    if (res is List && res.isNotEmpty && res.first == 'galat') throw StateError('${res[1]}');
    return res;
  }

  @override
  Future<VisionResult> detect(VisionInput input, {bool thorough = false}) async {
    final res =
        await _call([
              'deteksi',
              TransferableTypedData.fromList([input.square]),
              input.squareSize,
              thorough,
            ])
            as List;
    final raw = [for (final r in res[0] as List) RawBox(r[0] as String, r[1] as double, (r[2] as List).cast<double>())];
    final ground = res[1] as double, verify = res[2] as double;
    return VisionResult(raw, IngredientDetector.toDetections(raw, ground), ground, verify);
  }

  @override
  Future<List<TextLine>> read(VisionInput input) async {
    final res =
        await _call([
              'ocr',
              TransferableTypedData.fromList([input.full]),
              input.width,
              input.height,
            ])
            as List;
    return [for (final l in res) TextLine(l[0] as String, l[1] as double, (l[2] as List).cast<double>())];
  }

  @override
  void close() => _isolate?.kill(priority: Isolate.immediate);

  static void _main(List<Object?> args) {
    final out = args[0] as SendPort;
    final inbox = ReceivePort();
    out.send(inbox.sendPort);
    IngredientDetector? detector;
    PackageOcr? ocr;
    inbox.listen((msg) {
      final m = msg as List;
      final reply = m[0] as SendPort;
      try {
        switch (m[1]) {
          case 'deteksi':
            detector ??= IngredientDetector.load(args[1] as String, threads: args[5] as int);
            final d = detector!;
            final rgba = (m[2] as TransferableTypedData).materialize().asUint8List();
            var raw = d.raw(rgba);
            if (m[4] == true) raw = [...raw, ..._flipped(d, rgba, m[3] as int)]..sort((a, b) => b.score.compareTo(a.score));
            reply.send([
              [
                for (final r in raw) [r.label, r.score, r.box],
              ],
              d.groundThreshold,
              d.verifyThreshold,
            ]);
          case 'ocr':
            ocr ??= PackageOcr.load(args[2] as String, args[3] as String, args[4] as String, threads: args[5] as int);
            final img = Rgba((m[2] as TransferableTypedData).materialize().asUint8List(), m[3] as int, m[4] as int);
            reply.send([
              for (final l in ocr!.read(img)) [l.text, l.confidence, l.box],
            ]);
        }
      } catch (e) {
        reply.send(['galat', '$e']);
      }
    });
  }

  /// Deteksi teliti: foto dicerminkan, hasilnya dikembalikan ke koordinat asli lalu digabung (kotak kembar dibuang
  /// oleh dedupe).
  static List<RawBox> _flipped(IngredientDetector d, Uint8List rgba, int size) {
    final m = Uint8List(rgba.length);
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final a = (y * size + x) * 4, b = (y * size + size - 1 - x) * 4;
        m.setRange(b, b + 4, rgba, a);
      }
    }
    return [
      for (final r in d.raw(m)) RawBox(r.label, r.score, [1 - r.box[2], r.box[1], 1 - r.box[0], r.box[3]]),
    ];
  }
}
