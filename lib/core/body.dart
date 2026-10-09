/// Kalkulator tubuh: indeks massa tubuh (IMT), rentang berat badan ideal, dan perkiraan kebutuhan gizi harian.
///
/// Rumus dan batasnya:
/// - IMT = berat (kg) / tinggi (m)². Kategori Kementerian Kesehatan RI: di bawah 17 berat badan kurang tingkat berat,
///   17 sampai 18,4 berat badan kurang, 18,5 sampai 25 normal, 25,1 sampai 27 berat badan berlebih, di atas 27 obesitas.
/// - Berat badan ideal rumus Broca yang dipakai Kementerian Kesehatan: (tinggi - 100) dikurangi 10% untuk laki-laki dan
///   15% untuk perempuan; tanpa pengurangan bila tinggi laki-laki di bawah 160 cm atau perempuan di bawah 150 cm.
/// - Energi: rumus Mifflin-St Jeor dikali faktor aktivitas. Tujuan menuju berat badan ideal mengurangi 500 kkal, tetapi
///   tidak di bawah 1.200 kkal (perempuan) atau 1.500 kkal (laki-laki).
/// - Pembagian energi Pedoman Gizi Seimbang: protein 15%, lemak 25%, karbohidrat 60%. Gula paling banyak 10% energi
///   dan tidak lebih dari 50 g; lemak tidak lebih dari 67 g; garam 5 g (Permenkes No. 30 Tahun 2013).
/// Semua angka adalah perkiraan untuk orang dewasa sehat, bukan pengganti saran dokter atau ahli gizi.
library;

import 'dart:math' as math;

class BodyProfile {
  const BodyProfile({required this.heightCm, required this.weightKg, required this.age, required this.male, this.activity = 'ringan'});
  final double heightCm;
  final double weightKg;
  final int age;
  final bool male;
  final String activity; // jarang, ringan, sedang, berat

  static const activities = {
    'jarang': ('Jarang bergerak', 'Kebanyakan duduk, jarang berolahraga', 1.2),
    'ringan': ('Ringan', 'Olahraga 1 sampai 3 hari seminggu', 1.375),
    'sedang': ('Sedang', 'Olahraga 3 sampai 5 hari seminggu', 1.55),
    'berat': ('Berat', 'Olahraga hampir setiap hari atau kerja fisik', 1.725),
  };
}

class DailyNeeds {
  const DailyNeeds({
    required this.bmi,
    required this.category,
    required this.idealMin,
    required this.idealMax,
    required this.broca,
    required this.energy,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.sugar,
    required this.salt,
  });
  final double bmi;
  final String category;
  final double idealMin, idealMax, broca; // kg
  final int energy; // kkal
  final int protein, fat, carbs, sugar; // gram
  final int salt; // gram

  /// Satu baris fakta untuk model bahasa, dipakai saat pengguna bertanya apakah suatu makanan cocok untuknya.
  String get factLine =>
      'Kebutuhan harian pengguna (perkiraan): energi sekitar ${_n(energy)} kkal, protein $protein g, lemak paling banyak $fat g, '
      'gula paling banyak $sugar g, dan garam paling banyak $salt g.';
}

String bmiCategory(double bmi) => bmi < 17
    ? 'Berat badan kurang tingkat berat'
    : bmi < 18.5
    ? 'Berat badan kurang'
    : bmi <= 25
    ? 'Normal'
    : bmi <= 27
    ? 'Berat badan berlebih'
    : 'Obesitas';

DailyNeeds needsFor(BodyProfile p, {String? goal}) {
  final h = p.heightCm / 100;
  final bmi = p.weightKg / (h * h);
  final reduce = p.male ? (p.heightCm < 160 ? 0 : .10) : (p.heightCm < 150 ? 0 : .15);
  final broca = (p.heightCm - 100) * (1 - reduce);
  final bmr = 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age + (p.male ? 5 : -161);
  var energy = bmr * (BodyProfile.activities[p.activity]?.$3 ?? 1.375);
  if (goal == 'turun' && bmi > 25) energy = math.max(energy - 500, p.male ? 1500 : 1200);
  final fat = math.min(energy * .25 / 9, 67);
  final sugar = math.min(energy * .10 / 4, 50);
  return DailyNeeds(
    bmi: bmi,
    category: bmiCategory(bmi),
    idealMin: 18.5 * h * h,
    idealMax: 25 * h * h,
    broca: broca,
    energy: (energy / 10).round() * 10,
    protein: (energy * .15 / 4).round(),
    fat: fat.round(),
    carbs: (energy * .60 / 4).round(),
    sugar: sugar.round(),
    salt: 5,
  );
}

String _n(int v) => v >= 1000 ? '${v ~/ 1000}.${(v % 1000).toString().padLeft(3, '0')}' : '$v';

/// Perbandingan fakta gizi USDA (per 100 g) dengan kebutuhan harian pengguna, sebagai satu baris fakta yang sudah
/// dihitung: model kecil tidak andal berhitung, jadi persentasenya disiapkan di sini dan model cukup menyampaikannya.
String? compareWithNeeds(String title, String nutritionText, DailyNeeds n) {
  double? grab(String name) {
    final m = RegExp('$name ([\\d.,]+) (?:kkal|g|mg)').firstMatch(nutritionText);
    return m == null ? null : double.tryParse(m[1]!.replaceAll('.', '').replaceAll(',', '.'));
  }

  final energy = grab('energi');
  if (energy == null) return null;
  final protein = grab('protein'), fat = grab('lemak'), sugar = grab('gula'), sodium = grab('natrium');
  final salt = sodium == null ? null : sodium * 2.5 / 1000; // gram garam dari miligram natrium
  int pct(double? v, int target) => v == null || target == 0 ? 0 : (v / target * 100).round();
  final food = title.replaceFirst(RegExp(r'^Kandungan gizi ', caseSensitive: false), '');
  final parts = [
    '${pct(energy, n.energy)}% energi',
    if (protein != null) '${pct(protein, n.protein)}% protein',
    if (fat != null) '${pct(fat, n.fat)}% batas lemak',
    if (sugar != null) '${pct(sugar, n.sugar)}% batas gula',
    if (salt != null) '${pct(salt, n.salt)}% batas garam',
  ];
  final high = [
    if (fat != null && pct(fat, n.fat) >= 30) 'lemak',
    if (sugar != null && pct(sugar, n.sugar) >= 30) 'gula',
    if (salt != null && pct(salt, n.salt) >= 30) 'garam',
  ];
  return 'Dibandingkan kebutuhan harian pengguna, 100 gram $food memenuhi sekitar ${_join(parts)}.'
      '${high.isEmpty ? ' Kandungannya masih wajar untuk porsi sedang.' : ' Kandungan ${_join(high)}-nya tinggi untuk 100 gram, jadi porsinya sebaiknya dibatasi.'}';
}

String _join(List<String> xs) => xs.length <= 1 ? xs.join() : '${xs.sublist(0, xs.length - 1).join(', ')} dan ${xs.last}';
