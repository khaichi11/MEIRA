/// Membaca keluaran model "mata": deteksi bahan bernomor dan jawaban verifikasi.
library;

import 'dart:convert';

import 'generated.dart';
import 'vocab.dart';

const coordScale = 1000.0;

class Detection {
  Detection({required this.key, required this.label, required this.rawLabel, required this.box, this.number = 0, this.group = false});

  final String? key;
  final String label;
  final String rawLabel;
  final List<double> box; // x1, y1, x2, y2 ternormalisasi 0..1
  int number;
  final bool group;

  double get cx => (box[0] + box[2]) / 2;
  double get cy => (box[1] + box[3]) / 2;
  double get area => (box[2] - box[0]) * (box[3] - box[1]);

  Map<String, dynamic> toJson() => {'key': key, 'label': label, 'raw_label': rawLabel, 'box': box, 'number': number, 'group': group};

  factory Detection.fromJson(Map<String, dynamic> j) => Detection(
        key: j['key'] as String?,
        label: j['label'] as String,
        rawLabel: (j['raw_label'] ?? j['label']) as String,
        box: (j['box'] as List).map((e) => (e as num).toDouble()).toList(),
        number: (j['number'] ?? 0) as int,
        group: j['group'] == true,
      );
}

class IngredientGroup {
  IngredientGroup(this.key, this.label, this.numbers);
  final String? key;
  final String label;
  final List<int> numbers;
  int single = 0;
  int group = 0;

  /// Jumlah dengan satuan alami: "5 buah", "1 tandan", "setumpuk", atau "" untuk bahan curah.
  String get count {
    if (massKeys.contains(key)) return '';
    final (unit, groupUnit) = unitTable[key] ?? ('buah', 'setumpuk');
    return [
      if (single > 0) '$single $unit',
      if (group > 0) group == 1 ? groupUnit : '$group × $groupUnit',
    ].join(' + ');
  }
}

double iou(List<double> a, List<double> b) {
  final ix = (a[2] < b[2] ? a[2] : b[2]) - (a[0] > b[0] ? a[0] : b[0]);
  final iy = (a[3] < b[3] ? a[3] : b[3]) - (a[1] > b[1] ? a[1] : b[1]);
  if (ix <= 0 || iy <= 0) return 0;
  final inter = ix * iy;
  final union = (a[2] - a[0]) * (a[3] - a[1]) + (b[2] - b[0]) * (b[3] - b[1]) - inter;
  return union > 0 ? inter / union : 0;
}

List<double>? normalizeBox(List<double> raw) {
  var v = raw.map((e) => (e / coordScale).clamp(0.0, 1.0)).toList();
  final x1 = v[0] < v[2] ? v[0] : v[2], x2 = v[0] < v[2] ? v[2] : v[0];
  final y1 = v[1] < v[3] ? v[1] : v[3], y2 = v[1] < v[3] ? v[3] : v[1];
  if (x2 - x1 < .005 || y2 - y1 < .005) return null;
  return [x1, y1, x2, y2];
}

final _line = RegExp(r'^\s*[-•\d.)]*\s*([^\d\n*][^\n*]*?)\s*(\*)?\s+(\d{1,4})[ ,]+(\d{1,4})[ ,]+(\d{1,4})[ ,]+(\d{1,4})\s*$');
final _boxLine = RegExp(r'^\s*(\d{1,4})[ ,]+(\d{1,4})[ ,]+(\d{1,4})[ ,]+(\d{1,4})\s*$');

Detection? _make(String label, List<double> raw, bool group) {
  label = label.trim();
  if (label.isEmpty || isNonFood(label)) return null;
  final box = normalizeBox(raw);
  if (box == null) return null;
  final key = resolve(label);
  return Detection(key: key, label: key != null ? displayName(key) : label, rawLabel: label, box: box, group: group);
}

/// Satu baris format ringkas "nama x1 y1 x2 y2"; dipakai juga saat streaming.
Detection? parseLine(String line) {
  final m = _line.firstMatch(line);
  if (m == null) return null;
  return _make(m.group(1)!.replaceAll(RegExp(r'^[:\-\s]+|[:\-\s]+$'), ''), [for (var i = 3; i <= 6; i++) double.parse(m.group(i)!)], m.group(2) != null);
}

