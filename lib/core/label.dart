/// Label "Informasi Nilai Gizi" (atau "Nutrition Facts") yang dibaca OCR dari foto kemasan: takaran saji, jumlah sajian
/// per kemasan, dan nilai gizi per sajian. Dari situ disusun jawaban per sajian dan per kemasan, dibandingkan dengan
/// kebutuhan harian pengguna, beserta saran porsi.
library;

import '../vision/ocr.dart';
import 'intake.dart';

class NutritionLabel {
  const NutritionLabel({
    this.serving,
    this.unit = 'g',
    this.servings,
    required this.energy,
    this.fat,
    this.saturated,
    this.protein,
    this.carbs,
    this.sugar,
    this.sodium,
  });
  final double? serving; // takaran saji
  final String unit; // g atau ml
  final double? servings; // sajian per kemasan
  final double energy; // kkal per sajian
  final double? fat, saturated, protein, carbs, sugar; // gram per sajian
  final double? sodium; // miligram per sajian

  /// Label dengan satu nilai yang dibetulkan pengguna ("lemaknya 5 g").
  NutritionLabel corrected(String field, double v) => NutritionLabel(
    serving: field == 'takaran' ? v : serving,
    unit: unit,
    servings: field == 'sajian' ? v : servings,
    energy: field == 'energi' ? v : energy,
    fat: field == 'lemak' ? v : fat,
    saturated: saturated,
    protein: field == 'protein' ? v : protein,
    carbs: field == 'karbohidrat' ? v : carbs,
    sugar: field == 'gula' ? v : sugar,
    sodium: field == 'natrium' ? v : sodium,
  );

  int get fieldCount => [fat, protein, carbs, sugar, sodium, servings].where((v) => v != null).length;

  Nutrients get perServing =>
      Nutrients(energy: energy, protein: protein ?? 0, fat: fat ?? 0, carbs: carbs ?? 0, sugar: sugar ?? 0, sodium: sodium ?? 0);

  String describe() => [
    'per sajian${serving == null ? '' : ' ${_n(serving!)} $unit'}: energi ${_n(energy)} kkal',
    if (fat != null) 'lemak ${_n(fat!)} g',
    if (protein != null) 'protein ${_n(protein!)} g',
    if (carbs != null) 'karbohidrat ${_n(carbs!)} g',
    if (sugar != null) 'gula ${_n(sugar!)} g',
    if (sodium != null) 'natrium ${_n(sodium!)} mg',
    if (servings != null) '${_n(servings!)} sajian per kemasan',
  ].join(', ');
}

String _n(double v) => (v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1)).replaceAll('.', ',');

final _header = RegExp(r'informasi nilai gizi|nutrition facts|nilai gizi', caseSensitive: false);

/// Baris OCR disusun menjadi teks menurut urutan baca (atas ke bawah, kiri ke kanan). Bila ada lebih dari satu label di
/// foto, dipakai label yang judulnya paling dekat dengan tengah foto.
String _labelText(List<TextLine> lines) {
  final headers = lines.where((l) => _header.hasMatch(l.text)).toList();
  var picked = lines;
  if (headers.isNotEmpty) {
    double cx(TextLine l) => (l.box[0] + l.box[2]) / 2;
    headers.sort((a, b) => (cx(a) - .5).abs().compareTo((cx(b) - .5).abs()));
    final h = headers.first;
    // beberapa label berdampingan: setiap baris ikut label yang judulnya paling dekat secara mendatar
    final others = headers.skip(1).where((o) => (cx(o) - cx(h)).abs() > (h.box[2] - h.box[0]) * .5).toList();
    picked = [
      for (final l in lines)
        if (l.box[3] >= h.box[1] && others.every((o) => (cx(l) - cx(h)).abs() <= (cx(l) - cx(o)).abs())) l,
    ];
  }
  picked = [...picked]..sort((a, b) => a.box[1].compareTo(b.box[1]));
  // satu baris visual: pusat vertikal yang berdekatan
  final rows = <List<TextLine>>[];
  for (final l in picked) {
    final cy = (l.box[1] + l.box[3]) / 2, hgt = l.box[3] - l.box[1];
    final row = rows.where((r) => ((r.first.box[1] + r.first.box[3]) / 2 - cy).abs() < hgt * .6).firstOrNull;
    if (row == null) {
      rows.add([l]);
    } else {
      row.add(l);
    }
  }
  final text = [
    for (final r in rows) ([...r]..sort((a, b) => a.box[0].compareTo(b.box[0]))).map((l) => l.text).join(' '),
  ].join('\n').toLowerCase().replaceAll(',', '.');
  // kesalahan OCR yang lazim pada label: huruf O dibaca sebagai nol ("Og"), dan "mg" atau "g" yang menempel
  return text.replaceAllMapped(RegExp(r'\bo\s?(m?g)\b'), (m) => '0${m[1]}');
}

