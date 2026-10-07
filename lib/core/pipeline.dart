/// Alur percakapan MEIRA di perangkat.
///
/// foto -> mata (VLM): bahan bernomor ┐
///      -> otak (visi): bahan atau makanan jadi? ┴-> buku resep -> otak (LLM) -> jawaban
/// teks atau suara pengguna: ganti resep, batas waktu, hindari bahan, cek bahan di foto.
library;

import 'dart:async';
import 'dart:math' as math;

import '../runtime/llama.dart';
import 'generated.dart';
import 'grounding.dart';
import 'history.dart';
import 'recipes.dart';
import 'vocab.dart';

const llmTurns = 6;

sealed class MeiraEvent {}

class StatusEvent extends MeiraEvent {
  StatusEvent(this.text);
  final String text;
}

/// Deteksi sementara selama model masih menulis (belum bernomor final).
class PartialEvent extends MeiraEvent {
  PartialEvent(this.items);
  final List<Detection> items;
}

class DetectionsEvent extends MeiraEvent {
  DetectionsEvent(this.items, this.seconds);
  final List<Detection> items;
  final double? seconds;
}

class SceneEvent extends MeiraEvent {
  SceneEvent(this.mode, this.dish);
  final String mode;
  final String? dish;
}

class RecipesEvent extends MeiraEvent {}

class TokenEvent extends MeiraEvent {
  TokenEvent(this.text);
  final String text;
}

class DoneEvent extends MeiraEvent {
  DoneEvent(this.text, this.source);
  final String text;
  final String source; // llm | templat | periksa
}

class ErrorEvent extends MeiraEvent {
  ErrorEvent(this.text);
  final String text;
}

class Session {
  Session(this.id);
  final String id;
  String? imageDataUrl; // foto ≤512 px untuk model
  String mode = 'bahan';
  String? dish;
  List<String> dishGuess = [];
  List<Detection> detections = [];
  Prefs prefs = Prefs();
  List<String> shown = [];
  List<Match> candidates = [];
  String? current;
  List<Map<String, String>> history = [];

  Map<String, List<int>> numbers() {
    final out = <String, List<int>>{};
    for (final d in detections) {
      if (d.key != null) out.putIfAbsent(d.key!, () => []).add(d.number);
    }
    return out;
  }

  Set<String> have() => {...numbers().keys, ...prefs.include};
  Match? get currentMatch => candidates.where((m) => m.recipe.id == current).firstOrNull;

  String title() {
    if (dish != null) return dish![0].toUpperCase() + dish!.substring(1);
    final names = grouped(detections).where((g) => g.key != null).map((g) => g.label).take(4).toList();
    if (names.isNotEmpty) {
      final t = names.join(', ');
      return t[0].toUpperCase() + t.substring(1);
    }
    final first = history.where((h) => h['role'] == 'user').map((h) => h['content']!).firstOrNull ?? '';
    return first.isEmpty ? 'Percakapan baru' : (first.length > 60 ? first.substring(0, 60) : first);
  }

  Map<String, dynamic> toState() => {
        'mode': mode,
        'dish': dish,
        'dish_guess': dishGuess,
        'detections': [for (final d in detections) d.toJson()],
        'prefs': prefs.toJson(),
        'shown': shown,
        'candidates': [for (final m in candidates) m.recipe.id],
        'current': current,
        'history': history.length > llmTurns ? history.sublist(history.length - llmTurns) : history,
      };

  static Session restore(String id, Map<String, dynamic> st, List<Recipe> recipes) {
    final s = Session(id)
      ..mode = st['mode'] ?? 'bahan'
      ..dish = st['dish']
      ..dishGuess = ((st['dish_guess'] as List?) ?? []).cast<String>()
      ..detections = [for (final d in (st['detections'] as List?) ?? []) Detection.fromJson(d)]
      ..prefs = Prefs.fromJson(st['prefs'])
      ..shown = ((st['shown'] as List?) ?? []).cast<String>()
      ..current = st['current']
      ..history = [for (final h in (st['history'] as List?) ?? []) Map<String, String>.from(h)];
    final byId = {for (final r in recipes) r.id: r};
    final cands = [for (final id in (st['candidates'] as List?) ?? []) ?byId[id]];
    final ranked = {for (final m in rank(cands, s.have(), Prefs(), k: math.max(1, cands.length))) m.recipe.id: m};
    s.candidates = [for (final r in cands) ranked[r.id] ?? Match(r, 0, [], [])];
    return s;
  }
}

