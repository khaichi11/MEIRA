/// Keadaan pengguna yang disebut dalam percakapan ("saya sedang puasa", "aku diabetes") dan diingat selama sesi, supaya
/// jawaban berikutnya tidak melupakannya. Keadaan ini hanya menyesuaikan saran dan tidak dikirim ke mana pun.
library;

/// Kunci keadaan dan sebutannya dalam kalimat.
const situationNames = {
  'puasa': 'sedang berpuasa',
  'puasa_if': 'sedang menjalankan pembatasan waktu makan (intermittent fasting)',
  'diet': 'sedang diet',
  'hamil': 'sedang hamil',
  'menyusui': 'sedang menyusui',
  'diabetes': 'memiliki diabetes',
  'hipertensi': 'memiliki darah tinggi',
  'kolesterol': 'memiliki kolesterol tinggi',
  'asam_urat': 'memiliki asam urat',
  'maag': 'memiliki maag',
  'vegetarian': 'vegetarian',
};

/// Keadaan yang berkaitan dengan kesehatan; sarannya selalu disertai anjuran ke dokter atau ahli gizi.
const medicalSituations = {'hamil', 'menyusui', 'diabetes', 'hipertensi', 'kolesterol', 'asam_urat', 'maag'};

const _me = r'(?:saya|aku|gue|gw|kami|sedang|lagi|masih|lg)';

final _on = <String, RegExp>{
  'puasa': RegExp('\\b$_me\\b(?:\\s+\\w+){0,2}\\s+(?:puasa|berpuasa)\\b|\\b(?:bulan puasa|puasa ramadan|puasa ramadhan)\\b'),
  'diet': RegExp('\\b$_me\\b(?:\\s+\\w+){0,2}\\s+diet\\b|\\b(?:mau|ingin|pengen|sedang|lagi) (?:kurus|menurunkan berat|turun berat)\\b'),
  'hamil': RegExp('\\b(?:$_me|istri saya|istriku)\\b(?:\\s+\\w+){0,2}\\s+hamil\\b'),
  'menyusui': RegExp(r'\b(?:menyusui|busui)\b'),
  'diabetes': RegExp('\\b$_me\\b(?:\\s+\\w+){0,2}\\s+(?:diabetes|kencing manis|gula darah tinggi)\\b'),
  'hipertensi': RegExp('\\b$_me\\b(?:\\s+\\w+){0,2}\\s+(?:hipertensi|darah tinggi)\\b'),
  'kolesterol': RegExp('\\b$_me\\b(?:\\s+\\w+){0,2}\\s+kolesterol\\b'),
  'asam_urat': RegExp('\\b$_me\\b(?:\\s+\\w+){0,2}\\s+asam urat\\b'),
  'maag': RegExp('\\b$_me\\b(?:\\s+\\w+){0,2}\\s+(?:maag|gerd|asam lambung)\\b'),
  'vegetarian': RegExp('\\b$_me\\b(?:\\s+\\w+){0,1}\\s+(?:vegetarian|vegan)\\b|\\b(?:tidak|nggak|gak) makan daging\\b'),
};

final _off = <String, RegExp>{
  'puasa': RegExp(
    r'\b(?:sudah|udah|baru|habis) (?:buka|berbuka)\b|\b(?:tidak|nggak|gak|enggak) (?:sedang |lagi )?(?:puasa|berpuasa)\b|'
    r'\b(?:batal|selesai) puasa\b',
  ),
  'diet': RegExp(r'\b(?:berhenti|selesai|tidak lagi|sudah tidak) diet\b'),
  'hamil': RegExp(r'\b(?:sudah melahirkan|tidak hamil)\b'),
  'vegetarian': RegExp(r'\b(?:bukan|tidak lagi) (?:vegetarian|vegan)\b'),
};

