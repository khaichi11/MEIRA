/// Kosakata bahan: pemetaan label bebas dari model atau pengguna ke kunci bahan.
library;

import 'generated.dart';

class Ingredient {
  const Ingredient(this.key, this.nameId, this.nameEn, this.category, this.synonyms, this.pantry);
  final String key;
  final String nameId;
  final String nameEn;
  final String category;
  final List<String> synonyms;
  final bool pantry;
}

final Map<String, Ingredient> ingredients = {
  for (final r in ingredientRows) r.key: Ingredient(r.key, r.nameId, r.nameEn, r.category, r.synonyms, r.pantry),
};

final Set<String> pantry = {
  for (final i in ingredients.values)
    if (i.pantry) i.key,
};

String norm(String text) {
  const from = 'àáâäãåèéêëìíîïòóôöõùúûüñç';
  const to = 'aaaaaaeeeeiiiiooooouuuunc';
  final buf = StringBuffer();
  for (final ch in text.toLowerCase().runes) {
    final c = String.fromCharCode(ch);
    final i = from.indexOf(c);
    buf.write(i >= 0 ? to[i] : c);
  }
  return buf.toString().replaceAll(RegExp(r'[^a-z0-9 ]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

final Map<String, String> _aliases = () {
  final m = <String, String>{};
  for (final i in ingredients.values) {
    for (final name in [i.key.replaceAll('_', ' '), i.nameId, i.nameEn, ...i.synonyms]) {
      m.putIfAbsent(norm(name), () => i.key);
    }
  }
  return m;
}();

final List<String> _aliasByLength = _aliases.keys.toList()..sort((a, b) => b.length.compareTo(a.length));

final _noise = RegExp(
  r'\b(sebuah|beberapa|buah|potong|potongan|irisan|segar|matang|mentah|setengah|sliced|slice|fresh|ripe|whole|half|piece|pieces|of|a|an|the|bunch|group|sekelompok|tumpukan|sisir|butir|ikat|kecil|besar)\b',
);

final _nonFood = RegExp(
  r'\b(kotak|box|tanda|label|harga|price|kertas|paper|piring|plate|mangkuk|bowl|meja|table|tangan|hand|plastik|plastic|keranjang|basket|pisau|knife|talenan|board|sendok|spoon|garpu|fork|wadah|container|kantong|bag|kain|cloth|botol|bottle|toples|jar|panci|pan|wajan|tray|nampan|rak|shelf|orang|person|tulisan|text|logo|stiker|sticker)\b',
);

/// Label bebas -> kunci bahan, atau null bila tidak dikenal.
String? resolve(String label) {
  final n = norm(label);
  if (n.isEmpty) return null;
  if (_aliases.containsKey(n)) return _aliases[n];
  final stripped = n.replaceAll(_noise, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (_aliases.containsKey(stripped)) return _aliases[stripped];
  for (final c in [n, stripped]) {
    if (c.endsWith('s') && _aliases.containsKey(c.substring(0, c.length - 1))) return _aliases[c.substring(0, c.length - 1)];
  }
  final target = stripped.isEmpty ? n : stripped;
  String? best;
  var bestScore = 0.0;
  for (final a in _aliases.keys) {
    final s = _similarity(target, a);
    if (s > bestScore) {
      bestScore = s;
      best = a;
    }
  }
  if (best != null && bestScore >= 0.86) return _aliases[best];
  final found = mentions(n);
  return found.length == 1 ? found.first : null;
}

/// Semua bahan yang disebut di kalimat, urut kemunculan (alias terpanjang menang).
List<String> mentions(String text) {
  var t = ' ${norm(text)} ';
  final found = <(int, String)>[];
  for (final alias in _aliasByLength) {
    if (alias.length < 3) continue;
    final needle = ' $alias ';
    var i = t.indexOf(needle);
    while (i != -1) {
      found.add((i, _aliases[alias]!));
      t = t.substring(0, i + 1) + '#' * alias.length + t.substring(i + 1 + alias.length);
      i = t.indexOf(needle);
    }
  }
  found.sort((a, b) => a.$1.compareTo(b.$1));
  final out = <String>[];
  for (final f in found) {
    if (!out.contains(f.$2)) out.add(f.$2);
  }
  return out;
}

bool isNonFood(String label) => resolve(label) == null && _nonFood.hasMatch(norm(label));

String displayName(String key) => ingredients[key]?.nameId ?? key.replaceAll('_', ' ');

/// Rasio kemiripan seperti difflib (2*M/T) berbasis jarak Levenshtein.
double _similarity(String a, String b) {
  if (a == b) return 1;
  if (a.isEmpty || b.isEmpty) return 0;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost].reduce((x, y) => x < y ? x : y);
    }
    prev = cur;
  }
  return 1 - prev[b.length] / (a.length > b.length ? a.length : b.length);
}