class Meira {
  Meira({
    required this.recipes,
    required this.history,
    required this.eyes,
    required this.brain,
    this.eyesFineTuned = false,
    this.brainHasVision = true,
    this.useLlmIntent = true,
    this.answerStyle = 'ringkas',
    this.parallelVision = true,
  });

  final List<Recipe> recipes;
  final History history;
  LlmClient? eyes;
  LlmClient? brain;
  bool eyesFineTuned; // format ringkas hasil fine-tune; selain itu prompt JSON bawaan Qwen
  bool brainHasVision;
  bool useLlmIntent;
  String answerStyle; // ringkas: rekomendasi dan langkah dari buku resep; natural: semua lewat LLM
  bool parallelVision; // false di HP: deteksi dulu agar penanda cepat tampil, baru kenali hidangan

  // --------------------------------------------------------------- mata
  Stream<MeiraEvent> _detect(Session s) async* {
    final sw = Stopwatch()..start();
    final buf = StringBuffer();
    final partial = <Detection>[];
    var line = '';
    final prompt = eyesFineTuned ? promptGround : promptGroundZeroshot;
    await for (final tok in eyes!.stream(LlmClient.visionMessages(s.imageDataUrl!, prompt), maxTokens: 700, sampling: visionSampling)) {
      buf.write(tok);
      line += tok;
      while (line.contains('\n')) {
        final i = line.indexOf('\n');
        final d = parseLine(line.substring(0, i));
        line = line.substring(i + 1);
        if (d != null && !partial.any((p) => iou(p.box, d.box) > .7)) {
          partial.add(d);
          yield PartialEvent(List.of(partial));
        }
      }
    }
    s.detections = parseDetections(buf.toString());
    yield DetectionsEvent(s.detections, sw.elapsedMilliseconds / 1000);
  }

  Future<Map<String, dynamic>?> _scene(Session s) async {
    if (brain == null || !brainHasVision) return null;
    final msgs = LlmClient.visionMessages(s.imageDataUrl!, promptScene);
    return brain!.json(msgs, sceneSchema, maxTokens: 120).timeout(const Duration(seconds: 25), onTimeout: () => null);
  }

  Future<(bool?, List<Detection>)> _verify(Session s, String key) async {
    final name = displayName(key);
    final prompt = (eyesFineTuned ? promptVerify : promptVerifyZeroshot).replaceAll('{name}', name);
    final raw = await eyes!.chat(LlmClient.visionMessages(s.imageDataUrl!, prompt), maxTokens: 200, sampling: visionSampling);
    final (present, boxes) = parseVerify(raw);
    final added = <Detection>[];
    for (final b in boxes) {
      if (s.detections.any((d) => d.key == key && iou(d.box, b) > .5)) continue;
      final d = Detection(key: key, label: name, rawLabel: name, box: b);
      s.detections.add(d);
      added.add(d);
    }
    if (added.isNotEmpty) s.detections = number(s.detections);
    return (present, added);
  }

  // --------------------------------------------------------------- niat
  Future<Intent> _intent(String text) async {
    final rule = ruleIntent(text);
    final plain = rule.action == 'rekomendasi' && rule.maxMinutes == null && rule.tags.isEmpty && rule.exclude.isEmpty && rule.include.isEmpty;
    if (!useLlmIntent || brain == null || !plain || text.split(' ').length < 4) return rule;
    final llm = await brain!.json([
      {'role': 'system', 'content': promptIntentSystem},
      {'role': 'user', 'content': text},
    ], intentSchema).timeout(const Duration(seconds: 8), onTimeout: () => null);
    if (llm == null) return rule;
    final a = llm['action'];
    if (a is String && ['rekomendasi', 'hidangan', 'ganti', 'pilih', 'detail', 'substitusi', 'cek', 'obrolan'].contains(a)) rule.action = a;
    if (llm['max_minutes'] is int) rule.maxMinutes = llm['max_minutes'];
    for (final x in (llm['exclude'] as List?) ?? []) {
      final k = resolve('$x');
      if (k != null) rule.exclude.add(k);
    }
    for (final x in (llm['include'] as List?) ?? []) {
      final k = resolve('$x');
      if (k != null) rule.include.add(k);
    }
    rule.ingredient ??= llm['ingredient'] as String?;
    if (llm['choice'] is int) rule.choice ??= llm['choice'];
    return rule;
  }

