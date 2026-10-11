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
  'air': (250, 'gelas'),
  'teh manis': (250, 'gelas'),
  'teh hijau': (250, 'gelas'),
  'jus jeruk': (250, 'gelas'),
  'jus apel': (250, 'gelas'),
  'susu cokelat': (250, 'gelas'),
  'ayam': (100, 'potong'),
  'udang': (15, 'ekor'),
  'bakso': (15, 'butir'),
  'kerupuk': (10, 'keping'),
  'kurma': (8, 'buah'),
  'telur puyuh': (10, 'butir'),
  'semangka': (150, 'potong'),
  'pepaya': (150, 'potong'),
  'melon': (150, 'potong'),
  'jagung': (100, 'tongkol'),
  'kentang': (150, 'buah'),
};

const mealSlots = ['Sarapan', 'Makan siang', 'Makan malam', 'Camilan'];

String slotFor(String text, DateTime now) => slotOf(text, now).$1;

/// Waktu makan dan apakah waktunya disebut pengguna ("tadi pagi", "jam 3 sore"); bila tidak, dari jam saat ini.
(String, bool) slotOf(String text, DateTime now) {
  final t = text.toLowerCase();
  if (RegExp(r'\b(camilan|cemilan|nyemil|ngemil|snack|jajan)\b').hasMatch(t)) return ('Camilan', true);
  final at = RegExp(r'\b(?:jam|pukul) (\d{1,2})(?:[.:]\d{2})?(?: (pagi|siang|sore|malam))?\b').firstMatch(t);
  if (at != null) {
    var h = int.parse(at[1]!) % 24;
    if (h < 12 && (at[2] == 'sore' || at[2] == 'malam' || (at[2] == 'siang' && h < 6))) h += 12;
    return (_slotAt(h), true);
  }
  if (RegExp(r'\b(sarapan|pagi)\b').hasMatch(t)) return ('Sarapan', true);
  if (RegExp(r'\b(siang)\b').hasMatch(t)) return ('Makan siang', true);
  // minum atau ngemil sore hari tergolong camilan; "makan sore" dan malam adalah makan malam
  if (RegExp(r'\b(makan sore|malam)\b').hasMatch(t)) return ('Makan malam', true);
  if (RegExp(r'\b(sore)\b').hasMatch(t)) return ('Camilan', true);
  return (_slotAt(now.hour), false);
}

String _slotAt(int h) => h < 10 ? 'Sarapan' : (h < 15 ? 'Makan siang' : (h < 17 ? 'Camilan' : (h < 21 ? 'Makan malam' : 'Camilan')));

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
  final energy =
      'Energi hari ini sekitar ${total.energy.round()} dari ${t.energy.round()} kkal'
      '${total.energy > t.energy ? ', sudah melewati kebutuhan harian.' : '.'}';
  if (over.isNotEmpty) {
    return '$energy ${_cap(_join(over))} sudah melewati batas harian, jadi sisa hari ini sebaiknya pilih makanan rendah ${_join(over)}.';
  }
  if (near.isNotEmpty) return '$energy ${_cap(_join(near))} sudah mendekati batas harian.';
  return '$energy Gula, lemak, dan garam masih dalam batas aman.';
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
String _join(List<String> xs) => xs.length <= 1 ? xs.join() : '${xs.sublist(0, xs.length - 1).join(', ')} dan ${xs.last}';

const _numberWords = {
  'satu': 1.0,
  'se': 1.0,
  'dua': 2.0,
  'tiga': 3.0,
  'empat': 4.0,
  'lima': 5.0,
  'enam': 6.0,
  'tujuh': 7.0,
  'delapan': 8.0,
  'sembilan': 9.0,
  'sepuluh': 10.0,
  'setengah': .5,
  'separuh': .5,
};
const _countWord = r'\d+(?:[.,]\d+)?|satu|dua|tiga|empat|lima|enam|tujuh|delapan|sembilan|sepuluh|setengah|separuh';
const _units =
    'bungkus|piring|porsi|mangkuk|mangkok|potong|butir|buah|gelas|cangkir|botol|kotak|sachet|lembar|kaleng|batang|keping|cup|biji|tusuk|sendok|ekor|tongkol';

