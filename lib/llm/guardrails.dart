/// Guardrails: menjaga MEIRA tetap di topik dapur, menolak permintaan berbahaya dengan sopan,
/// dan mengabaikan upaya mengubah instruksinya.
library;

import '../core/recipes.dart';
import '../core/vocab.dart';

enum GuardVerdict { allow, offTopic, unsafe, injection, medical }

class GuardResult {
  const GuardResult(this.verdict, [this.reply = '']);
  final GuardVerdict verdict;
  final String reply;
  bool get allowed => verdict == GuardVerdict.allow;
}

class Guardrails {
  static final _injection = RegExp(
    r'\b(abaikan|lupakan|acuhkan|ignore|disregard)\b.{0,40}\b(instruksi|perintah|aturan|prompt|instructions?|rules?)(mu|nya)?\b|'
    r'\bbebas menjawab apa (saja|pun)\b|'
    r'\b(system prompt|prompt sistem|jailbreak|mode developer|developer mode|berpura-pura(lah)? menjadi|pretend to be)\b',
    caseSensitive: false,
  );

  static final _unsafe = RegExp(
    r'\b(racun|meracun|bom|peledak|narkoba|sabu|ganja|senjata|membunuh|bunuh diri|menyakiti)\b|'
    r'\b(alkohol oplosan|metanol|jamur beracun untuk|meracuni)\b|'
    r'\bmembuat (orang|seseorang|dia|mereka) (sakit|keracunan|pingsan)\b',
    caseSensitive: false,
  );

  static final _medical = RegExp(
    r'\b(menyembuhkan|obat untuk|mengobati|diabetes|kanker|hipertensi|darah tinggi|kolesterol|asam urat|hamil|ibu hamil|bayi di bawah|mpasi|dosis)\b',
    caseSensitive: false,
  );

  /// Kata yang menandakan percakapan masih seputar dapur dan makanan.
  /// Nama hidangan, jajanan, dan istilah kuliner Indonesia yang sering ditanyakan, supaya pertanyaan seperti "apa bedanya
  /// rendang dan kalio" tidak ditolak hanya karena hidangannya belum ada di buku resep.
  static final _food = RegExp(
    r'\b(hidangan|kuliner|lauk|jajanan|kudapan|kue|camilan|dessert|snack|gizi|nutrisi|kalori|protein|vitamin|serat|'
    r'rendang|kalio|soto|sate|bakso|gado|rawon|opor|semur|gulai|pecel|lontong|ketupat|martabak|seblak|cireng|cilok|batagor|'
    r'siomay|pempek|karedok|urap|sop|sup|uduk|kuning|bubur|kolak|klepon|onde|lemper|risoles|pastel|lumpia|kerupuk|rempeyek|'
    r'perkedel|bakwan|puding|agar|jus|kopi|teh|sambal|saus|kecap|rica|balado|oseng|sangrai|ungkep|presto|marinasi|fermentasi|'
    r'kecambah|tauge|singkong|ubi|jagung|kentang|tomat|cabai|cabe|bawang|jahe|kunyit|lengkuas|serai|kemiri|ketumbar|merica|'
    r'pisang|apel|jeruk|mangga|pepaya|semangka|melon|nanas|anggur|durian|rambutan|alpukat|kelapa|beras|ketan|terigu|mentega)\b',
    caseSensitive: false,
  );

  static final _kitchen = RegExp(
    r'\b(masak|memasak|resep|bahan|bumbu|goreng|rebus|tumis|panggang|kukus|bakar|makan|makanan|minuman|minum|sarapan|camilan|'
    r'dapur|kulkas|simpan|menyimpan|segar|matang|potong|iris|cincang|blender|wajan|panci|teflon|oven|kompor|porsi|menit|'
    r'pengganti|ganti|enak|pedas|manis|asin|gurih|sayur|buah|daging|telur|nasi|mi|mie|roti|susu|keju|ikan|udang|ayam|tahu|tempe|'
    r'santan|gula|garam|minyak|tepung|foto|nomor|penanda|alergi|vegetarian)\b',
    caseSensitive: false,
  );

  static final _smallTalk = RegExp(
    r'\b(terima kasih|makasih|halo|hai|hi|hello|assalamualaikum|selamat (pagi|siang|sore|malam)|oke|baik|sampai jumpa|dadah|'
    r'kamu siapa|siapa kamu|kamu bisa apa|bisa (bantu|membantu) apa|apa (saja|aja) yang bisa (kamu|anda))\b',
    caseSensitive: false,
  );