/// Huruf "g" yang terbaca sebagai angka 9 atau 8 ("10g" menjadi "109"): nilai gram per sajian di atas 100 tidak masuk
/// akal untuk lemak, gula, protein, atau karbohidrat, jadi angka terakhirnya dibuang.
double? _grams(double? v) => v == null || v <= 100 ? v : ((v ~/ 10) == v / 10 ? null : (v ~/ 10).toDouble());

double? _grab(String text, List<String> patterns) {
  for (final p in patterns) {
    final m = RegExp(p).firstMatch(text);
    if (m != null) return double.tryParse(m[1]!);
  }
  return null;
}

const _num = r'(\d+(?:\.\d+)?)';

/// Label gizi dari baris OCR, atau null bila foto tidak memuat label gizi yang terbaca.
NutritionLabel? nutritionLabel(List<TextLine> lines) {
  final t = _labelText(lines);
  final energy = _grab(t, [
    'energi total[^0-9\\n]{0,20}$_num\\s*k(?:k|c)al',
    'total energy[^0-9\\n]{0,10}$_num\\s*k(?:k|c)al',
    'calories[^0-9\\n]{0,10}$_num',
    '$_num\\s*(?:\\|\\s*)?\\n?\\s*calories',
    'energi[^0-9\\n]{0,10}$_num\\s*kkal',
  ]);
  if (energy == null) return null;
  final fat = _grams(_grab(t, ['lemak total[^0-9\\n]{0,25}$_num\\s*g?', 'total fat[^0-9\\n]{0,10}$_num\\s*g']));
  final saturated = _grab(t, ['lemak jenuh[^0-9\\n]{0,25}$_num\\s*g', 'saturated fat[^0-9\\n]{0,10}$_num\\s*g']);
  final protein = _grams(_grab(t, ['protein[^0-9\\n]{0,15}$_num\\s*g?']));
  final carbs = _grams(_grab(t, ['karbohidrat total[^0-9\\n]{0,30}$_num\\s*g?', 'total carb(?:ohydrate)?s?[^0-9\\n]{0,10}$_num\\s*g']));
  final sugar = _grams(_grab(t, ['gula[^0-9\\n]{0,15}$_num\\s*g?', 'total sugars[^0-9\\n]{0,10}$_num\\s*g', 'sugars[^0-9\\n]{0,10}$_num\\s*g']));
  final sodium = _grab(t, [
    '(?:garam|natrium|sodium)[^0-9\\n]{0,30}$_num\\s*mg',
    '(?:garam|natrium|sodium)[^0-9\\n]{0,30}$_num\\s*m\\b',
    '$_num\\s*mg?\\b[^\\n]{0,12}\\n?[^\\n]{0,12}(?:garam|natrium|sodium)',
  ]);
  if ([fat, protein, carbs, sugar, sodium].where((v) => v != null).length < 2) return null;
  final servingMatch =
      RegExp('takaran saji[^0-9\\n]{0,5}$_num\\s*(g|ml)').firstMatch(t) ?? RegExp('serving size[^0-9\\n]{0,10}$_num\\s*(g|ml)').firstMatch(t);
  final servings = _grab(t, [
    '$_num\\s*sajian per kemasan',
    'sajian per kemasan[^0-9\\n]{0,5}$_num',
    '$_num\\s*servings? per container',
    'servings? per container[^0-9\\n]{0,5}$_num',
  ]);
  return NutritionLabel(
    serving: servingMatch == null ? null : double.tryParse(servingMatch[1]!),
    unit: servingMatch?[2] ?? 'g',
    servings: servings,
    energy: energy,
    fat: fat,
    saturated: saturated,
    protein: protein,
    carbs: carbs,
    sugar: sugar,
    sodium: sodium,
  );
}

int _pct(double v, double target) => target == 0 ? 0 : (v / target * 100).round();

String _join(List<String> xs) => xs.length <= 1 ? xs.join() : '${xs.sublist(0, xs.length - 1).join(', ')} dan ${xs.last}';