/// Jumlah yang disebut dalam teks: "200 gram", "2 piring", "setengah gelas", atau bentuk "se-" ("sepiring", "sebutir").
final _quantity = RegExp('(?:\\b($_countWord)\\s*(gram|gr|g|ml|$_units)|\\bse($_units))\\b');

/// Angka tanpa satuan. Jam, lama waktu, berat badan, dan sejenisnya bukan jumlah makanan.
final _bareCount = RegExp(
  '(?<!\\b(?:jam|pukul|ke|tanggal|nomor|no) )\\b($_countWord)\\b(?!\\s*(?:gram|gr|g|ml|$_units|jam|menit|detik|kali|hari|minggu|bulan|tahun|kg|kilo|cm|persen|kkal|kalori)\\b)',
);

typedef _Qty = ({int start, int end, double count, String unit});

double _count(String w) => _numberWords[w] ?? double.tryParse(w.replaceAll(',', '.')) ?? 1;

List<_Qty> _quantities(String t) => [
  for (final m in _quantity.allMatches(t)) (start: m.start, end: m.end, count: m[3] != null ? 1.0 : _count(m[1]!), unit: m[2] ?? m[3]!),
];

/// Angka tanpa satuan yang tidak menjadi bagian dari jumlah bersatuan.
List<_Qty> _bareCounts(String t, List<_Qty> withUnit) => [
  for (final m in _bareCount.allMatches(t))
    if (!withUnit.any((q) => m.start < q.end && q.start < m.end)) (start: m.start, end: m.end, count: _count(m[1]!), unit: ''),
];

(double, String) _portion(Food food, double count, String unit) {
  if (const {'gram', 'gr', 'g', 'ml'}.contains(unit)) return (count, '${count.round()} g');
  final (grams, label) = food.portion;
  final countText = count == .5 ? 'setengah' : (count == count.roundToDouble() ? '${count.round()}' : '$count');
  return (grams * count, label.contains('100 g') ? '${(grams * count).round()} g' : '$countText $label');
}

/// Teks yang dirapikan untuk pencocokan nama: huruf kecil, tanda baca menjadi spasi kecuali koma atau titik di antara
/// angka ("1,5 piring").
String mealText(String text) =>
    ' ${text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9.,\s-]'), ' ').replaceAll(RegExp(r'(?<!\d)[.,]|[.,](?!\d)'), ' ').replaceAll(RegExp(r'\s+'), ' ')} ';

/// Satu makanan dalam pesan: data gizinya, berat dalam gram, sebutan porsinya, dan nama seperti yang ditulis
/// pengguna bila berbeda ("tempe goreng" yang dihitung sebagai tempe).
typedef MealItem = ({Food food, double grams, String portion, String said});

/// Isi satu pesan makan: makanan yang dikenali dan nama hidangan yang belum ada di daftar gizi ("sate ayam").
typedef Meal = ({List<MealItem> items, List<String> unknown});

// cara masak yang ditulis setelah nama bahan; bahannya tetap dihitung, dengan catatan bahwa angkanya perkiraan
const _methods = {'bakar', 'panggang', 'geprek', 'penyet', 'rebus', 'kukus', 'balado', 'rica', 'kecap', 'krispi', 'crispy', 'tumis', 'goreng'};

// hidangan umum yang belum ada di daftar gizi dan namanya memuat nama bahan lain ("mie ayam" bukan mi ditambah ayam)
final _dishes = RegExp(
  r' ((?:mie|mi) (?:ayam|goreng|rebus|kuah|bakso)|(?:kopi|teh) susu|nasi (?:kuning|campur|padang|pecel|rames|bakar|kucing)|'
  r'ayam (?:geprek|penyet|katsu|teriyaki)|telur balado|tahu (?:isi|telur)|kentang balado) ',
);

/// Nama hidangan umum yang disebut dalam teks tetapi belum ada di daftar gizi ("kopi susu", "mie ayam").
List<String> unknownDishes(String text) => [for (final m in _dishes.allMatches(mealText(text))) m[1]!];

