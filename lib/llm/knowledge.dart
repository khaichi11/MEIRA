/// Basis pengetahuan dapur untuk RAG: catatan singkat yang dicari dengan BM25 dan disisipkan
/// ke konteks model sebagai pegangan fakta.
library;

import 'dart:math' as math;

import '../core/vocab.dart';

class Note {
  Note(this.title, this.keywords, this.body);
  final String title;
  final String keywords;
  final String body;
}

class KnowledgeBase {
  KnowledgeBase(this.notes, {this.k1 = 1.4, this.b = .75}) {
    for (final n in notes) {
      final toks = _tokens('${n.title} ${n.title} ${n.keywords} ${n.keywords} ${n.body}');
      _docs.add(toks);
      for (final t in toks.toSet()) {
        _df[t] = (_df[t] ?? 0) + 1;
      }
    }
    _avg = _docs.isEmpty ? 1 : _docs.fold<int>(0, (a, d) => a + d.length) / _docs.length;
  }

  static KnowledgeBase parse(String markdown) {
    final notes = <Note>[];
    for (final block in markdown.split('\n## ').skip(1)) {
      final lines = block.split('\n');
      final title = lines.first.trim();
      final kw = lines.firstWhere((l) => l.startsWith('kunci:'), orElse: () => 'kunci:').substring(6).trim();
      final body = lines.skip(1).where((l) => !l.startsWith('kunci:') && l.trim().isNotEmpty).join(' ').trim();
      notes.add(Note(title, kw, body));
    }
    return KnowledgeBase(notes);
  }

  final List<Note> notes;
  final double k1;
  final double b;
  final List<List<String>> _docs = [];
  final Map<String, int> _df = {};
  late final double _avg;

  // kata tanya dan kata waktu umum tidak dihitung, agar "berapa harga saham hari ini" tidak dianggap soal dapur
  static const _stop = {
    'yang',
    'dan',
    'atau',
    'di',
    'ke',
    'dari',
    'untuk',
    'dengan',
    'ini',
    'itu',
    'apa',
    'apakah',
    'bagaimana',
    'gimana',
    'saya',
    'aku',
    'bisa',
    'ada',
    'tidak',
    'nggak',
    'gak',
    'agar',
    'supaya',
    'berapa',
    'hari',
    'kapan',
    'kenapa',
    'mengapa',
    'boleh',
  };

  static List<String> _tokens(String text) => [
    for (final w in norm(text).split(' '))
      if (w.length > 2 && !_stop.contains(w)) w,
  ];

  /// Hasil: (catatan, skor BM25, jumlah kata berbeda yang cocok).
  /// Jumlah kata bermakna dalam pertanyaan; dipakai untuk menghitung seberapa banyak pertanyaan diliput sebuah catatan.
  int termCount(String query) => _tokens(query).toSet().length;

  List<(Note, double, int)> search(String query, {int k = 2, double minScore = 1.5}) {
    final q = _tokens(query).toSet();
    if (q.isEmpty) return [];
    final n = _docs.length;
    final hits = <(Note, double, int)>[];
    for (var i = 0; i < n; i++) {
      final d = _docs[i];
      final tf = <String, int>{};
      for (final t in d) {
        if (q.contains(t)) tf[t] = (tf[t] ?? 0) + 1;
      }
      var score = 0.0;
      tf.forEach((t, f) {
        final idf = math.log(1 + (n - _df[t]! + .5) / (_df[t]! + .5));
        score += idf * f * (k1 + 1) / (f + k1 * (1 - b + b * d.length / _avg));
      });
      if (score >= minScore) hits.add((notes[i], score, tf.length));
    }
    hits.sort((a, b) => b.$2.compareTo(a.$2));
    return hits.take(k).toList();
  }
}

/// Pertanyaan pengetahuan dapur yang tidak tertangkap aturan: berbentuk pertanyaan, tidak meminta resep, dan cocok
/// kuat (minimal dua kata berbeda) dengan sebuah catatan. Contoh: "apakah sayur perlu dicuci pakai sabun?".
final _wantsRecipe = RegExp(
  r'\b(resep|masak apa|menu|ide|rekomendasi|sarankan|bikin apa|buat apa|dibuat apa|dimasak apa|'
  r'olahan|bisa (saya |aku )?(masak|buat|bikin)|bisa dibuat|bisa dimasak|enaknya)\b',
);

bool kitchenQuestion(String text, KnowledgeBase kb) {
  final t = ' ${text.toLowerCase()} ';
  final asks =
      text.trim().endsWith('?') || RegExp(r'\b(apakah|bagaimana|gimana|berapa|kenapa|mengapa|perlu|haruskah|bisakah|bolehkah|cara)\b').hasMatch(t);
  if (!asks || _wantsRecipe.hasMatch(t)) return false;
  final hits = kb.search(text, k: 1);
  return hits.isNotEmpty && hits.first.$3 >= 2;
}

/// Pertanyaan tentang sifat bahan, misalnya "apel hijau rasanya beda nggak sama apel merah", bukan permintaan resep
/// walaupun menyebut bahan. Pertanyaan seperti ini dijawab sebagai obrolan, bukan dengan rekomendasi resep.
bool ingredientQuestion(String text) {
  final t = ' ${text.toLowerCase().replaceAll('?', ' ? ')} ';
  if (_wantsRecipe.hasMatch(t)) return false;
  final strong = RegExp(
    r'\b(beda|bedanya|perbedaan|dibanding|dibandingkan|daripada|rasanya|teksturnya|kenapa|mengapa|kok|'
    r'lebih (enak|manis|asam|sehat|segar|awet|lembut|renyah))\b',
  ).hasMatch(t);
  // "... nggak?" di akhir kalimat juga pertanyaan, kecuali pernyataan bahan seperti "ada telur juga"
  final tag = RegExp(r'\b(nggak|enggak|gak|ga|tidak|kah)\s*\??\s*$').hasMatch(t.trim());
  final states = RegExp(r'\b(ada|punya|tambah|tambahkan|juga|sisa|masih)\b').hasMatch(t);
  // pertanyaan biasa tentang bahan atau hidangan ("pisang hijau itu pisang apa?") juga obrolan, selama bukan minta resep
  final asks = t.contains('?') || RegExp(r'\b(apa|apakah|kenapa|mengapa|kok|bagaimana|gimana|berapa|jenis|macam)\b').hasMatch(t);
  return strong || asks || (tag && !states);
}

/// Pesan yang dijawab sebagai obrolan walaupun aturan menebak permintaan rekomendasi resep.
bool chatQuestion(String text, KnowledgeBase? kb) => ingredientQuestion(text) || (kb != null && kitchenQuestion(text, kb));
