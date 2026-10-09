/// Catatan makan harian: makanan dari daftar gizi USDA (per 100 g) dengan porsi perkiraan, dijumlahkan per hari dan
/// dibandingkan dengan kebutuhan atau batas harian pengguna.
library;

import 'body.dart';

class Nutrients {
  const Nutrients({this.energy = 0, this.protein = 0, this.fat = 0, this.carbs = 0, this.sugar = 0, this.sodium = 0});
  final double energy, protein, fat, carbs, sugar; // kkal dan gram
  final double sodium; // miligram
  double get salt => sodium * 2.5 / 1000; // gram garam

  Nutrients operator +(Nutrients o) => Nutrients(
    energy: energy + o.energy,
    protein: protein + o.protein,
    fat: fat + o.fat,
    carbs: carbs + o.carbs,
    sugar: sugar + o.sugar,
    sodium: sodium + o.sodium,
  );

  Nutrients scale(double f) =>
      Nutrients(energy: energy * f, protein: protein * f, fat: fat * f, carbs: carbs * f, sugar: sugar * f, sodium: sodium * f);

  Map<String, double> toJson() => {'e': energy, 'p': protein, 'f': fat, 'c': carbs, 's': sugar, 'na': sodium};

  static Nutrients fromJson(Map<String, dynamic> j) => Nutrients(
    energy: (j['e'] as num).toDouble(),
    protein: (j['p'] as num).toDouble(),
    fat: (j['f'] as num).toDouble(),
    carbs: (j['c'] as num).toDouble(),
    sugar: (j['s'] as num).toDouble(),
    sodium: (j['na'] as num).toDouble(),
  );

  /// Nilai per 100 g dari teks fakta gizi ("energi 440 kkal, protein 10,2 g, ..., natrium 1855 mg").
  static Nutrients? parse(String text) {
    double grab(String name) {
      final m = RegExp('$name ([\\d.,]+) (?:kkal|g|mg)').firstMatch(text);
      return m == null ? 0 : double.tryParse(m[1]!.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    }

    final e = grab('energi');
    if (e == 0 && !text.contains('energi 0')) return null;
    return Nutrients(
      energy: e,
      protein: grab('protein'),
      fat: grab('lemak'),
      carbs: grab('karbohidrat'),
      sugar: grab('gula'),
      sodium: grab('natrium'),
    );
  }
}

/// Satu makanan yang bisa dicatat, dengan nilai gizi per 100 g.
class Food {
  const Food(this.name, this.names, this.per100);
  final String name;
  final List<String> names;
  final Nutrients per100;

  /// Porsi umum dalam gram dan sebutannya; perkiraan untuk satu satuan.
  (double, String) get portion => portions[name] ?? (100, 'porsi (100 g)');
}

/// Porsi umum (gram per satuan). Angka perkiraan, dipakai bila pengguna tidak menyebut gram.
const portions = <String, (double, String)>{
  'mi instan': (85, 'bungkus'),
  'nasi': (150, 'piring'),
  'nasi goreng': (250, 'piring'),
  'telur': (55, 'butir'),
  'telur bebek': (70, 'butir'),
  'roti': (30, 'lembar'),
  'roti tawar': (30, 'lembar'),
  'pisang': (100, 'buah'),
  'apel': (150, 'buah'),
  'jeruk': (130, 'buah'),
  'mangga': (200, 'buah'),
  'susu': (250, 'gelas'),
  'susu kedelai': (250, 'gelas'),
  'teh': (250, 'gelas'),
  'kopi': (200, 'gelas'),
  'minuman bersoda': (330, 'kaleng'),
  'keripik kentang': (30, 'bungkus kecil'),
  'nugget ayam': (20, 'potong'),
  'sosis sapi': (45, 'batang'),
  'sosis': (45, 'batang'),
  'tempe': (50, 'potong'),
  'tahu': (60, 'potong'),
  'tahu goreng': (60, 'potong'),
  'ayam goreng': (100, 'potong'),
  'donat': (60, 'buah'),
  'kue kering cokelat': (15, 'keping'),
  'biskuit krekers': (10, 'keping'),
  'cokelat susu': (40, 'batang'),
  'es krim': (70, 'cup'),
  'hamburger': (220, 'buah'),
  'pizza': (110, 'potong'),
  'yoghurt': (150, 'cup'),
  'kentang goreng': (120, 'porsi'),
  'air kelapa': (250, 'gelas'),
};

const mealSlots = ['Sarapan', 'Makan siang', 'Makan malam', 'Camilan'];

String slotFor(String text, DateTime now) {
  final t = text.toLowerCase();
  if (RegExp(r'\b(camilan|cemilan|nyemil|ngemil|snack|jajan)\b').hasMatch(t)) return 'Camilan';
  if (RegExp(r'\b(sarapan|pagi)\b').hasMatch(t)) return 'Sarapan';
  if (RegExp(r'\b(siang)\b').hasMatch(t)) return 'Makan siang';
  if (RegExp(r'\b(sore|malam)\b').hasMatch(t)) return 'Makan malam';
  final h = now.hour;
  return h < 10 ? 'Sarapan' : (h < 15 ? 'Makan siang' : (h < 21 ? 'Makan malam' : 'Camilan'));
}

class IntakeEntry {
  IntakeEntry(this.time, this.slot, this.food, this.grams, this.nutrients);
  final DateTime time;
  final String slot;
  final String food;
  final double grams;
  final Nutrients nutrients;