// kata yang boleh berada tepat sebelum nama makanan tanpa membentuk nama hidangan lain
final _beforeFood = RegExp(
  r'^(makan|minum|sarapan|ngemil|nyemil|mengonsumsi|menghabiskan|menyantap|catat|catatkan|habis|saya|aku|gue|gw|kami|kita|tadi|'
  r'barusan|baru|sudah|pagi|siang|sore|malam|ini|itu|hari|juga|lagi|sih|dong|ya|kok|aja|saja|cuma|hanya|dan|sama|serta|plus|atau|'
  r'dengan|pakai|lalu|terus|kemudian|tambah|ditambah|sedikit|banyak|sekitar|kira|tolong|coba|buat|untuk|sebelum|setelah|sesudah|'
  r'sambil|jam|pukul|porsi|lauk|camilan|cemilan|snack|minuman|makanan)$',
);

/// Semua makanan yang disebut dalam satu pesan beserta porsinya, berurutan seperti dalam teks ("nasi 1 piring dan
/// 2 butir telur"). Nama terpanjang didahulukan ("ayam goreng" bukan "ayam"). Setiap jumlah diberikan ke makanan yang
/// berdampingan dengannya; bila jumlah itu diapit dua makanan, satuannya yang menentukan (piring untuk nasi, butir untuk
/// telur), lalu pola kalimatnya (jumlah sebelum atau sesudah nama makanan). Bahan yang menjadi bagian nama hidangan
/// lain ("ayam" pada "sate ayam", "alpukat" pada "jus alpukat") tidak dihitung sebagai bahan itu.
Meal parseMeal(String text, List<Food> foods) {
  final names = [
    for (final f in foods)
      for (final n in f.names) (n.toLowerCase(), f),
  ]..sort((a, b) => b.$1.length.compareTo(a.$1.length));
  final t = fixNameTypos(mealText(text), [for (final (n, _) in names) n]);
  var found = <({int start, int end, Food food, String said})>[];
  for (final (n, f) in names) {
    for (var i = t.indexOf(' $n '); i >= 0; i = t.indexOf(' $n ', i + 1)) {
      final start = i + 1, end = i + 1 + n.length;
      if (found.any((x) => start < x.end && x.start < end)) continue;
      if (found.any((x) => x.food == f)) break;
      found.add((start: start, end: end, food: f, said: n));
    }
  }
  found.sort((a, b) => a.start.compareTo(b.start));
  String wordBefore(int i) => RegExp(r'(\S+)\s*$').firstMatch(t.substring(0, i))?[1] ?? '';
  String wordAfter(int i) => RegExp(r'^\s*(\S+)').firstMatch(t.substring(i))?[1] ?? '';
  bool isCount(String w) => RegExp('^($_countWord|gram|gr|g|ml|$_units|se($_units))\$').hasMatch(w);
  final unknown = <String>[];
  final unknownSpans = <({int start, int end})>[];
  for (final m in _dishes.allMatches(t)) {
    unknown.add(t.substring(m.start + 1, m.end - 1));
    unknownSpans.add((start: m.start + 1, end: m.end - 1));
  }
  final kept = <({int start, int end, Food food, String said})>[];
  for (final f in found) {
    if (unknownSpans.any((m) => f.start < m.end && m.start < f.end)) continue;
    final before = wordBefore(f.start), after = wordAfter(f.end);
    final besideFood = found.any((o) => o != f && o.end < f.start && t.substring(o.end, f.start).trim().isEmpty);
    if (before.length >= 3 && !_beforeFood.hasMatch(before) && !isCount(before) && !besideFood) {
      // "sate ayam", "jus alpukat": nama hidangan lain yang belum ada di daftar gizi
      final withMethod = _methods.contains(after);
      unknown.add('$before ${f.said}${withMethod ? ' $after' : ''}');
      unknownSpans.add((start: f.start - before.length - 1, end: withMethod ? f.end + 1 + after.length : f.end));
      continue;
    }
    final method = _methods.contains(after) && !f.said.endsWith(after) ? after : null;
    kept.add(method == null ? f : (start: f.start, end: f.end + 1 + method.length, food: f.food, said: '${f.said} $method'));
  }
  found = kept;
  if (found.isEmpty) return (items: const <MealItem>[], unknown: unknown);
  MealItem item(({int start, int end, Food food, String said}) f, (double, String) p) =>
      (food: f.food, grams: p.$1, portion: p.$2, said: f.said == f.food.name || f.food.names.contains(f.said) ? f.food.name : f.said);
  bool touching(int a, int b) => a <= b && t.substring(a, b).trim().isEmpty;
  // jumlah milik hidangan yang belum dikenal ("sate ayam 10 tusuk") tidak boleh berpindah ke makanan lain
  bool ownedByUnknown(_Qty q) => unknownSpans.any((u) => touching(u.end, q.start) || touching(q.end, u.start));
  final all = _quantities(t);
  final withUnit = [
    for (final q in all)
      if (!ownedByUnknown(q)) q,
  ];
  // angka tanpa satuan hanya berarti jumlah untuk makanan yang punya satuan alami ("2 telur", "ayam goreng 1"); untuk
  // makanan yang porsinya 100 g, "udang 5" bukan 500 g
  bool natural(({int start, int end, Food food, String said}) f) => !f.food.portion.$2.contains('100 g');
  final bare = [
    for (final q in _bareCounts(t, all))
      if (!ownedByUnknown(q)) q,
  ];
  if (found.length == 1) {
    // satu makanan: jumlah bersatuan di mana pun dalam kalimat, atau angka tanpa satuan yang menempel pada namanya
    final f = found.single;
    final q =
        withUnit.where((q) => const {'gram', 'gr', 'g', 'ml'}.contains(q.unit)).firstOrNull ??
        withUnit.firstOrNull ??
        bare.where((q) => natural(f) && (touching(q.end, f.start) || touching(f.end, q.start))).firstOrNull;
    return (items: [item(f, q == null ? _portion(f.food, 1, '') : _portion(f.food, q.count, q.unit))], unknown: unknown);
  }
  final qs = [
    ...withUnit,
    for (final q in bare)
      if (found.any((f) => natural(f) && (touching(q.end, f.start) || touching(f.end, q.start)))) q,
  ]..sort((a, b) => a.start.compareTo(b.start));
  final prefixStyle = qs.any((q) => touching(q.end, found.first.start));
  final assigned = <Food, _Qty>{};
  for (final q in qs) {
    final after = found.where((f) => touching(f.end, q.start)).firstOrNull; // "nasi 2 piring"
    final before = found.where((f) => touching(q.end, f.start)).firstOrNull; // "2 piring nasi"
    final options = [?after, ?before].where((f) => !assigned.containsKey(f.food)).toList();
    if (options.isEmpty) continue;
    final byUnit = q.unit.isEmpty
        ? const <({int start, int end, Food food, String said})>[]
        : options.where((f) => f.food.portion.$2.contains(q.unit)).toList();
    final pick = byUnit.length == 1
        ? byUnit.single
        : options.length == 1
        ? options.single
        : (prefixStyle ? before! : after!);
    assigned[pick.food] = q;
  }
  return (
    items: [
      for (final f in found)
        item(f, switch (assigned[f.food]) {
          final q? => _portion(f.food, q.count, q.unit),
          null => _portion(f.food, 1, ''),
        }),
    ],
    unknown: unknown,
  );
}