  void _applyPrefs(Session s, Intent it) {
    final p = s.prefs;
    if (it.maxMinutes != null) p.maxMinutes = it.maxMinutes;
    p.tags.addAll(it.tags);
    p.exclude.addAll(it.exclude);
    p.include
      ..addAll(it.include)
      ..removeAll(p.exclude);
    if (p.exclude.contains('chili')) p.tags.remove('pedas');
  }

  void _rerank(Session s, {required bool skipShown}) {
    final have = {...s.have(), if (s.mode == 'hidangan') ...s.dishGuess};
    s.candidates = rank(recipes, have, s.prefs, skip: skipShown ? s.shown.toSet() : const {}, k: 3);
    if (s.mode == 'hidangan' && s.dish != null && !skipShown) {
      final named = findRecipe(recipes, s.dish!);
      if (named != null) {
        s.candidates.removeWhere((m) => m.recipe.id == named.id);
        final found = rank([named], have, Prefs(), k: 1);
        s.candidates.insert(0, found.isNotEmpty ? found.first : Match(named, 0, [], []));
        if (s.candidates.length > 3) s.candidates = s.candidates.sublist(0, 3);
      }
    }
    if (s.candidates.isEmpty && skipShown && s.shown.isNotEmpty) {
      s.shown.clear();
      s.candidates = rank(recipes, have, s.prefs, k: 3);
    }
    s.current = s.candidates.firstOrNull?.recipe.id;
    if (s.current != null && !s.shown.contains(s.current)) s.shown.add(s.current!);
  }

  // ------------------------------------------------------------ giliran
  Stream<MeiraEvent> turn(Session s, {String text = '', String? imageDataUrl, String mode = 'otomatis'}) async* {
    text = text.trim();
    if (text.isNotEmpty || imageDataUrl != null) {
      await history.addMessage(s.id, 'user', text.isEmpty ? '(foto)' : text, {'photo': imageDataUrl != null});
    }
    if (imageDataUrl != null) {
      s
        ..imageDataUrl = imageDataUrl
        ..detections = []
        ..shown = []
        ..candidates = []
        ..current = null
        ..dish = null
        ..dishGuess = [];
      yield StatusEvent('Melihat foto');
      Future<Map<String, dynamic>?>? sceneFuture = mode != 'bahan' && parallelVision ? _scene(s) : null;
      if (eyes == null) {
        yield ErrorEvent('Model penglihatan belum siap');
      } else {
        try {
          yield* _detect(s);
        } catch (e) {
          yield ErrorEvent('Gagal membaca foto: $e');
        }
      }
      final sc = await (sceneFuture ?? (mode != 'bahan' ? _scene(s) : Future<Map<String, dynamic>?>.value(null)));
      s.mode = mode == 'otomatis' ? (sc?['jenis'] == 'hidangan' ? 'hidangan' : 'bahan') : mode;
      if (s.mode == 'hidangan' && sc != null) {
        final dish = (sc['hidangan'] as String?)?.trim();
        s.dish = dish == null || dish.isEmpty ? null : dish;
        s.dishGuess = [for (final x in (sc['bahan_utama'] as List?) ?? []) ?resolve('$x')];
      }
      yield SceneEvent(s.mode, s.dish);
    }

    final it = text.isNotEmpty ? await _intent(text) : Intent(imageDataUrl != null && s.mode == 'hidangan' ? 'hidangan' : 'rekomendasi');
    if (imageDataUrl != null && s.mode == 'hidangan' && it.action == 'rekomendasi') it.action = 'hidangan';
    _applyPrefs(s, it);
    var task = it.action;
    final extra = <String, String>{};

    if (it.action == 'cek') {
      yield* _check(s, text, it);
      await _persist(s);
      return;
    }
    // foto bahan tanpa satu pun bahan yang dikenali: jangan menyarankan resep tebakan
    final known = s.detections.where((d) => d.key != null).length;
    if (imageDataUrl != null && s.mode == 'bahan' && known == 0 && s.prefs.include.isEmpty) {
      final n = s.detections.length;
      final msg = n == 0
          ? 'Aku belum melihat bahan dengan jelas di foto ini. Coba foto lebih dekat dengan cahaya cukup, atau sebutkan bahan yang kamu punya.'
          : 'Aku melihat $n benda (${n == 1 ? '#1' : '#1 sampai #$n'}) tapi belum yakin jenis bahannya. Sebutkan bahannya, misalnya "itu apel dan pisang", atau coba foto lebih dekat.';
      yield TokenEvent(msg);
      await _remember(s, text.isEmpty ? '(foto baru)' : text, msg, 'templat');
      yield DoneEvent(msg, 'templat');
      await _persist(s);
      return;
    }
    switch (it.action) {
      case 'pilih':
        Recipe? chosen;
        if (it.choice != null && it.choice! >= 1 && it.choice! <= s.candidates.length) {
          chosen = s.candidates[it.choice! - 1].recipe;
        } else {
          chosen = findRecipe(recipes, text);
        }
        if (chosen != null) {
          if (!s.candidates.any((m) => m.recipe.id == chosen!.id)) {
            final found = rank([chosen], s.have(), Prefs(), k: 1);
            s.candidates.insert(0, found.isNotEmpty ? found.first : Match(chosen, 0, [], [for (final i in chosen.items) if (!i.optional && !pantry.contains(i.key)) i.key]));
          }
          s.current = chosen.id;
          task = 'detail';
        } else {
          _rerank(s, skipShown: false);
          task = 'rekomendasi';
        }
      case 'ganti':
        _rerank(s, skipShown: true);
        task = 'rekomendasi';
      case 'detail' || 'substitusi':
        if (s.currentMatch == null) _rerank(s, skipShown: false);
        if (it.action == 'substitusi') extra['ingredient'] = it.ingredient ?? 'bahan tersebut';
      case 'rekomendasi' || 'hidangan':
        _rerank(s, skipShown: false);
      default:
        if (s.candidates.isEmpty && (s.imageDataUrl != null || s.prefs.include.isNotEmpty)) _rerank(s, skipShown: false);
    }
    yield RecipesEvent();
    yield* _answer(s, text, task, extra);
    await _persist(s);
  }

