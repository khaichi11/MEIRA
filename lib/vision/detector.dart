/// Detektor bahan (D-FINE, Apache-2.0) yang dilatih ulang untuk 60 bahan MEIRA. Padanan scripts/eval_detector.py:
/// gambar 640 x 640 tanpa normalisasi rata-rata, skor sigmoid per kelas, ambang dipilih pada set validasi.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import '../core/grounding.dart';
import '../core/vocab.dart';
import 'ort.dart';

class RawBox {
  const RawBox(this.label, this.score, this.box);
  final String label; // kunci bahan, akhiran * untuk kotak kelompok
  final double score;
  final List<double> box; // x1, y1, x2, y2 relatif
}

class IngredientDetector {
  IngredientDetector(this.model, this.labels, {required this.groundThreshold, required this.verifyThreshold, this.size = 640});

  /// [path] berkas .onnx; di sebelahnya ada berkas `.labels.txt` dan `.json` (ambang dari evaluasi) dengan nama sama.
  static IngredientDetector load(String path, {int threads = 2}) {
    final base = path.replaceAll(RegExp(r'\.onnx$'), '');
    final labels = File('$base.labels.txt').readAsLinesSync().where((l) => l.trim().isNotEmpty).toList();
    final meta = File('$base.json').existsSync() ? jsonDecode(File('$base.json').readAsStringSync()) as Map<String, dynamic> : const {};
    return IngredientDetector(OrtModel.load(path, threads: threads), labels,
        groundThreshold: (meta['ground'] as num?)?.toDouble() ?? .4, verifyThreshold: (meta['verify'] as num?)?.toDouble() ?? .3);
  }

  final OrtModel model;
  final List<String> labels;
  final double groundThreshold;
  final double verifyThreshold;
  final int size;

  /// [rgba] gambar yang sudah diubah ke [size] x [size] (RGBA 8 bit).
  List<RawBox> raw(Uint8List rgba) {
    final n = size * size;
    final x = Float32List(3 * n);
    for (var i = 0; i < n; i++) {
      x[i] = rgba[i * 4] / 255;
      x[n + i] = rgba[i * 4 + 1] / 255;
      x[2 * n + i] = rgba[i * 4 + 2] / 255;
    }
    final out = model.run(Tensor(x, [1, 3, size, size]));
    final logits = out[0], boxes = out[1];
    final q = logits.shape[1], c = logits.shape[2];
    final found = <RawBox>[];
    for (var i = 0; i < q; i++) {
      for (var k = 0; k < c; k++) {
        final s = 1 / (1 + math.exp(-logits.data[i * c + k]));
        if (s < .05) continue;
        final cx = boxes.data[i * 4], cy = boxes.data[i * 4 + 1], w = boxes.data[i * 4 + 2], h = boxes.data[i * 4 + 3];
        found.add(RawBox(labels[k], s, [cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2].map((v) => v.clamp(0.0, 1.0)).toList()));
      }
    }
    found.sort((a, b) => b.score.compareTo(a.score));
    return found.take(300).toList();
  }

  /// Penanda bahan: kotak di atas ambang, kotak kembar dibuang, lalu dinomori kiri ke kanan.
  static List<Detection> toDetections(List<RawBox> raw, double threshold) {
    final dets = <Detection>[
      for (final r in raw)
        if (r.score >= threshold && r.box[2] > r.box[0] && r.box[3] > r.box[1])
          Detection(
            key: r.label.replaceAll('*', ''),
            label: displayName(r.label.replaceAll('*', '')),
            rawLabel: displayName(r.label.replaceAll('*', '')),
            box: r.box,
            group: r.label.endsWith('*'),
          ),
    ];
    return number(dedupe(dets));
  }

  /// "Apakah ada X?": ambang lebih rendah karena pertanyaannya sudah menyebut bahan yang dicari.
  bool present(List<RawBox> raw, String key) => raw.any((r) => r.label.replaceAll('*', '') == key && r.score >= verifyThreshold);
}