/// Kata kedua nama makanan yang salah ketik satu huruf diperbaiki bila kata pertamanya cocok ("ayam goren" menjadi
/// "ayam goreng"). Hanya kata kedua yang dicek, supaya kata biasa seperti "udah" tidak berubah menjadi "udang".
String fixNameTypos(String t, Iterable<String> names) {
  var out = t;
  for (final n in names) {
    final words = n.split(' ');
    if (words.length < 2 || words[1].length < 4 || out.contains(' $n ')) continue;
    final m = RegExp(' ${RegExp.escape(words[0])} ([a-z]+) ').firstMatch(out);
    if (m != null && m[1] != words[1] && _oneEdit(m[1]!, words[1])) {
      out = out.replaceRange(m.start, m.end, ' ${words[0]} ${words[1]} ');
    }
  }
  return out;
}

/// Dua kata berbeda tepat satu huruf (sisip, hapus, atau ganti).
bool _oneEdit(String a, String b) {
  if ((a.length - b.length).abs() > 1 || a == b) return false;
  var i = 0, j = 0, edits = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      i++;
      j++;
      continue;
    }
    if (++edits > 1) return false;
    if (a.length > b.length) {
      i++;
    } else if (b.length > a.length) {
      j++;
    } else {
      i++;
      j++;
    }
  }
  return edits + (a.length - i) + (b.length - j) == 1;
}