  Stream<MeiraEvent> _check(Session s, String text, Intent it) async* {
    final names = mentions(text);
    if (names.isEmpty && it.ingredient != null) {
      final k = resolve(it.ingredient!);
      if (k != null) names.add(k);
    }
    String answer;
    if (s.imageDataUrl == null) {
      answer = 'Belum ada foto. Kirim foto bahanmu dulu, nanti aku periksa satu per satu.';
    } else if (names.isEmpty) {
      answer = 'Bahan apa yang mau dicek? Sebutkan namanya, misalnya: apakah ada wortel?';
    } else if (eyes == null) {
      answer = 'Model penglihatan belum siap, coba lagi sebentar.';
    } else {
      final lines = <String>[];
      for (final key in names.take(3)) {
        yield StatusEvent('Memeriksa ${displayName(key)}');
        final before = s.numbers()[key] ?? [];
        final (present, _) = await _verify(s, key);
        final nums = s.numbers()[key] ?? [];
        final name = displayName(key);
        if (nums.isNotEmpty) {
          final tag = nums.map((n) => '#$n').join(', ');
          lines.add(before.isNotEmpty ? 'Ya, ada $name di foto ($tag).' : 'Ya, ada $name. Sekarang sudah kutandai ($tag).');
        } else if (present == true) {
          lines.add('Sepertinya ada $name, tapi letaknya kurang jelas.');
        } else {
          lines.add('Aku tidak melihat $name di foto ini.');
        }
      }
      yield DetectionsEvent(s.detections, null);
      if (s.candidates.isNotEmpty) {
        _rerank(s, skipShown: false);
        yield RecipesEvent();
      }
      answer = lines.join(' ');
    }
    yield TokenEvent(answer);
    await _remember(s, text, answer, 'periksa');
    yield DoneEvent(answer, 'periksa');
  }

