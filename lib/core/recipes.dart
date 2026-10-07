/// Buku resep lokal: parser Markdown, pencocokan dengan bahan di foto, dan pemahaman permintaan.
library;

import 'vocab.dart';

const recipeTags = ['sarapan', 'camilan', 'minuman', 'berkuah', 'pedas', 'manis', 'segar', 'sehat', 'vegetarian', 'anak', 'tanpa-kompor', 'hemat'];

class RecipeItem {
  RecipeItem(this.key, this.amount, {this.main = false, this.optional = false});
  final String key;
  final String amount;
  final bool main;
  final bool optional;
  String get name => displayName(key);
}

class Recipe {
  Recipe(this.id, this.name, this.minutes, this.servings, this.difficulty);
  final String id;
  final String name;
  final int minutes;
  final int servings;
  final String difficulty;
  List<String> tags = [];
  String desc = '';
  final List<RecipeItem> items = [];
  final List<String> steps = [];
  String tip = '';
  final Map<String, String> swaps = {};

  Set<String> get mainKeys => {for (final i in items) if (i.main) i.key};
  Set<String> get neededKeys => {for (final i in items) if (!i.optional && !pantry.contains(i.key)) i.key};
}

List<Recipe> parseRecipes(String markdown) {
  final out = <Recipe>[];
  Recipe? cur;
  String? section;
  for (final line in markdown.split('\n')) {
    final s = line.trim();
    if (line.startsWith('## ')) {
      final p = line.substring(3).split('|').map((e) => e.trim()).toList();
      cur = Recipe(p[0], p[1], int.parse(p[2]), int.parse(p[3]), p[4]);
      out.add(cur);
      section = null;
      continue;
    }
    if (cur == null || s.isEmpty) continue;
    if (s.startsWith('tag:')) {
      cur.tags = s.substring(4).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (s.startsWith('desc:')) {
      cur.desc = s.substring(5).trim();
    } else if (s.startsWith('tip:')) {
      cur.tip = s.substring(4).trim();
    } else if (s.startsWith('ganti:')) {
      for (final pair in s.substring(6).split(';')) {
        final i = pair.indexOf('=');
        if (i > 0) cur.swaps[pair.substring(0, i).trim()] = pair.substring(i + 1).trim();
      }
    } else if (s == 'bahan:' || s == 'langkah:') {
      section = s.substring(0, s.length - 1);
    } else if (section == 'bahan' && s.startsWith('- ')) {
      final bar = s.indexOf('|');
      var key = (bar > 0 ? s.substring(2, bar) : s.substring(2)).trim();
      final amount = bar > 0 ? s.substring(bar + 1).trim() : '';
      final main = key.endsWith('*'), opt = key.endsWith('?');
      key = key.replaceAll(RegExp(r'[*?]$'), '');
      cur.items.add(RecipeItem(key, amount, main: main, optional: opt));
    } else if (section == 'langkah' && RegExp(r'^\d+\.').hasMatch(s)) {
      cur.steps.add(s.substring(s.indexOf('.') + 1).trim());
    }
  }
  return out;
}

class Prefs {
  int? maxMinutes;
  Set<String> tags = {};
  Set<String> exclude = {};
  Set<String> include = {};

  Map<String, dynamic> toJson() => {'max_minutes': maxMinutes, 'tags': tags.toList(), 'exclude': exclude.toList(), 'include': include.toList()};

  static Prefs fromJson(Map<String, dynamic>? j) {
    final p = Prefs();
    if (j == null) return p;
    p.maxMinutes = j['max_minutes'] as int?;
    p.tags = {...((j['tags'] as List?) ?? []).cast<String>()};
    p.exclude = {...((j['exclude'] as List?) ?? []).cast<String>()};
    p.include = {...((j['include'] as List?) ?? []).cast<String>()};
    return p;
  }
}

class Match {
  Match(this.recipe, this.score, this.have, this.missing);
  final Recipe recipe;
  final double score;
  final List<String> have;
  final List<String> missing;
}

List<Match> rank(List<Recipe> recipes, Set<String> have, Prefs prefs, {Set<String> skip = const {}, int k = 3}) {
  final out = <Match>[];
  for (final r in recipes) {
    if (skip.contains(r.id)) continue;
    if (prefs.maxMinutes != null && r.minutes > prefs.maxMinutes!) continue;
    if (r.mainKeys.intersection(prefs.exclude).isNotEmpty) continue;
    if (prefs.tags.contains('tanpa-kompor') && !r.tags.contains('tanpa-kompor')) continue;
    if (prefs.tags.contains('vegetarian') && !r.tags.contains('vegetarian')) continue;
    final mainHit = r.mainKeys.intersection(have);
    if (have.isNotEmpty && mainHit.isEmpty) continue;
    final covMain = mainHit.length / (r.mainKeys.isEmpty ? 1 : r.mainKeys.length);
    final needed = r.neededKeys;
    final covAll = needed.intersection(have).length / (needed.isEmpty ? 1 : needed.length);
    final tagHit = prefs.tags.isEmpty ? 0.0 : prefs.tags.intersection(r.tags.toSet()).length / prefs.tags.length;
    final bonus = .03 * {for (final i in r.items) if (i.optional) i.key}.intersection(have).length;
    final penalty = .15 * {for (final i in r.items) i.key}.intersection(prefs.exclude).length;
    final score = .55 * covMain + .3 * covAll + .15 * tagHit + bonus - penalty;
    out.add(Match(
      r,
      score,
      [for (final i in r.items) if (have.contains(i.key)) i.key],
      [for (final i in r.items) if (!i.optional && !have.contains(i.key) && !pantry.contains(i.key)) i.key],
    ));
  }
  out.sort((a, b) {
    final c = b.score.compareTo(a.score);
    if (c != 0) return c;
    final m = a.missing.length.compareTo(b.missing.length);
    return m != 0 ? m : a.recipe.minutes.compareTo(b.recipe.minutes);
  });
  return out.take(k).toList();
}

Recipe? findRecipe(List<Recipe> recipes, String query) {
  final q = query.toLowerCase();
  for (final r in recipes) {
    final n = r.name.toLowerCase();
    if (r.id == q || q.contains(n) || n.contains(q)) return r;
  }
  final words = RegExp(r'[a-z]+').allMatches(q).map((m) => m.group(0)!).toSet();
  Recipe? best;
  var bestHit = 0;
  for (final r in recipes) {
    final hit = RegExp(r'[a-z]+').allMatches(r.name.toLowerCase()).map((m) => m.group(0)!).toSet().intersection(words).length;
    if (hit > bestHit) {
      bestHit = hit;
      best = r;
    }
  }
  return bestHit >= 2 ? best : null;
}

/// Hasil pemahaman permintaan pengguna.
class Intent {
  Intent(this.action);
  String action; // rekomendasi | hidangan | ganti | pilih | detail | substitusi | cek | obrolan
  int? maxMinutes;
  Set<String> tags = {};
  Set<String> exclude = {};
  Set<String> include = {};
  String? ingredient;
  int? choice;
}

bool _has(String t, String pattern) => RegExp(pattern).hasMatch(t);

/// Pemahaman permintaan berbasis aturan: cepat, tanpa model, dan tepat untuk pola umum.
Intent ruleIntent(String text) {
  final t = ' ${text.toLowerCase()} ';
  var action = 'rekomendasi';
  if (_has(t, r'\b(lain|ganti|yang beda|alternatif|selain itu|nggak suka|gak suka|bosen|bosan)\b')) action = 'ganti';
  if (_has(t, r'\b(pilih|yang nomor|nomor \d|yang (pertama|kedua|ketiga)|ambil yang)\b')) action = 'pilih';
  if (_has(t, r'\b(makanan apa|masakan apa|ini apa|bahannya apa|bahan apa saja|bahan apa aja|pakai bahan apa|pake bahan apa|terbuat dari|dibuat dari|isinya apa)\b')) {
    action = 'hidangan';
  }
  if (_has(t, r'\b(caranya|langkah|gimana bikin|bagaimana membuat|cara buat|cara membuat|resepnya)\b')) action = 'detail';
  if (_has(t, r'\b(pengganti|diganti apa|ganti apa|substitusi|kalau nggak ada|kalau gak ada|kalau tidak ada)\b')) action = 'substitusi';
  if (_has(t, r'\b(apakah ada|ada (\w+ )?(nggak|gak|tidak) di foto|cek|periksa|beneran ada|benar ada)\b')) action = 'cek';
  final it = Intent(action);

  final m = RegExp(r'(\d+)\s*(menit|mnt)').firstMatch(t);
  if (m != null) {
    it.maxMinutes = int.parse(m.group(1)!);
  } else {
    const words = {'lima menit': 5, 'sepuluh menit': 10, 'lima belas menit': 15, 'dua puluh menit': 20, 'setengah jam': 30};
    words.forEach((w, v) {
      if (t.contains(' $w')) it.maxMinutes = v;
    });
    if (_has(t, r'\b(cepat|kilat|buru-buru|nggak sempat|gak sempat|tidak sempat|sebentar)\b')) it.maxMinutes ??= 15;
  }

  const tagWords = {
    'sarapan': r'sarapan|pagi',
    'camilan': r'camilan|cemilan|ngemil|snack',
    'minuman': r'minum|jus|smoothie|es ',
    'berkuah': r'kuah|sup|sop|hangat',
    'manis': r'manis|dessert|pencuci mulut',
    'segar': r'segar|seger',
    'sehat': r'sehat|diet|ringan',
    'vegetarian': r'vegetarian|tanpa daging|vegan',
    'anak': r'anak|bocah|si kecil',
    'tanpa-kompor': r'tanpa kompor|nggak pakai kompor|gak pakai kompor|tanpa masak|tidak masak|gak masak|nggak masak',
    'hemat': r'hemat|murah|irit',
  };
  tagWords.forEach((tag, pat) {
    if (_has(t, pat)) it.tags.add(tag);
  });
  if (_has(t, r'pedas') && !_has(t, r'\b(jangan|nggak|gak|tidak|ga|kurang|tanpa) (terlalu |yang )?pedas')) it.tags.add('pedas');

  for (final mm in RegExp(r'(?:jangan|tanpa|nggak mau|gak mau|tidak mau|nggak suka|gak suka|tidak suka|alergi)\s+([a-z ,]{3,40}?)(?=[.!?]| dong| ya| deh| aja| saja| $)').allMatches(t)) {
    it.exclude.addAll(mentions(mm.group(1)!));
  }
  if (_has(t, r'\b(jangan|nggak|gak|tidak|ga|kurang|tanpa) (terlalu |yang )?pedas')) it.exclude.add('chili');
  for (final mm in RegExp(r'(?:punya|ada|pakai|pake|stok)\s+([a-z ,]{3,50}?)(?=[.!?]| dong| ya| juga| di rumah| di kulkas| $)').allMatches(t)) {
    final before = t.substring(mm.start < 8 ? 0 : mm.start - 8, mm.start);
    if (mm.group(0)!.contains('di foto') || RegExp(r'(nggak|gak|tidak|ga|belum) $').hasMatch(before)) continue;
    it.include.addAll(mentions(mm.group(1)!));
  }
  final named = mentions(text);
  it.ingredient = named.isNotEmpty ? displayName(named.first) : null;
  final c = RegExp(r'(?:nomor|yang ke|pilihan)\s*(\d)').firstMatch(t);
  if (c != null) {
    it.choice = int.parse(c.group(1)!);
  } else if (_has(t, r'\b(pertama|kesatu)\b')) {
    it.choice = 1;
  } else if (_has(t, r'\bkedua\b')) {
    it.choice = 2;
  } else if (_has(t, r'\bketiga\b')) {
    it.choice = 3;
  }
  return it;
}