/// Jawaban untuk foto label gizi: per sajian, bila dihabiskan sekemasan, saran porsi, dan catatan umum bila ada zat
/// yang tinggi. [whole] menekankan jawaban untuk satu kemasan penuh ("kalau saya makan semuanya?").
String labelAnswer(NutritionLabel l, Targets t, {bool whole = false}) {
  final one = l.perServing;
  final n = l.servings ?? 1;
  final all = one.scale(n);
  String share(Nutrients x) => _join([
    '${_pct(x.energy, t.energy)}% energi',
    if (l.sugar != null) '${_pct(x.sugar, t.sugar)}% batas gula',
    if (l.fat != null) '${_pct(x.fat, t.fat)}% batas lemak',
    if (l.sodium != null) '${_pct(x.salt, t.salt)}% batas garam',
  ]);
  final parts = <String>[];
  if (!whole) {
    parts.add('Label gizi terbaca: ${l.describe()}.');
    parts.add('Satu sajian memenuhi sekitar ${share(one)} harian${t.personal ? ' Anda' : ''}.');
  }
  if (n > 1) {
    parts.add('Bila satu kemasan (${_n(n)} sajian) dihabiskan sekaligus, energinya sekitar ${all.energy.round()} kkal, yaitu ${share(all)}.');
  }
  // porsi sekali makan: gula, lemak, dan garam sebaiknya tidak lebih dari sepertiga batas harian
  double cap(double? per, double target) => per == null || per == 0 ? double.infinity : (target / 3) / per;
  final maxServings = [cap(l.sugar, t.sugar), cap(l.fat, t.fat), cap(l.sodium == null ? null : one.salt, t.salt)].reduce((a, b) => a < b ? a : b);
  if (maxServings < 1) {
    parts.add('Untuk sekali makan, sebaiknya cukup setengah sajian, atau satu sajian lalu kurangi makanan asin, manis, dan berlemak hari ini.');
  } else if (maxServings < n) {
    final k = maxServings.floor();
    parts.add('Untuk sekali makan, sebaiknya cukup $k sajian${l.serving == null ? '' : ' (sekitar ${(k * l.serving!).round()} ${l.unit})'}.');
  } else if (l.servings == null) {
    // jumlah sajian tidak terbaca: tidak boleh menilai satu kemasan, hanya satu sajian
    parts.add('Satu sajian masih wajar untuk sekali makan bila makanan lain hari ini tidak tinggi gula, lemak, dan garam.');
  } else {
    parts.add('Satu kemasan masih wajar untuk sekali makan bila makanan lain hari ini tidak tinggi gula, lemak, dan garam.');
  }
  if (l.servings == null && whole) {
    parts.add(
      'Jumlah sajian per kemasan tidak terbaca, jadi angka di atas untuk satu sajian. Ketik misalnya "isinya 20 sajian" agar saya hitung satu kemasan.',
    );
  }
  final notes = <String>[
    if (l.sodium != null && all.salt > t.salt / 2) 'kelebihan garam yang terus-menerus dapat meningkatkan risiko tekanan darah tinggi',
    if (l.sugar != null && all.sugar > t.sugar / 2) 'kelebihan gula yang terus-menerus berkaitan dengan risiko diabetes tipe 2 dan gigi berlubang',
    if (l.fat != null && all.fat > t.fat / 2) 'kelebihan lemak, terutama lemak jenuh, dapat meningkatkan kolesterol dan risiko penyakit jantung',
  ];
  if (notes.isNotEmpty) parts.add('Secara umum, ${_join(notes)}.');
  if (!whole) parts.add('Bila ada angka yang terbaca keliru, ketik yang benar, misalnya "lemaknya 5 g".');
  return parts.join(' ');
}

/// Koreksi satu nilai label dari obrolan ("lemaknya 5 g", "natriumnya 290 mg", "isinya 20 sajian"), atau null.
(String, double)? labelCorrection(String text) {
  final t = text.toLowerCase().replaceAll(',', '.');
  const fields = {
    'lemak': 'lemak',
    'gula': 'gula',
    'garam': 'natrium',
    'natrium': 'natrium',
    'sodium': 'natrium',
    'protein': 'protein',
    'karbohidrat': 'karbohidrat',
    'karbo': 'karbohidrat',
    'energi': 'energi',
    'kalori': 'energi',
  };
  for (final MapEntry(key: word, value: field) in fields.entries) {
    final m = RegExp('\\b$word(?:nya)?\\b([^0-9]{0,12})$_num\\s*(g|mg|kkal|kalori)?').firstMatch(t);
    if (m == null) continue;
    // "lemak jenuh 2 g" atau "lemak trans" bukan lemak total
    if (word == 'lemak' && RegExp(r'jenuh|trans').hasMatch(m[1]!)) continue;
    final v = double.parse(m[2]!);
    // "garamnya 1 g" berarti gram garam; label menulis natrium dalam miligram (1 g garam sekitar 400 mg natrium)
    if (word == 'garam' && m[3] != 'mg' && v < 20) return ('natrium', v * 400);
    return (field, v);
  }
  final servings = RegExp('$_num\\s*(?:sajian|potong|buah|keping|biji|pcs)').firstMatch(t);
  if (servings != null && RegExp(r'\b(isi|isinya|ada|berisi|per kemasan|sebungkus)\b').hasMatch(t)) return ('sajian', double.parse(servings[1]!));
  return null;
}