  Stream<MeiraEvent> _answer(Session s, String text, String task, Map<String, String> extra) async* {
    final user = context(s, task, extra) + (text.isNotEmpty ? '\n\nPERMINTAAN PENGGUNA: $text' : '');
    var full = '';
    final cur = s.currentMatch;
    final swapKnown = task == 'substitusi' && cur != null && cur.recipe.swaps.containsKey(resolve(extra['ingredient'] ?? '') ?? '');
    // jawaban dari buku resep: instan, akurat, dan tidak mengarang (dipakai default di HP)
    final fromBook = answerStyle == 'ringkas' && (task == 'rekomendasi' || task == 'detail' || swapKnown);
    if (brain != null && !fromBook) {
      final msgs = [
        {'role': 'system', 'content': promptBrainSystem},
        ...s.history.skip(math.max(0, s.history.length - llmTurns)),
        {'role': 'user', 'content': user},
      ];
      try {
        await for (final tok in brain!.stream(msgs, maxTokens: 380)) {
          full += tok;
          yield TokenEvent(tok);
        }
      } catch (e) {
        full = '';
      }
    }
    var source = 'llm';
    if (full.trim().isNotEmpty) full = fixRefs(full, s.detections);
    if (full.trim().isEmpty) {
      full = template(s, task, extra);
      source = 'templat';
    }
    await _remember(s, text.isEmpty ? '(foto baru)' : text, full, source);
    yield DoneEvent(full, source);
  }

  Future<void> _remember(Session s, String user, String answer, String source) async {
    s.history
      ..add({'role': 'user', 'content': user.length > 500 ? user.substring(0, 500) : user})
      ..add({'role': 'assistant', 'content': answer.length > 900 ? answer.substring(0, 900) : answer});
    if (s.history.length > llmTurns) s.history = s.history.sublist(s.history.length - llmTurns);
    await history.addMessage(s.id, 'assistant', answer, {'source': source, 'recipe': s.current});
  }

  Future<void> _persist(Session s) => history.saveSession(s.id, s.title(), s.toState());

  // -------------------------------------------------------------- konteks
  String _nums(List<int> ns) => ns.length <= 4 ? ns.map((n) => '#$n').join(' ') : '#${ns.first} sampai #${ns.last}';

  String _ingredientsLine(Session s) {
    if (s.imageDataUrl == null && s.detections.isEmpty) return 'tidak ada foto';
    if (s.detections.isEmpty) return 'tidak ada bahan yang terlihat jelas';
    return grouped(s.detections).map((g) => '${g.label} (${g.count.isEmpty ? '' : '${g.count}, '}${_nums(g.numbers)})').join('; ');
  }

  String _recipeBlock(Match m, Map<String, List<int>> nums, bool full, String mode) {
    final r = m.recipe;
    final items = r.items.map((it) {
      final mark = nums.containsKey(it.key)
          ? 'terlihat ${_nums(nums[it.key]!)}'
          : m.have.contains(it.key)
              ? 'dimiliki pengguna'
              : pantry.contains(it.key)
                  ? 'bumbu dasar'
                  : it.optional
                      ? 'opsional'
                      : (mode == 'hidangan' ? 'perkiraan, tidak terlihat' : 'PERLU DISIAPKAN');
      return '${it.name} ${it.amount} [$mark]';
    }).join('; ');
    var text = '${r.name} (${r.minutes} menit, ${r.servings} porsi, ${r.difficulty}). ${r.desc}\nBahan: $items';
    if (full) {
      text += '\nLangkah: ${[for (var i = 0; i < r.steps.length; i++) '${i + 1}. ${r.steps[i]}'].join(' ')}';
      if (r.tip.isNotEmpty) text += '\nTip: ${r.tip}';
    }
    return text;
  }

  static const _tasks = {
    'rekomendasi': 'Rekomendasikan RESEP TERPILIH dalam 3 sampai 5 kalimat: sebut bahan dari foto beserta nomornya, bahan yang perlu disiapkan, '
        'dan lama memasak. Sebut singkat KANDIDAT LAIN sebagai alternatif, lalu tawarkan untuk menjelaskan langkahnya.',
    'hidangan': 'Foto ini makanan jadi. Sebut perkiraan nama hidangannya, bahan yang TERLIHAT beserta nomornya, lalu bahan lain yang biasanya '
        'dipakai (sebut sebagai perkiraan). Bila ada RESEP TERPILIH yang cocok, pakai daftar bahannya dan tawarkan langkah membuatnya. Maksimal 5 kalimat.',
    'detail': 'Jelaskan cara membuat RESEP TERPILIH: sebut bahan yang perlu disiapkan, lalu langkah singkat bernomor.',
    'substitusi': 'Jawab bahan pengganti untuk {ingredient} dalam RESEP TERPILIH. Gunakan saran pengganti dari buku resep bila ada. Maksimal 3 kalimat.',
    'obrolan': 'Jawab permintaan pengguna dengan memakai konteks di atas. Maksimal 4 kalimat.',
  };