  Map<String, dynamic> toJson() => {'t': time.toIso8601String(), 'slot': slot, 'food': food, 'g': grams, 'n': nutrients.toJson()};

  static IntakeEntry fromJson(Map<String, dynamic> j) => IntakeEntry(
    DateTime.parse(j['t'] as String),
    j['slot'] as String,
    j['food'] as String,
    (j['g'] as num).toDouble(),
    Nutrients.fromJson(j['n'] as Map<String, dynamic>),
  );
}

/// Target harian untuk perbandingan: dari kalkulator tubuh bila ada, selain itu angka umum dewasa (AKG 2019 rata-rata
/// sekitar 2.150 kkal dan 60 g protein; batas gula 50 g, lemak 67 g, garam 5 g).
class Targets {
  const Targets(this.energy, this.protein, this.fat, this.sugar, this.salt, {this.personal = false});
  final double energy, protein, fat, sugar, salt;
  final bool personal;

  static Targets of(DailyNeeds? n) => n == null
      ? const Targets(2150, 60, 67, 50, 5)
      : Targets(n.energy.toDouble(), n.protein.toDouble(), n.fat.toDouble(), n.sugar.toDouble(), n.salt.toDouble(), personal: true);
}

/// Status satu zat gizi hari ini: aman, mendekati batas, atau melebihi.
enum Level { safe, near, over }

Level levelOf(double value, double target) => value > target ? Level.over : (value >= target * .8 ? Level.near : Level.safe);

/// Ringkasan satu kalimat untuk hari ini, menyebut zat yang mendekati atau melewati batas.
String daySummary(Nutrients total, Targets t) {
  final over = [
    if (levelOf(total.sugar, t.sugar) == Level.over) 'gula',
    if (levelOf(total.fat, t.fat) == Level.over) 'lemak',
    if (levelOf(total.salt, t.salt) == Level.over) 'garam',
  ];
  final near = [
    if (levelOf(total.sugar, t.sugar) == Level.near) 'gula',
    if (levelOf(total.fat, t.fat) == Level.near) 'lemak',
    if (levelOf(total.salt, t.salt) == Level.near) 'garam',
  ];
  final energy = 'Energi hari ini sekitar ${total.energy.round()} dari ${t.energy.round()} kkal.';
  if (over.isNotEmpty) {
    return '$energy ${_cap(_join(over))} sudah melewati batas harian, jadi sisa hari ini sebaiknya pilih makanan rendah ${_join(over)}.';
  }
  if (near.isNotEmpty) return '$energy ${_cap(_join(near))} sudah mendekati batas harian.';
  return '$energy Gula, lemak, dan garam masih dalam batas aman.';
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
String _join(List<String> xs) => xs.length <= 1 ? xs.join() : '${xs.sublist(0, xs.length - 1).join(', ')} dan ${xs.last}';

const _numberWords = {'satu': 1.0, 'se': 1.0, 'dua': 2.0, 'tiga': 3.0, 'empat': 4.0, 'setengah': .5, 'separuh': .5};

/// Porsi dari teks: gram yang disebut langsung ("200 gram"), atau jumlah satuan ("2 bungkus", "setengah piring") dikali
/// porsi umum makanan itu. Bila tidak disebut, satu porsi umum.
(double, String) gramsFrom(String text, Food food) {
  final t = text.toLowerCase();
  final g = RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:gram|gr|g|ml)\b').firstMatch(t);
  if (g != null) {
    final v = double.parse(g[1]!.replaceAll(',', '.'));
    return (v, '${v.round()} g');
  }
  final (unit, label) = food.portion;
  final n = RegExp(
    r'(\d+(?:[.,]\d+)?|satu|dua|tiga|empat|setengah|separuh)\s*(?:bungkus|piring|porsi|mangkuk|potong|butir|buah|gelas|lembar|kaleng|batang|keping|cup|biji)',
  ).firstMatch(t);
  final count = n == null ? 1.0 : (_numberWords[n[1]] ?? double.tryParse(n[1]!.replaceAll(',', '.')) ?? 1);
  final countText = count == .5 ? 'setengah' : (count == count.roundToDouble() ? '${count.round()}' : '$count');
  return (unit * count, label.contains('100 g') ? '${(unit * count).round()} g' : '$countText $label');
}
