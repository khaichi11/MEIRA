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

/// Di bawah skor ini resep tergolong berat: digoreng dalam minyak banyak, bersantan kental, atau banyak gula.
const heavyBelow = .4;

bool _deepFried(Recipe r) => r.items.any((i) => i.key == 'cooking_oil' && i.amount.contains('secukupnya')) || _fried.hasMatch(r.steps.join(' '));

/// Skor 0 sampai 1: tinggi untuk resep yang banyak sayur atau buah, berprotein rendah lemak, dan dimasak tanpa banyak
/// minyak; rendah untuk gorengan, santan kental, dan yang banyak gula.
double healthScore(Recipe r) {
  final keys = {for (final i in r.items) i.key};
  final plants = keys.where((k) => const {'sayur', 'buah'}.contains(ingredients[k]?.category)).length;
  final steps = r.steps.join(' ');
  var s = 0.35;
  s += .08 * plants.clamp(0, 4);
  if (keys.intersection(_lean).isNotEmpty) s += .1;
  if (_gentle.hasMatch(steps)) s += .1;
  if (r.tags.contains('sehat')) s += .1;
  if (_deepFried(r)) s -= .25;
  s -= .1 * keys.intersection(_rich).length;
  s -= .08 * keys.intersection(_sweet).length;
  if (r.tags.contains('manis')) s -= .05;
  return s.clamp(0.0, 1.0);
}

bool isHealthy(Recipe r) => healthScore(r) >= .6;

/// Satu kalimat saran agar resep lebih ringan, atau kosong bila resepnya sudah tergolong sehat.
String healthTip(Recipe r) {
  final keys = {for (final i in r.items) i.key};
  if (_deepFried(r)) {
    return 'Agar lebih ringan, masak dengan sedikit minyak di teflon atau panggang, alih-alih digoreng dalam minyak banyak.';
  }
  if (keys.contains('coconut_milk')) return 'Agar lebih ringan, pakai santan encer atau kurangi jumlahnya.';
  if (keys.intersection(_sweet).isNotEmpty) {
    return 'Agar lebih ringan, kurangi gula atau kecap manis; anjuran Kementerian Kesehatan paling banyak 50 gram gula sehari.';
  }
  if (keys.intersection(_rich).isNotEmpty) return 'Agar lebih ringan, kurangi bahan berlemak dan tambahkan sayur.';
  return '';
}

String _list(List<String> xs) => switch (xs.length) {
  0 || 1 => xs.join(),
  2 => '${xs[0]} dan ${xs[1]}',
  _ => '${xs.sublist(0, xs.length - 1).join(', ')}, dan ${xs.last}',
};

/// Cara memasak yang membuat resep ringan, menurut langkah resepnya.
String? _gentleWay(Recipe r) {
  final steps = r.steps.join(' ').toLowerCase();
  for (final (word, phrase) in const [
    ('kukus', 'dikukus'),
    ('rebus', 'direbus'),
    ('panggang', 'dipanggang'),
    ('bakar', 'dibakar'),
    ('tanpa dimasak', 'tanpa dimasak'),
    ('blender', 'cukup diblender'),
  ]) {
    if (steps.contains(word)) return phrase;
  }
  return null;
}

/// Alasan singkat sebuah resep tergolong ringan, misalnya "banyak sayur atau buah dan dikukus".
String lightReasons(Recipe r) {
  final keys = {for (final i in r.items) i.key};
  final plants = keys.where((k) => const {'sayur', 'buah'}.contains(ingredients[k]?.category)).length;
  final way = _gentleWay(r);
  return _list([
    if (plants >= 2) 'banyak sayur atau buah',
    if (keys.intersection(_lean).isNotEmpty) 'memakai protein rendah lemak',
    if (way != null) way else if (!_deepFried(r)) 'tidak digoreng dalam minyak banyak',
  ]);
}

/// Hal yang membuat resep tergolong berat, untuk dibandingkan dengan pilihan yang lebih ringan.
String heavyReason(Recipe r) {
  final keys = {for (final i in r.items) i.key};
  if (_deepFried(r)) return 'digoreng dalam minyak banyak';
  if (keys.contains('coconut_milk')) return 'memakai santan';
  if (keys.intersection(_sweet).isNotEmpty) return 'memakai gula atau kecap manis';
  if (keys.intersection(_rich).isNotEmpty) return 'lebih berlemak';
  return 'lebih berat';
}

/// Catatan mode "Enak & sehat" untuk resep yang disarankan. [tastier] adalah resep yang akan terpilih tanpa mode ini;
/// bila berbeda dan lebih berat, keduanya disebut supaya pengguna melihat apa yang berubah.
String healthNote(Recipe chosen, {Recipe? tastier}) {
  final out = <String>[];
  if (healthScore(chosen) < heavyBelow) {
    // tidak ada pilihan yang lebih ringan untuk bahan ini; jangan sampai resep berat disebut sebagai pilihan sehat
    out.add('Buku resep belum punya pilihan yang lebih ringan untuk bahan ini.');
  } else if (tastier != null && tastier.id != chosen.id && healthScore(tastier) < healthScore(chosen)) {
    out.add('Mode Enak & sehat aktif, jadi saya mendahulukan ${chosen.name} daripada ${tastier.name} yang ${heavyReason(tastier)}.');
  }
  final why = isHealthy(chosen) ? lightReasons(chosen) : '';
  if (why.isNotEmpty) {
    out.add('${chosen.name} tergolong ringan karena $why.');
  } else {
    final tip = healthTip(chosen);
    if (tip.isNotEmpty) out.add(tip);
  }
  return out.join(' ');
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