  String context(Session s, String task, Map<String, String> extra) {
    final nums = s.numbers();
    final cur = s.currentMatch;
    final others = s.candidates.where((m) => m != cur).toList();
    final p = s.prefs;
    final prefs = [
      if (p.maxMinutes != null) 'maksimal ${p.maxMinutes} menit',
      if (p.tags.isNotEmpty) 'suka: ${p.tags.join(', ')}',
      if (p.exclude.isNotEmpty) 'hindari: ${p.exclude.map(displayName).join(', ')}',
    ].join('; ');
    final rejected = s.shown.where((r) => r != s.current).toList();
    final names = {for (final r in recipes) r.id: r.name};
    final summary = [
      if (rejected.isNotEmpty) 'sudah ditawarkan sebelumnya: ${rejected.reversed.take(5).map((r) => names[r] ?? r).join(', ')}',
      if (s.dish != null) 'hidangan di foto (perkiraan): ${s.dish}',
    ].join('; ');
    final lines = [
      'JENIS FOTO: ${s.mode == 'hidangan' ? 'makanan jadi' : 'bahan'}',
      'DAFTAR BAHAN DI FOTO: ${_ingredientsLine(s)}',
      if (s.mode == 'hidangan') 'PERKIRAAN HIDANGAN: ${s.dish ?? 'tidak yakin'}; bahan perkiraan: ${s.dishGuess.isEmpty ? '-' : s.dishGuess.map(displayName).join(', ')}',
      'BAHAN TAMBAHAN MENURUT PENGGUNA: ${p.include.isEmpty ? '-' : p.include.map(displayName).join(', ')}',
      'PREFERENSI: ${prefs.isEmpty ? '-' : prefs}',
      'RINGKASAN SEBELUMNYA: ${summary.isEmpty ? '-' : summary}',
      'RESEP TERPILIH: ${cur != null ? _recipeBlock(cur, nums, task != 'rekomendasi', s.mode) : 'tidak ada resep di buku yang cocok'}',
      if (cur != null && cur.recipe.swaps.isNotEmpty) 'SARAN PENGGANTI: ${cur.recipe.swaps.entries.map((e) => '${displayName(e.key)} -> ${e.value}').join('; ')}',
      if (others.isNotEmpty) 'KANDIDAT LAIN: ${others.map((m) => '${m.recipe.name} (${m.recipe.minutes} menit)').join('; ')}',
      'TUGAS: ${_tasks[task]!.replaceAll('{ingredient}', extra['ingredient'] ?? '')}',
    ];
    return lines.join('\n');
  }