// pengaturan pembatasan waktu makan memakai kata "puasa" juga, tetapi itu perintah fitur, bukan keadaan hari ini
final _plan = RegExp(r'\b(?:atur|aktifkan|matikan|hentikan|nonaktifkan|mulai jam)\b.*\b(?:puasa|jendela makan)\b|\d+\s*[:/]\s*\d+\s+mulai');

// puasa tidak selalu Ramadan: "intermittent fasting" atau jendela makan berarti pembatasan waktu makan
final _intermittent = RegExp(r'\b(?:intermittent|fasting|puasa berselang|jendela makan|pembatasan waktu makan|if|16 ?jam|14 ?jam|18 ?jam)\b');
final _ramadan = RegExp(r'\b(?:ramadan|ramadhan|sahur|buka puasa|berbuka|takjil|tarawih|lebaran)\b');

/// Perbarui [ctx] dari pesan [text]. Mengembalikan keadaan yang baru disebut dan yang baru berakhir. [hasPlan] berarti
/// pengguna sudah mengatur jendela makan di aplikasi, sehingga "saya sedang puasa" tanpa kata Ramadan lebih mungkin
/// berarti pembatasan waktu makan.
({Set<String> added, Set<String> removed}) updateSituation(Set<String> ctx, String text, {bool hasPlan = false}) {
  final t = ' ${text.toLowerCase()} ';
  final added = <String>{}, removed = <String>{};
  for (final MapEntry(:key, :value) in _off.entries) {
    if (!value.hasMatch(t)) continue;
    for (final k in key == 'puasa' ? const ['puasa', 'puasa_if'] : [key]) {
      if (ctx.remove(k)) removed.add(k);
    }
  }
  for (final MapEntry(:key, :value) in _on.entries) {
    if (key == 'puasa' && _plan.hasMatch(t)) continue;
    if (removed.contains(key) || removed.contains('puasa_if') && key == 'puasa' || (_off[key]?.hasMatch(t) ?? false)) continue;
    if (!value.hasMatch(t) && !(key == 'puasa' && RegExp(r'\b(?:sedang|lagi|saya|aku) (?:intermittent fasting|if)\b').hasMatch(t))) continue;
    var k = key;
    if (key == 'puasa') {
      k = _intermittent.hasMatch(t) || (hasPlan && !_ramadan.hasMatch(t)) ? 'puasa_if' : 'puasa';
      ctx.remove(k == 'puasa' ? 'puasa_if' : 'puasa');
    }
    if (ctx.add(k)) added.add(k);
  }
  return (added: added, removed: removed);
}

/// Pesan yang hanya memberi tahu keadaan ("saya sedang puasa", "aku lagi diet nih"), tanpa pertanyaan atau permintaan.
bool onlySituation(String text) {
  final t = text.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), ' ').trim();
  if (text.contains('?') ||
      RegExp(r'\b(apa|apakah|kenapa|bagaimana|gimana|boleh|bisa|berapa|enaknya|sebaiknya|mau|resep|makan|minum)\b').hasMatch(t)) {
    return false;
  }
  return t.split(RegExp(r'\s+')).length <= 7;
}

