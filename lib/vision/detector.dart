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
    return IngredientDetector(
      OrtModel.load(path, threads: threads),
      labels,
      groundThreshold: (meta['ground'] as num?)?.toDouble() ?? .4,
      verifyThreshold: (meta['verify'] as num?)?.toDouble() ?? .3,
    );
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

  /// Penanda bahan: kotak di atas ambang, label dicek dengan warna kulit buah bila [rgba] ada, kotak kembar dibuang,
  /// lalu dinomori kiri ke kanan.
  static List<Detection> toDetections(List<RawBox> raw, double threshold, {Uint8List? rgba, int size = 640}) {
    final dets = <Detection>[
      for (final r in raw)
        if (r.score >= threshold && r.box[2] > r.box[0] && r.box[3] > r.box[1])
          _detection(rgba == null ? r.label.replaceAll('*', '') : checkSkin(r, raw, rgba, size), r),
    ];
    return number(dedupe(dets));
  }

  static Detection _detection(String key, RawBox r) =>
      Detection(key: key, label: displayName(key), rawLabel: displayName(key), box: r.box, group: r.label.endsWith('*'));

  /// Buah naga kadang ditandai labu kuning. Kulit buah naga berwarna magenta dan labu kuning jingga: pada foto buah
  /// naga dan labu kuning di dataset, 47% kotak buah naga memenuhi aturan magenta ini dan tidak ada kotak labu kuning
  /// yang memenuhinya. Arah sebaliknya hanya dipakai bila detektor juga melihat labu kuning di tempat itu, karena 3%
  /// kotak buah naga tampak jingga.
  static String checkSkin(RawBox r, List<RawBox> raw, Uint8List rgba, int size) {
    final key = r.label.replaceAll('*', '');
    if (key != 'pumpkin' && key != 'dragon_fruit') return key;
    final (magenta, orange) = skinShares(rgba, size, r.box);
    if (key == 'pumpkin' && magenta > .4 && orange < .15) return 'dragon_fruit';
    final pumpkinHere = raw.any((o) => o.label.replaceAll('*', '') == 'pumpkin' && o.score >= .1 && iou(o.box, r.box) > .5);
    if (key == 'dragon_fruit' && orange > .5 && magenta < .05 && pumpkinHere) return 'pumpkin';
    return key;
  }

  /// Bagian piksel bersaturasi di tengah kotak yang berwarna magenta (rona 290 sampai 352) dan jingga (15 sampai 50).
  static (double, double) skinShares(Uint8List rgba, int size, List<double> box) {
    final x1 = (box[0] * size).round(), y1 = (box[1] * size).round(), x2 = (box[2] * size).round(), y2 = (box[3] * size).round();
    // setengah bagian tengah saja, supaya latar di sudut kotak tidak ikut dihitung
    final cx1 = x1 + (x2 - x1) ~/ 4, cy1 = y1 + (y2 - y1) ~/ 4, cx2 = x2 - (x2 - x1) ~/ 4, cy2 = y2 - (y2 - y1) ~/ 4;
    final step = math.max(1, math.max(cx2 - cx1, cy2 - cy1) ~/ 40);
    var n = 0, magenta = 0, orange = 0;
    for (var y = cy1; y < cy2 && y < size; y += step) {
      for (var x = cx1; x < cx2 && x < size; x += step) {
        final i = (y * size + x) * 4;
        final r = rgba[i] / 255, g = rgba[i + 1] / 255, b = rgba[i + 2] / 255;
        final hi = math.max(r, math.max(g, b)), lo = math.min(r, math.min(g, b)), d = hi - lo;
        n++;
        if (hi <= .2 || d / hi <= .25) continue;
        final hue = hi == r ? 60 * (((g - b) / d) % 6) : (hi == g ? 60 * ((b - r) / d + 2) : 60 * ((r - g) / d + 4));
        if (hue >= 290 && hue <= 352) {
          magenta++;
        } else if (hue >= 15 && hue <= 50) {
          orange++;
        }
      }
    }
    return n == 0 ? (0.0, 0.0) : (magenta / n, orange / n);
  }

  /// "Apakah ada X?": ambang lebih rendah karena pertanyaannya sudah menyebut bahan yang dicari.
  bool present(List<RawBox> raw, String key) => raw.any((r) => r.label.replaceAll('*', '') == key && r.score >= verifyThreshold);
}