  /// Sapaan, ucapan terima kasih, atau pertanyaan tentang kemampuan MEIRA: dijawab sebagai obrolan, bukan resep.
  static bool smallTalk(String text) => _smallTalk.hasMatch(text) && mentions(text).isEmpty;

  /// Periksa pesan pengguna sebelum diteruskan ke model. [knownIngredient] = pesan menyebut bahan yang dikenal.
  /// [ragScore] = skor BM25 tertinggi dari buku resep atau catatan dapur; kecocokan lemah (kata umum) tidak dihitung.
  static const ragThreshold = 4.0;

  /// Pesan yang jelas termasuk alur resep: menyebut bahan, atau permintaan lanjutan seperti "cara membuatnya",
  /// "resep lain", "pilih nomor dua", dan "apakah ada telur?".
  static bool kitchenRequest(String text) =>
      mentions(text).isNotEmpty || const {'detail', 'ganti', 'pilih', 'substitusi', 'cek', 'hidangan'}.contains(ruleIntent(text).action);

  static GuardResult checkInput(String text, {bool knownIngredient = false, double ragScore = 0}) {
    final t = text.toLowerCase();
    if (_injection.hasMatch(t)) {
      return const GuardResult(
        GuardVerdict.injection,
        'Mohon maaf, saya tetap mengikuti peran sebagai asisten dapur MEIRA. Silakan sampaikan pertanyaan seputar bahan atau resep.',
      );
    }
    if (_unsafe.hasMatch(t)) {
      return const GuardResult(
        GuardVerdict.unsafe,
        'Mohon maaf, saya tidak dapat membantu permintaan tersebut. Saya dengan senang hati membantu memilih resep dari bahan yang Anda miliki.',
      );
    }
    if (_medical.hasMatch(t)) {
      return const GuardResult(
        GuardVerdict.medical,
        'Untuk kebutuhan kesehatan atau kondisi medis tertentu, sebaiknya Anda berkonsultasi dengan dokter atau ahli gizi. '
        'Saya dapat membantu memilih resep secara umum, misalnya yang rendah gula atau tidak pedas.',
      );
    }
    if (!knownIngredient && ragScore < ragThreshold && !_kitchen.hasMatch(t) && !_food.hasMatch(t) && !_smallTalk.hasMatch(t)) {
      return const GuardResult(
        GuardVerdict.offTopic,
        'Saya MEIRA, asisten khusus dapur, sehingga hanya dapat membantu soal bahan, resep, dan cara memasak. '
        'Silakan kirim foto bahan atau tanyakan resep yang Anda inginkan.',
      );
    }
    return const GuardResult(GuardVerdict.allow);
  }

  /// Definisi berputar: "orak-arik adalah orak-arik", "telur dadar yaitu telur dadar".
  static bool isCircular(String answer) {
    final m = RegExp(
      r'\b([a-z]+(?:[- ][a-z]+)?)\s+(?:adalah|yaitu|ialah|merupakan)\s+(?:sebuah\s+|suatu\s+)?\1\b',
      caseSensitive: false,
    ).firstMatch(answer.toLowerCase());
    return m != null;
  }

  static final _leak = RegExp(r'RESEP TERPILIH|KANDIDAT LAIN|DAFTAR BAHAN DI FOTO|TUGAS:|PREFERENSI:|REFERENSI BUKU RESEP|PENGETAHUAN DAPUR');

  /// Periksa jawaban model: bocoran konteks, teks kosong, dan saran keamanan pangan yang keliru.
  static String checkOutput(String answer) {
    var a = answer.replaceAll(_leak, '').replaceAll(RegExp(r'[—–]'), ',').replaceAll(RegExp(r'[ \t]{2,}'), ' ').trim();
    // saran berbahaya yang lazim keliru: ayam/daging setengah matang, telur mentah untuk anak
    if (RegExp(
      r'\b(ayam|daging ayam)\b.{0,30}\b(setengah matang|masih merah muda|kurang matang)\b.{0,30}\b(aman|boleh|tidak apa)',
      caseSensitive: false,
    ).hasMatch(a)) {
      a += ' Catatan keamanan: ayam harus dimasak sampai matang sempurna, tanpa bagian merah muda.';
    }
    return a;
  }

