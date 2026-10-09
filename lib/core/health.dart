/// Penilaian resep untuk pola makan sehat dan rencana makan harian.
///
/// Pedomannya umum dan berasal dari anjuran Kementerian Kesehatan RI: Isi Piringku (separuh piring sayur dan buah) dan
/// batas harian gula 50 g, garam 5 g (sekitar 1 sendok teh), serta lemak 67 g (Permenkes No. 30 Tahun 2013). Nilai di
/// sini hanya membandingkan resep satu dengan lainnya, bukan hitungan gizi pribadi; kondisi medis seperti obesitas,
/// diabetes, atau hipertensi tetap perlu rencana dari dokter atau ahli gizi.
library;

import 'recipes.dart';
import 'vocab.dart';

const _lean = {'fish', 'chicken', 'tofu', 'tempeh', 'egg', 'shrimp', 'squid', 'clam', 'mung_bean', 'kidney_bean', 'soybean', 'quail_egg'};
const _sweet = {'sugar', 'palm_sugar', 'honey', 'chocolate', 'sweet_soy_sauce'};
const _rich = {'coconut_milk', 'butter', 'cheese', 'sausage', 'meatball', 'goat_meat'};
final _fried = RegExp(r'\bgoreng\b|digoreng|menggoreng', caseSensitive: false);
final _gentle = RegExp(r'kukus|rebus|panggang|bakar|blender|tanpa dimasak', caseSensitive: false);

/// Skor 0 sampai 1: tinggi untuk resep yang banyak sayur atau buah, berprotein rendah lemak, dan dimasak tanpa banyak
/// minyak; rendah untuk gorengan, santan kental, dan yang banyak gula.
double healthScore(Recipe r) {
  final keys = {for (final i in r.items) i.key};
  final plants = keys.where((k) => const {'sayur', 'buah'}.contains(ingredients[k]?.category)).length;
  final steps = r.steps.join(' ');
  final deepFried = r.items.any((i) => i.key == 'cooking_oil' && i.amount.contains('secukupnya')) || _fried.hasMatch(steps);
  var s = 0.35;
  s += .08 * plants.clamp(0, 4);
  if (keys.intersection(_lean).isNotEmpty) s += .1;
  if (_gentle.hasMatch(steps)) s += .1;
  if (r.tags.contains('sehat')) s += .1;
  if (deepFried) s -= .25;
  s -= .1 * keys.intersection(_rich).length;
  s -= .08 * keys.intersection(_sweet).length;
  if (r.tags.contains('manis')) s -= .05;
  return s.clamp(0.0, 1.0);
}

bool isHealthy(Recipe r) => healthScore(r) >= .6;

/// Satu kalimat saran agar resep lebih ringan, atau kosong bila resepnya sudah tergolong sehat.
String healthTip(Recipe r) {
  final keys = {for (final i in r.items) i.key};
  final steps = r.steps.join(' ');
  if (r.items.any((i) => i.key == 'cooking_oil' && i.amount.contains('secukupnya')) || _fried.hasMatch(steps)) {
    return 'Agar lebih ringan, masak dengan sedikit minyak di teflon atau panggang, alih-alih digoreng dalam minyak banyak.';
  }
  if (keys.contains('coconut_milk')) return 'Agar lebih ringan, pakai santan encer atau kurangi jumlahnya.';
  if (keys.intersection(_sweet).isNotEmpty) {
    return 'Agar lebih ringan, kurangi gula atau kecap manis; anjuran Kementerian Kesehatan paling banyak 50 gram gula sehari.';
  }
  if (keys.intersection(_rich).isNotEmpty) return 'Agar lebih ringan, kurangi bahan berlemak dan tambahkan sayur.';
  return '';
}

/// Rencana makan sehari: sarapan, makan siang, makan malam, dan camilan dari resep yang tergolong sehat. Pilihannya
/// bergilir menurut tanggal, sehingga berganti setiap hari tetapi tetap sama sepanjang hari itu. [shift] menggeser
/// pilihan satu slot ("Ganti").
List<(String, Recipe)> dailyPlan(List<Recipe> recipes, DateTime day, {Map<String, int> shift = const {}}) {
  final healthy = [...recipes.where(isHealthy)]..sort((a, b) => healthScore(b).compareTo(healthScore(a)));
  if (healthy.isEmpty) return const [];
  bool meal(Recipe r) => !r.tags.contains('minuman') && !r.tags.contains('camilan');
  final slots = <(String, bool Function(Recipe))>[
    ('Sarapan', (r) => r.tags.contains('sarapan')),
    ('Makan siang', (r) => meal(r) && !r.tags.contains('sarapan')),
    ('Makan malam', (r) => meal(r) && (r.tags.contains('berkuah') || r.minutes <= 30)),
    ('Camilan', (r) => r.tags.contains('camilan') || r.tags.contains('minuman')),
  ];
  final seed = day.year * 400 + day.month * 32 + day.day;
  final used = <String>{};
  final out = <(String, Recipe)>[];
  for (final (i, (name, test)) in slots.indexed) {
    final pool = healthy.where((r) => test(r) && !used.contains(r.id)).toList();
    final list = pool.isEmpty ? healthy.where((r) => !used.contains(r.id)).toList() : pool;
    if (list.isEmpty) continue;
    final r = list[(seed * 7 + i * 13 + (shift[name] ?? 0)) % list.length];
    used.add(r.id);
    out.add((name, r));
  }
  return out;
}
