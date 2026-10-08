/// OCR tulisan kemasan: PP-OCRv5 mobile (Apache-2.0), deteksi baris DBNet lalu pengenal huruf Latin (CTC).
/// Padanan meira/ocr.py; pascaproses sengaja sederhana (kotak tegak lurus) agar cepat di CPU ponsel.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'ort.dart';

class TextLine {
  const TextLine(this.text, this.confidence, this.box);
  final String text;
  final double confidence;
  final List<double> box; // x1, y1, x2, y2 relatif terhadap foto
}

/// Gambar RGBA sederhana yang bisa dipotong dan diubah ukurannya tanpa dart:ui (aman dipakai di isolate).
class Rgba {
  Rgba(this.data, this.width, this.height);
  final Uint8List data;
  final int width;
  final int height;

  /// Potong lalu ubah ukuran dengan interpolasi bilinear; hasil: tensor CHW urutan BGR, (nilai/255 - mean)/std.
  Float32List tensor(int x0, int y0, int x1, int y1, int outW, int outH, List<double> mean, List<double> std) {
    final out = Float32List(3 * outW * outH);
    final sx = (x1 - x0) / outW, sy = (y1 - y0) / outH;
    for (var y = 0; y < outH; y++) {
      final fy = (y0 + (y + .5) * sy - .5).clamp(0.0, height - 1.0);
      final iy = fy.floor(), dy = fy - iy, iy2 = math.min(iy + 1, height - 1);
      for (var x = 0; x < outW; x++) {
        final fx = (x0 + (x + .5) * sx - .5).clamp(0.0, width - 1.0);
        final ix = fx.floor(), dx = fx - ix, ix2 = math.min(ix + 1, width - 1);
        for (var c = 0; c < 3; c++) {
          double px(int xx, int yy) => data[(yy * width + xx) * 4 + c].toDouble();
          final v = (px(ix, iy) * (1 - dx) + px(ix2, iy) * dx) * (1 - dy) + (px(ix, iy2) * (1 - dx) + px(ix2, iy2) * dx) * dy;
          final ch = 2 - c; // model PaddleOCR dilatih dengan urutan BGR
          out[ch * outW * outH + y * outW + x] = (v / 255 - mean[ch]) / std[ch];
        }
      }
    }
    return out;
  }
}

class PackageOcr {
  PackageOcr(this.det, this.rec, this.chars, {this.maxSide = 960});

  static PackageOcr load(String detPath, String recPath, String keysPath, {int threads = 2}) {
    final keys = File(keysPath).readAsLinesSync();
    return PackageOcr(OrtModel.load(detPath, threads: threads), OrtModel.load(recPath, threads: threads), ['', ...keys, ' ']);
  }

  final OrtModel det;
  final OrtModel rec;
  final List<String> chars;
  final int maxSide;

  static const _detMean = [0.406, 0.456, 0.485], _detStd = [0.225, 0.224, 0.229]; // urutan BGR
  static const _recMean = [.5, .5, .5], _recStd = [.5, .5, .5];

  List<List<int>> boxes(Rgba img, {double thresh = .3, double boxThresh = .6}) {
    final s = math.min(1.0, maxSide / math.max(img.width, img.height));
    final nw = math.max(32, (img.width * s / 32).round() * 32), nh = math.max(32, (img.height * s / 32).round() * 32);
    final prob = det.run(Tensor(img.tensor(0, 0, img.width, img.height, nw, nh, _detMean, _detStd), [1, 3, nh, nw]))[0].data;
    final seen = Uint8List(nw * nh);
    final out = <List<int>>[];
    final queue = <int>[];
    for (var start = 0; start < nw * nh; start++) {
      if (seen[start] == 1 || prob[start] <= thresh) continue;
      // isi area bersambung (4 tetangga) untuk satu baris teks
      queue
        ..clear()
        ..add(start);
      seen[start] = 1;
      var minX = nw, minY = nh, maxX = 0, maxY = 0, sum = 0.0, count = 0;
      for (var head = 0; head < queue.length; head++) {
        final p = queue[head], x = p % nw, y = p ~/ nw;
        sum += prob[p];
        count++;
        minX = math.min(minX, x);
        maxX = math.max(maxX, x);
        minY = math.min(minY, y);
        maxY = math.max(maxY, y);
        for (final n in [if (x > 0) p - 1, if (x < nw - 1) p + 1, if (y > 0) p - nw, if (y < nh - 1) p + nw]) {
          if (seen[n] == 0 && prob[n] > thresh) {
            seen[n] = 1;
            queue.add(n);
          }
        }
      }
      final bw = maxX + 1 - minX, bh = maxY + 1 - minY;
      if (math.min(bw, bh) < 3 || sum / count < boxThresh) continue;
      final d = 1.5 * bw * bh / (2 * (bw + bh)); // unclip seperti DBNet
      out.add([
        math.max(0, ((minX - d) * img.width / nw).round()),
        math.max(0, ((minY - d) * img.height / nh).round()),
        math.min(img.width, ((maxX + 1 + d) * img.width / nw).round()),
        math.min(img.height, ((maxY + 1 + d) * img.height / nh).round()),
      ]);
    }
    return mergeWords(out);
  }

  /// Gabungkan kata yang berdampingan pada baris yang sama menjadi satu baris teks (padanan merge_words di Python).
  static List<List<int>> mergeWords(List<List<int>> boxes) {
    final out = <List<int>>[];
    for (final b in [...boxes]..sort((a, b) => a[0].compareTo(b[0]))) {
      final m = out.where((m) {
        final h = math.min(b[3] - b[1], m[3] - m[1]);
        final overlap = math.min(b[3], m[3]) - math.max(b[1], m[1]);
        return overlap >= .5 * h && b[0] - m[2] <= .8 * h;
      }).firstOrNull;
      if (m == null) {
        out.add([...b]);
      } else {
        m.setAll(0, [math.min(m[0], b[0]), math.min(m[1], b[1]), math.max(m[2], b[2]), math.max(m[3], b[3])]);
      }
    }
    out.sort((a, b) => a[1] ~/ 20 != b[1] ~/ 20 ? (a[1] ~/ 20).compareTo(b[1] ~/ 20) : a[0].compareTo(b[0]));
    return out;
  }

  (String, double) readLine(Rgba img, List<int> b) {
    final w = b[2] - b[0], h = math.max(1, b[3] - b[1]);
    final nw = (48 * w / h).round().clamp(16, 960);
    final out = rec.run(Tensor(img.tensor(b[0], b[1], b[2], b[3], nw, 48, _recMean, _recStd), [1, 3, 48, nw]))[0];
    final steps = out.shape[1], c = out.shape[2];
    final text = StringBuffer();
    var prev = 0, conf = 0.0, kept = 0;
    for (var t = 0; t < steps; t++) {
      var best = 0;
      for (var k = 1; k < c; k++) {
        if (out.data[t * c + k] > out.data[t * c + best]) best = k;
      }
      if (best != 0 && best != prev && best < chars.length) {
        text.write(chars[best]);
        conf += out.data[t * c + best];
        kept++;
      }
      prev = best;
    }
    return (text.toString().trim(), kept == 0 ? 0 : conf / kept);
  }

  List<TextLine> read(Rgba img, {double minConfidence = .6}) => [
    for (final b in boxes(img))
      if (readLine(img, b) case (final text, final conf) when text.isNotEmpty && conf >= minConfidence)
        TextLine(text, conf, [b[0] / img.width, b[1] / img.height, b[2] / img.width, b[3] / img.height]),
  ];
}
