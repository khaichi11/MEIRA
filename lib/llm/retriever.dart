/// Retriever BM25 di atas buku resep (RAG): jawaban pertanyaan bebas berpijak pada resep lokal,
/// bukan pada ingatan model kecil yang mudah mengarang.
library;

import 'dart:math' as math;

import '../core/recipes.dart';
import '../core/vocab.dart';

class RecipeHit {
  RecipeHit(this.recipe, this.score, [this.matched = 0]);
  final Recipe recipe;
  final double score;
  final int matched; // jumlah kata berbeda dari pertanyaan yang ditemukan di resep ini
}

class RecipeRetriever {
  RecipeRetriever(this.recipes, {this.k1 = 1.4, this.b = .75}) {
    for (final r in recipes) {
      // nama dan bahan utama diberi bobot lebih dengan diulang
      final text = [
        r.name,
        r.name,
        r.desc,
        r.tags.join(' '),
        for (final i in r.items) ...[i.name, if (i.main) i.name],
        r.steps.join(' '),
        r.tip,
      ].join(' ');
      final toks = _tokens(text);
      _docs.add(toks);
      for (final t in toks.toSet()) {
        _df[t] = (_df[t] ?? 0) + 1;
      }
    }
    _avgLen = _docs.isEmpty ? 1 : _docs.fold<int>(0, (a, d) => a + d.length) / _docs.length;
  }

  final List<Recipe> recipes;
  final double k1;
  final double b;
  final List<List<String>> _docs = [];
  final Map<String, int> _df = {};
  late final double _avgLen;

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
    'aku',
    'saya',
    'mau',
    'ingin',
    'bisa',
    'apa',
    'gimana',
    'bagaimana',
    'cara',
    'resep',
    'bikin',
    'buat',
    'masak',
    'dong',
    'ya',
    'sih',
    'nya',
    'ada',
    'tidak',
    'nggak',
    'gak',
    'sampai',
    'lalu',
    'agar',
    'supaya',
    'sudah',
    'akan',
    'juga',
    'lebih',
    'sebentar',
    'menit',
  };

  static List<String> _tokens(String text) => [
    for (final w in norm(text).split(' '))
      if (w.length > 2 && !_stop.contains(w)) w,
  ];

  List<RecipeHit> search(String query, {int k = 3, double minScore = 1.0}) {
    final q = _tokens(query).toSet();
    // nama bahan yang disebut juga dicari lewat nama Indonesianya
    for (final key in mentions(query)) {
      q.addAll(_tokens(displayName(key)));
    }
    if (q.isEmpty) return [];
    final n = _docs.length;
    final hits = <RecipeHit>[];
    for (var i = 0; i < n; i++) {
      final d = _docs[i];
      final tf = <String, int>{};
      for (final t in d) {
        if (q.contains(t)) tf[t] = (tf[t] ?? 0) + 1;
      }
      var score = 0.0;
      tf.forEach((t, f) {
        final idf = math.log(1 + (n - _df[t]! + .5) / (_df[t]! + .5));
        score += idf * f * (k1 + 1) / (f + k1 * (1 - b + b * d.length / _avgLen));
      });
      if (score >= minScore) hits.add(RecipeHit(recipes[i], score, tf.length));
    }
    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(k).toList();
  }
}