List<Detection> parseDetections(String text) {
  text = text.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '');
  final compact = [for (final l in const LineSplitter().convert(text)) ?parseLine(l)];
  if (compact.isNotEmpty) return number(dedupe(compact));
  // model zero-shot biasanya menjawab JSON [{"bbox_2d": [...], "label": "..."}]
  final data = _extractJson(text);
  final list = data is List ? data : (data is Map ? (data['objects'] ?? data['objek'] ?? []) : []);
  final dets = <Detection>[];
  for (final o in list) {
    if (o is! Map) continue;
    final raw = o['bbox_2d'] ?? o['box_2d'] ?? o['bbox'];
    final label = (o['label'] ?? o['name'] ?? '').toString();
    if (raw is! List || raw.length != 4) continue;
    final d = _make(label, raw.map((e) => (e as num).toDouble()).toList(), o['kelompok'] == true || o['group'] == true);
    if (d != null) dets.add(d);
  }
  return number(dedupe(dets));
}

/// (ada?, kotak) dari jawaban verifikasi.
(bool?, List<List<double>>) parseVerify(String text) {
  final head = text.trim().toLowerCase();
  if (head.startsWith('tidak ada')) return (false, []);
  if (head.startsWith('ada')) {
    final boxes = <List<double>>[];
    for (final l in const LineSplitter().convert(text).skip(1)) {
      final m = _boxLine.firstMatch(l);
      if (m == null) continue;
      final b = normalizeBox([for (var i = 1; i <= 4; i++) double.parse(m.group(i)!)]);
      if (b != null) boxes.add(b);
    }
    return (true, boxes);
  }
  final data = _extractJson(text);
  if (data is Map) {
    final present = data['ada'] ?? data['present'];
    var raw = (data['bbox_2d'] as List?) ?? [];
    if (raw.isNotEmpty && raw.first is num) raw = [raw];
    final boxes = [for (final r in raw) if (r is List && r.length == 4) ?normalizeBox(r.map((e) => (e as num).toDouble()).toList())];
    return (present is bool ? present : boxes.isNotEmpty, boxes);
  }
  if (RegExp(r'\b(tidak ada|tidak terlihat)\b').hasMatch(head)) return (false, []);
  return (null, []);
}

dynamic _extractJson(String text) {
  final fence = RegExp(r'```(?:json)?\s*([\s\S]+?)```').firstMatch(text);
  if (fence != null) text = fence.group(1)!;
  for (final (open, close) in [('[', ']'), ('{', '}')]) {
    final s = text.indexOf(open), e = text.lastIndexOf(close);
    if (s != -1 && e > s) {
      final chunk = text.substring(s, e + 1);
      try {
        return jsonDecode(chunk);
      } catch (_) {
        if (open == '[') {
          final last = chunk.lastIndexOf('}');
          if (last != -1) {
            try {
              return jsonDecode('${chunk.substring(0, last + 1)}]');
            } catch (_) {}
          }
        }
      }
    }
  }
  return null;
}

/// Buang kotak kembar (model kecil suka mengulang) dan kotak seluas seluruh foto.
List<Detection> dedupe(List<Detection> dets, {double thr = .7}) {
  final kept = <Detection>[];
  for (final d in dets) {
    if (d.area > .92 && dets.length > 1) continue;
    final same = d.key ?? d.label;
    if (kept.any((k) => iou(d.box, k.box) > (same == (k.key ?? k.label) ? thr : .9))) continue;
    kept.add(d);
  }
  return kept;
}

/// Nomor urut kiri ke kanan (titik tengah), seri dipecah atas ke bawah.
List<Detection> number(List<Detection> dets) {
  final ordered = [...dets]..sort((a, b) {
      final c = ((a.cx * 100).round()).compareTo((b.cx * 100).round());
      return c != 0 ? c : a.cy.compareTo(b.cy);
    });
  for (var i = 0; i < ordered.length; i++) {
    ordered[i].number = i + 1;
  }
  return ordered;
}

List<IngredientGroup> grouped(List<Detection> dets) {
  final out = <String, IngredientGroup>{};
  for (final d in dets) {
    final k = d.key ?? '?${d.label}';
    final g = out.putIfAbsent(k, () => IngredientGroup(d.key, d.label, []));
    g.numbers.add(d.number);
    if (d.group) {
      g.group++;
    } else {
      g.single++;
    }
  }
  return out.values.toList();
}