  /// Kata penghubung dan kata umum yang boleh ditambahkan model walau tidak ada di sumber.
  static const _glue = {
    'anda',
    'saya',
    'dapat',
    'bisa',
    'perlu',
    'harus',
    'sebaiknya',
    'agar',
    'supaya',
    'sehingga',
    'karena',
    'juga',
    'lebih',
    'kurang',
    'sekitar',
    'kira',
    'setelah',
    'sebelum',
    'saat',
    'ketika',
    'hingga',
    'sampai',
    'dengan',
    'tersebut',
    'bila',
    'jika',
    'apabila',
    'selalu',
    'cukup',
    'terlalu',
    'masih',
    'sudah',
    'akan',
    'adalah',
    'yaitu',
    'berarti',
    'merupakan',
    'menjadi',
    'dalam',
    'pada',
    'untuk',
    'dari',
    'yang',
    'atau',
    'tetapi',
    'namun',
    'tidak',
    'jangan',
    'hanya',
    'sangat',
    'paling',
    'biasanya',
    'umumnya',
    'tetap',
    'mulai',
    'baik',
    'cara',
    'waktu',
    'menit',
    'hari',
    'derajat',
    'celsius',
    'beberapa',
    'semua',
    'setiap',
    'berikut',
    'langkah',
    'kemudian',
    'lalu',
    'silakan',
    'semoga',
    'membantu',
    'mencoba',
    'memasak',
    'masak',
    'bahan',
    'hasil',
    'ingin',
    'mohon',
    'pastikan',
    'gunakan',
    'pakai',
    'memakai',
    'menggunakan',
    'sedikit',
    'banyak',
    'lama',
    'sebentar',
    'benar',
    'aman',
    'yakni',
    'seperti',
    'misalnya',
    'contohnya',
    'demikian',
    'begitu',
    'itulah',
    'karenanya',
    'tanpa',
    'bukan',
    'secara',
  };

  /// Bentuk dasar yang mungkin dari sebuah kata (imbuhan umum bahasa Indonesia, termasuk peluluhan me-/pe-).
  static Set<String> _forms(String w) {
    final out = {w};
    for (final suf in ['nya', 'kan', 'lah', 'an', 'i']) {
      if (w.length > suf.length + 3 && w.endsWith(suf)) out.add(w.substring(0, w.length - suf.length));
    }
    const prefixes = {
      'meng': ['', 'k'],
      'meny': ['s'],
      'mem': ['', 'p'],
      'men': ['', 't'],
      'me': [''],
      'peng': ['', 'k'],
      'peny': ['s'],
      'pem': ['', 'p'],
      'pen': ['', 't'],
      'pe': [''],
      'ber': [''],
      'be': [''],
      'ter': [''],
      'per': [''],
      'di': [''],
      'ke': [''],
      'se': [''],
    };
    for (final b in out.toList()) {
      for (final e in prefixes.entries) {
        if (b.length > e.key.length + 3 && b.startsWith(e.key)) {
          for (final r in e.value) {
            out.add(r + b.substring(e.key.length));
          }
        }
      }
    }
    return out;
  }

  static final _num = RegExp(r'\d+(?:[.,]\d+)?');

  /// Jawaban berpijak pada sumber: tidak ada angka baru, dan sebagian besar kata isinya ada di sumber
  /// atau pertanyaan. Dipakai sebelum jawaban model ditampilkan; bila gagal, catatan aslinya yang dipakai.
  static bool supported(String answer, String source, {String question = '', double minRatio = .75}) {
    final known = '$source $question';
    final nums = _num.allMatches(known).map((m) => m.group(0)!).toSet();
    if (_num.allMatches(answer).any((m) => !nums.contains(m.group(0)))) return false;
    final forms = {
      for (final w in norm(known).split(' '))
        if (w.length >= 3) ..._forms(w),
    };
    final words = [
      for (final w in norm(answer).split(' '))
        if (w.length >= 4 && !_glue.contains(w) && !_num.hasMatch(w)) w,
    ];
    if (words.isEmpty) return false;
    final ok = words.where((w) => _forms(w).intersection(forms).isNotEmpty).length;
    return ok / words.length >= minRatio;
  }
}