  String template(Session s, String task, Map<String, String> extra) {
    final cur = s.currentMatch;
    final nums = s.numbers();
    if (task == 'hidangan') {
      final seen = grouped(s.detections).where((g) => g.key != null).map((g) => '${g.label} (${g.numbers.map((n) => '#$n').join(', ')})').toList();
      var txt = s.dish != null ? 'Sepertinya ini ${s.dish}.' : 'Aku belum yakin nama hidangannya.';
      if (seen.isNotEmpty) txt += ' Yang terlihat: ${seen.join(', ')}.';
      if (cur != null) {
        final guess = [for (final i in cur.recipe.items) if (!nums.containsKey(i.key) && !i.optional && !pantry.contains(i.key)) i.name];
        return '$txt Menurut resep ${cur.recipe.name}, biasanya juga memakai ${guess.join(', ')} (perkiraan). Mau aku jelaskan cara membuatnya?';
      }
      if (s.dishGuess.isNotEmpty) txt += ' Bahan yang biasanya dipakai (perkiraan): ${s.dishGuess.map(displayName).join(', ')}.';
      return txt;
    }
    if (cur == null) return 'Aku belum menemukan resep yang cocok di buku. Coba foto lain, sebutkan bahan yang kamu punya, atau longgarkan batas waktunya.';
    final r = cur.recipe;
    final seen = [for (final k in cur.have) if (nums.containsKey(k)) '${displayName(k)} (${nums[k]!.map((n) => '#$n').join(', ')})'];
    final missing = cur.missing.map(displayName).toList();
    if (task == 'detail') {
      final steps = [for (var i = 0; i < r.steps.length; i++) '${i + 1}. ${r.steps[i]}'].join(' ');
      return '${r.name}. ${missing.isNotEmpty ? 'Siapkan dulu: ${missing.join(', ')}. ' : ''}$steps';
    }
    if (task == 'substitusi') {
      final k = resolve(extra['ingredient'] ?? '');
      if (k != null && r.swaps.containsKey(k)) return 'Untuk ${r.name}, ${displayName(k)} bisa diganti ${r.swaps[k]}.';
      return 'Buku resep belum punya saran pengganti ${extra['ingredient']} untuk ${r.name}.';
    }
    var txt = 'Bagaimana kalau ${r.name}? Waktunya sekitar ${r.minutes} menit.';
    if (seen.isNotEmpty) txt += ' Dari foto sudah ada ${seen.join(', ')}.';
    if (missing.isNotEmpty) txt += ' Yang perlu disiapkan: ${missing.join(', ')}.';
    final others = [for (final m in s.candidates) if (m != cur) m.recipe.name];
    if (others.isNotEmpty) txt += ' Alternatifnya ${others.join(' atau ')}.';
    return '$txt Mau aku jelaskan langkahnya?';
  }
}

final _ref = RegExp(r'\s*\(?\s*(?:#|nomor\s+|no\.\s*)(\d+)(?:\s*(?:,|dan|-|–)\s*(?:#|nomor\s+)?\d+)*\s*\)?', caseSensitive: false);

/// Pertahankan rujukan nomor (#n) hanya bila nama bahan nomor itu memang disebut tepat sebelumnya,
/// lalu bersihkan label konteks yang bocor dan tanda pisah panjang.
String fixRefs(String text, List<Detection> detections) {
  final byNum = {for (final d in detections) d.number: d};
  bool ok(int n, String before) {
    final d = byNum[n];
    if (d == null) return false;
    final window = before.substring(math.max(0, before.length - 40)).toLowerCase();
    final names = {d.label.toLowerCase(), d.rawLabel.toLowerCase()};
    final ing = ingredients[d.key];
    if (ing != null) names.addAll([ing.nameId, ing.nameEn, ...ing.synonyms].map((e) => e.toLowerCase()));
    return names.any((x) => x.isNotEmpty && window.contains(x));
  }

  final out = StringBuffer();
  var last = 0;
  for (final m in _ref.allMatches(text)) {
    final nums = RegExp(r'\d+').allMatches(m.group(0)!).map((x) => int.parse(x.group(0)!)).toList();
    final keep = nums.where((n) => ok(n, text.substring(0, m.start))).toList();
    out.write(text.substring(last, m.start));
    final nextAlnum = m.end < text.length && RegExp(r'[A-Za-z0-9]').hasMatch(text[m.end]);
    if (keep.isNotEmpty) {
      out.write(' (${keep.map((n) => '#$n').join(', ')})');
      if (nextAlnum) out.write(' ');
    } else if (nextAlnum && m.start > 0 && RegExp(r'[A-Za-z0-9]').hasMatch(text[m.start - 1])) {
      out.write(' ');
    }
    last = m.end;
  }
  out.write(text.substring(last));
  var cleaned = out.toString()
      .replaceAll(RegExp(r'\bRESEP TERPILIH\b', caseSensitive: false), 'resep ini')
      .replaceAll(RegExp(r'\bKANDIDAT LAIN\b', caseSensitive: false), 'pilihan lain')
      .replaceAll(RegExp(r'\bDAFTAR BAHAN DI FOTO\b', caseSensitive: false), 'foto')
      .replaceAll(RegExp(r'\b(TUGAS|PREFERENSI|RINGKASAN SEBELUMNYA):?'), '')
      .replaceAll(RegExp(r'(?:(?<=[.!?])\s+|^)Tawarkan\b[^.!?\n]*[.!?]?', multiLine: true), '')
      .replaceAll(' — ', ', ')
      .replaceAll('—', ', ')
      .replaceAll(RegExp(r'[ \t]{2,}'), ' ');
  return cleaned.trim();
}