/// Balasan singkat yang menegaskan keadaan yang diingat atau yang sudah berakhir.
String situationAck(Set<String> added, Set<String> removed) {
  if (added.isEmpty) {
    if (removed.contains('puasa') || removed.contains('puasa_if')) {
      return 'Baik, berarti sekarang Anda sudah tidak berpuasa. Saran makanan dari saya kembali seperti biasa.';
    }
    return 'Baik, saya catat Anda ${removed.map((k) => 'tidak lagi ${situationNames[k]!.replaceFirst('sedang ', '')}').join(' dan ')}.';
  }
  if (added.length == 1) {
    final k = added.first;
    if (k == 'puasa') return 'Baik, semoga puasanya lancar. Saran makanan dari saya akan saya sesuaikan untuk sahur dan berbuka.';
    if (k == 'puasa_if') {
      return 'Baik, saran makanan dari saya akan saya sesuaikan dengan jendela makan Anda. Di luar jendela makan, air putih, '
          'teh, atau kopi tanpa gula tidak menambah energi.';
    }
    if (k == 'diet') return 'Baik, selama Anda diet saya akan mendahulukan pilihan yang lebih ringan dan menyebutkan porsinya.';
    if (k == 'vegetarian') return 'Baik, saya ingat Anda vegetarian, jadi saran makanan dari saya tanpa daging.';
    if (medicalSituations.contains(k)) {
      return 'Terima kasih sudah memberi tahu bahwa Anda ${situationNames[k]}. Saran makanan dari saya bersifat umum, jadi '
          'tetap ikuti anjuran dokter atau ahli gizi Anda.';
    }
  }
  final said = added.map((k) => situationNames[k]!).join(' dan ');
  final why = added.any(medicalSituations.contains)
      ? ' Saran makanan dari saya bersifat umum, jadi tetap ikuti anjuran dokter atau ahli gizi Anda.'
      : ' Saya akan memperhitungkannya saat menyarankan makanan.';
  return 'Baik, saya ingat Anda $said.$why';
}

/// Satu baris fakta untuk model bahasa, atau null bila tidak ada keadaan yang diingat.
String? situationFact(Set<String> ctx) =>
    ctx.isEmpty ? null : 'Keadaan pengguna yang perlu diingat: ${[for (final k in ctx) situationNames[k]].join(', ')}.';

/// Kalimat tambahan untuk jawaban gizi sesuai keadaan pengguna, atau kosong.
String situationAdvice(Set<String> ctx, {bool medicalNoted = false}) => [
  if (ctx.contains('puasa')) 'Karena Anda sedang berpuasa, makan atau minum ini saat sahur atau berbuka.',
  if (ctx.contains('puasa_if')) 'Karena Anda menjalankan pembatasan waktu makan, makan ini di dalam jendela makan.',
  if (ctx.contains('diet')) 'Karena Anda sedang diet, perhatikan porsinya.',
  if (!medicalNoted && ctx.any(medicalSituations.contains)) 'Untuk kondisi Anda, ikuti juga saran dokter atau ahli gizi.',
].join(' ');

/// Kata pencarian tambahan dari keadaan pengguna: "enaknya buka pakai apa" saat berpuasa berarti buka puasa.
String withSituation(String text, Set<String> ctx) {
  final t = text.toLowerCase();
  final more = <String>[
    // "sahur" dan "berbuka" sudah jelas; "buka" saja atau pertanyaan minum perlu kata "puasa ramadan" supaya catatannya
    // ketemu
    if (ctx.contains('puasa') && !RegExp(r'\b(puasa|sahur|berbuka)\b').hasMatch(t) && RegExp(r'\b(buka|takjil|minum|kopi|teh)\b').hasMatch(t))
      'puasa ramadan'
    else if (ctx.contains('puasa_if') && !t.contains('jendela') && RegExp(r'\b(minum|kopi|teh|makan|boleh|kapan)\b').hasMatch(t))
      'puasa jendela makan',
    // "buah yang aman apa?" dari pengguna yang menyebut diabetes berarti buah untuk diabetes
    if (_choosesFood.hasMatch(t))
      for (final w in ctx.map((k) => _conditionWords[k]).nonNulls)
        if (!t.contains(w)) w,
  ];
  return more.isEmpty ? text : '$text ${more.join(' ')}';
}

const _conditionWords = {
  'diabetes': 'diabetes',
  'hipertensi': 'darah tinggi',
  'kolesterol': 'kolesterol',
  'asam_urat': 'asam urat',
  'hamil': 'hamil',
  'maag': 'maag',
};

final _choosesFood = RegExp(
  r'\b(aman|boleh|bolehkah|cocok|bagus|baik|sebaiknya|pantangan|hindari|dihindari|makan|minum|buah|sayur|camilan|cemilan|menu|makanan|minuman)\b',
);
