/// Alur percakapan MEIRA di perangkat.
///
/// foto -> mata (VLM): bahan bernomor ┐
///      -> otak (visi): bahan atau makanan jadi? ┴-> buku resep -> otak (LLM) -> jawaban
/// teks atau suara pengguna: ganti resep, batas waktu, hindari bahan, cek bahan di foto.
library;

import 'dart:async';
import 'dart:math' as math;

import '../llm/chain.dart';
import '../llm/guardrails.dart';
import '../llm/knowledge.dart';
import '../llm/memory.dart';
import '../llm/retriever.dart';
import '../runtime/llama.dart';
import '../vision/ocr.dart';
import '../vision/vision.dart';
import 'generated.dart';
import 'body.dart';
import 'grounding.dart';
import 'health.dart';
import 'history.dart';
import 'recipes.dart';
import 'vocab.dart';

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
  Session(this.id, {int memoryBudget = 1100}) : memory = ConversationMemory(budgetTokens: memoryBudget);
  final String id;
  String? imageDataUrl; // foto yang sudah diperkecil untuk model (bawaan 768 px)
  String? imageDataUrlFlipped; // versi cermin untuk mode deteksi teliti
  String mode = 'bahan';
  String? dish;
  List<String> dishGuess = [];
  String? guess; // bahan utama menurut model penglihatan bila detektor tidak mengenalnya, misalnya buah naga
  List<Detection> detections = [];
  VisionInput? visionInput; // foto siap pakai untuk detektor dan OCR (tidak disimpan ke riwayat)
  VisionResult? visionResult;
  Prefs prefs = Prefs();
  List<String> shown = [];
  List<Match> candidates = [];
  String? current;
  ConversationMemory memory;

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
    final first = memory.turns.map((t) => t.user).where((u) => !u.startsWith('(')).firstOrNull ?? '';
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
    'memory': memory.toJson(),
    'summary': memory.summary,
  };

  static Session restore(String id, Map<String, dynamic> st, List<Recipe> recipes, {int memoryBudget = 1100}) {
    final s = Session(id, memoryBudget: memoryBudget)
      ..mode = st['mode'] ?? 'bahan'
      ..dish = st['dish']
      ..dishGuess = ((st['dish_guess'] as List?) ?? []).cast<String>()
      ..detections = [for (final d in (st['detections'] as List?) ?? []) Detection.fromJson(d)]
      ..prefs = Prefs.fromJson(st['prefs'])
      ..shown = ((st['shown'] as List?) ?? []).cast<String>()
      ..current = st['current'];
    s.memory.restore(st['memory'] as List?);
    s.memory.summary.addAll(((st['summary'] as List?) ?? []).cast<String>());
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
    this.useLlmIntent = false,
    this.answerStyle = 'ringkas',
    this.parallelVision = true,
    this.knowledge,
    this.readPackages = true,
    this.thorough = false,
    this.healthMode = false,
    this.needs,
    this.rewriteNotes = false,
    this.vision,
  });

  final List<Recipe> recipes;
  final History history;
  LlmClient? eyes; // cadangan bila detektor tidak tersedia: penglihatan bawaan model bahasa
  Vision? vision; // detektor bahan dan OCR kemasan yang terpisah dari model bahasa
  LlmClient? brain;
  bool eyesFineTuned; // format ringkas hasil fine-tune; selain itu prompt JSON bawaan Qwen
  bool brainHasVision;
  bool useLlmIntent;
  String answerStyle; // ringkas: rekomendasi dan langkah dari buku resep; natural: semua lewat LLM
  bool parallelVision; // false di HP: deteksi dulu agar penanda cepat tampil, baru kenali hidangan
  bool readPackages; // baca tulisan kemasan (mi instan, minyak, kecap, santan, ...)
  DailyNeeds? needs; // kebutuhan gizi harian dari kalkulator tubuh, bila pengguna mengisinya
  bool healthMode; // "enak dan sehat": resep ringan didahulukan dan jawaban resep diberi satu saran agar lebih ringan
  bool thorough; // deteksi teliti: foto asli + cermin digabung, recall lebih tinggi, waktu sekitar 2x
  late final RecipeRetriever retriever = RecipeRetriever(recipes);
  final KnowledgeBase? knowledge; // catatan dapur untuk RAG pertanyaan bebas
  /// Model merangkai ulang catatan dapur. Mati secara bawaan: pada evaluasi, model kecil masih menambah atau membalik
  /// fakta (lihat runs/brains/REPORT.md), sehingga catatan yang ditulis tangan langsung dipakai.
  bool rewriteNotes;
  String? userName; // nama panggilan pengguna, dipakai menyapa di jawaban pertama sebuah percakapan
  String lastDraft = ''; // jawaban mentah model sebelum diperiksa (untuk evaluasi perbandingan model)
  String lastNotes = ''; // catatan yang menjadi sumber jawaban terakhir

  // --------------------------------------------------------------- mata
  Stream<MeiraEvent> _detect(Session s) async* {
    final sw = Stopwatch()..start();
    if (vision != null && s.visionInput != null) {
      final res = await vision!.detect(s.visionInput!, thorough: thorough);
      s
        ..visionResult = res
        ..detections = res.detections;
      yield DetectionsEvent(s.detections, sw.elapsedMilliseconds / 1000);
      return;
    }
    final buf = StringBuffer();
    final partial = <Detection>[];
    var line = '';
    final prompt = eyesFineTuned ? promptGround : promptGroundZeroshot;
    await for (final tok in eyes!.stream(
      LlmClient.visionMessages(s.imageDataUrl!, prompt),
      maxTokens: 700,
      sampling: eyesFineTuned ? groundingSampling : visionSampling,
    )) {
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
    if (thorough && s.imageDataUrlFlipped != null) {
      // mode teliti: pandangan kedua dari foto cermin menangkap bahan yang terlewat
      yield PartialEvent(List.of(s.detections));
      final second = await eyes!.chat(
        LlmClient.visionMessages(s.imageDataUrlFlipped!, prompt),
        maxTokens: 700,
        sampling: eyesFineTuned ? groundingSampling : visionSampling,
      );
      s.detections = mergeViews(s.detections, flipBack(parseDetections(second)));
    }
    yield DetectionsEvent(s.detections, sw.elapsedMilliseconds / 1000);
  }

  /// Produk kemasan dikenali dari tulisan labelnya oleh model otak (visi), lalu diberi nomor seperti bahan lain.
  Future<List<Detection>> _packages(Session s) async {
    if (vision != null && s.visionInput != null) return packagesFromText(await vision!.read(s.visionInput!), s.detections);
    if (brain == null || !brainHasVision) return [];
    final res = await brain!
        .json(LlmClient.visionMessages(s.imageDataUrl!, promptPackages), packagesSchema, maxTokens: 260)
        .timeout(const Duration(seconds: 25), onTimeout: () => null);
    final out = <Detection>[];
    for (final p in (res?['kemasan'] as List?) ?? []) {
      if (p is! Map) continue;
      final key = resolve('${p['jenis'] ?? ''}') ?? resolve('${p['tulisan'] ?? ''}');
      final raw = p['bbox_2d'];
      if (key == null || raw is! List || raw.length != 4) continue;
      final box = normalizeBox([for (final v in raw) (v as num).toDouble()]);
      if (box == null || s.detections.any((d) => d.key == key && iou(d.box, box) > .4)) continue;
      out.add(Detection(key: key, label: displayName(key), rawLabel: '${p['tulisan']}', box: box, packaged: true));
    }
    return out;
  }

  /// Bahan kemasan dari tulisan labelnya (OCR): baris yang menyebut bahan atau merek dikenal menjadi satu penanda
  /// per kemasan. Baris berdekatan yang menyebut bahan sama digabung.
  static List<Detection> packagesFromText(List<TextLine> lines, List<Detection> existing) {
    final out = <Detection>[];
    for (final l in lines) {
      for (final key in mentions(l.text)) {
        final near = out.where((d) => d.key == key && (d.cx - (l.box[0] + l.box[2]) / 2).abs() < .3 && (d.cy - (l.box[1] + l.box[3]) / 2).abs() < .3);
        if (near.isNotEmpty) {
          final d = near.first;
          final box = [math.min(d.box[0], l.box[0]), math.min(d.box[1], l.box[1]), math.max(d.box[2], l.box[2]), math.max(d.box[3], l.box[3])];
          out[out.indexOf(d)] = Detection(key: key, label: d.label, rawLabel: '${d.rawLabel} ${l.text}', box: box, packaged: true);
          continue;
        }
        if (existing.any((d) => d.key == key && iou(d.box, l.box) > .3)) continue;
        out.add(Detection(key: key, label: displayName(key), rawLabel: l.text, box: l.box, packaged: true));
      }
    }
    return out;
  }

  Future<Map<String, dynamic>?> _scene(Session s) async {
    if (brain == null || !brainHasVision) return null;
    final msgs = LlmClient.visionMessages(s.imageDataUrl!, promptScene);
    return brain!.json(msgs, sceneSchema, maxTokens: 120).timeout(const Duration(seconds: 25), onTimeout: () => null);
  }

  /// Setelah pengguna mengoreksi penanda: susun ulang nomor dan cari ulang resep.
  Future<void> refresh(Session s) async {
    s.detections = number(s.detections);
    _rerank(s, skipShown: false);
    await _persist(s);
  }

  Future<(bool?, List<Detection>)> _verify(Session s, String key) async {
    final name = displayName(key);
    final vr = s.visionResult;
    if (vr != null) {
      // detektor sudah menyimpan semua kandidat; ambang verifikasi lebih rendah karena bahannya sudah disebut
      final added = vr.extra(key, s.detections);
      if (added.isNotEmpty) s.detections = number([...s.detections, ...added]);
      return (vr.present(key) || added.isNotEmpty, added);
    }
    final prompt = (eyesFineTuned ? promptVerify : promptVerifyZeroshot).replaceAll('{name}', name);
    final raw = await eyes!.chat(
      LlmClient.visionMessages(s.imageDataUrl!, prompt),
      maxTokens: 200,
      sampling: eyesFineTuned ? groundingSampling : visionSampling,
    );
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
    // pertanyaan dapur atau pertanyaan tentang sifat bahan dijawab sebagai obrolan, bukan rekomendasi resep
    if (rule.action == 'rekomendasi' && (Guardrails.smallTalk(text) || chatQuestion(text, knowledge))) return rule..action = 'obrolan';
    final plain = rule.action == 'rekomendasi' && rule.maxMinutes == null && rule.tags.isEmpty && rule.exclude.isEmpty && rule.include.isEmpty;
    if (!useLlmIntent || brain == null || !plain || text.split(' ').length < 4) return rule;
    final llm = await brain!
        .json([
          {'role': 'system', 'content': promptIntentSystem},
          {'role': 'user', 'content': text},
        ], intentSchema)
        .timeout(const Duration(seconds: 8), onTimeout: () => null);
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

  void _rerank(Session s, {required bool skipShown, String query = ''}) {
    s.prefs.healthy = healthMode || s.prefs.tags.contains('sehat');
    final have = {...s.have(), if (s.mode == 'hidangan') ...s.dishGuess};
    final skip = skipShown ? s.shown.toSet() : const <String>{};
    if (have.isEmpty && query.trim().isNotEmpty) {
      // tanpa bahan: cari resep lewat teks permintaan ("resep sup", "mau bikin sambal")
      final hits = retriever.search(query, k: 12).map((h) => h.recipe).where((r) => !skip.contains(r.id)).toList();
      if (hits.isNotEmpty) {
        s.candidates = rank(hits, const {}, s.prefs, k: 3);
        if (s.candidates.isNotEmpty) {
          s.current = s.candidates.first.recipe.id;
          if (!s.shown.contains(s.current)) s.shown.add(s.current!);
          return;
        }
      }
    }
    s.candidates = rank(recipes, have, s.prefs, skip: skip, k: 3);
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

  static final _rawGroups = RegExp(r'^(buah|buah-buahan|sayur|sayuran|sayur-mayur|aneka buah)$|^bahan\b');

  /// Foto tambahan dalam percakapan yang sama (misalnya isi kulkas lalu isi rak): bahan yang terlihat ditambahkan
  /// ke daftar bahan, lalu resep dicari ulang. Penanda tetap di foto utama.
  Stream<MeiraEvent> addPhoto(Session s, VisionInput input) async* {
    await history.addMessage(s.id, 'user', '(foto tambahan)', {'photo': true});
    if (vision == null) {
      yield ErrorEvent('Model penglihatan belum siap');
      return;
    }
    yield StatusEvent('Melihat foto tambahan');
    final res = await vision!.detect(input, thorough: thorough);
    final keys = {for (final d in res.detections) ?d.key};
    if (readPackages) keys.addAll({for (final d in packagesFromText(await vision!.read(input), const [])) ?d.key});
    final fresh = keys.difference(s.have());
    s.prefs.include.addAll(keys);
    String names(Iterable<String> ks) {
      final n = ks.map(displayName).toList();
      return n.length < 2 ? n.join() : '${n.sublist(0, n.length - 1).join(', ')} dan ${n.last}';
    }

    String msg;
    if (keys.isEmpty) {
      msg = 'Saya belum melihat bahan yang jelas di foto tambahan ini. Silakan foto lebih dekat, atau sebutkan bahannya.';
    } else if (fresh.isEmpty) {
      msg = 'Bahan di foto tambahan sudah tercatat: ${names(keys)}.';
    } else {
      _rerank(s, skipShown: false);
      yield RecipesEvent();
      msg = 'Saya tambahkan ${names(fresh)} dari foto ini. ${template(s, 'rekomendasi', const {})}';
    }
    yield TokenEvent(msg);
    await _remember(s, '(foto tambahan)', msg, 'templat');
    yield DoneEvent(msg, 'templat');
    await _persist(s);
  }

  // ------------------------------------------------------------ giliran
  Stream<MeiraEvent> turn(Session s, {String text = '', String? imageDataUrl, VisionInput? visionInput, String mode = 'otomatis'}) async* {
    text = text.trim();
    if (text.isNotEmpty || imageDataUrl != null) {
      await history.addMessage(s.id, 'user', text.isEmpty ? '(foto)' : text, {'photo': imageDataUrl != null});
    }
    if (imageDataUrl != null) {
      s
        ..imageDataUrl = imageDataUrl
        ..visionInput = visionInput
        ..visionResult = null
        ..detections = []
        ..shown = []
        ..candidates = []
        ..current = null
        ..dish = null
        ..dishGuess = []
        ..guess = null;
      yield StatusEvent('Melihat foto');
      Future<Map<String, dynamic>?>? sceneFuture = mode != 'bahan' && parallelVision ? _scene(s) : null;
      if (eyes == null && vision == null) {
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
      // nama hidangan yang hanya berupa golongan bahan ("buah", "sayur") berarti foto bahan mentah, bukan masakan
      final dishName = '${sc?['hidangan'] ?? ''}'.trim().toLowerCase();
      // ("bahan makanan yang belum dimasak" juga), meski detektor hanya menandai sedikit bahan
      if (mode == 'otomatis' &&
          s.mode == 'hidangan' &&
          (_rawGroups.hasMatch(dishName) || (dishName.isEmpty && s.detections.where((d) => d.key != null).length >= 2))) {
        s.mode = 'bahan';
      }
      if (s.mode == 'hidangan' && sc != null) {
        final dish = (sc['hidangan'] as String?)?.trim();
        s.dish = dish == null || dish.isEmpty ? null : dish;
        s.dishGuess = [for (final x in (sc['bahan_utama'] as List?) ?? []) ?resolve('$x')];
      }
      if (s.mode == 'bahan' && sc != null) s.guess = _guess(sc, s.detections);
      yield SceneEvent(s.mode, s.dish);
      if (s.mode == 'bahan' && readPackages) {
        yield StatusEvent('Membaca kemasan');
        final pkg = await _packages(s);
        if (pkg.isNotEmpty) {
          s.detections = number([...s.detections, ...pkg]);
          yield DetectionsEvent(s.detections, null);
        }
      }
    }

    // koreksi pengguna atas isi foto ("ini buah naga", "bukan kepiting, tapi buah naga")
    final fixed = imageDataUrl == null && s.imageDataUrl != null ? correction(text) : null;
    // hanya nama makanan yang dikenal (kosakata atau basis pengetahuan); "ini enak" bukan koreksi
    if (fixed != null && (mentions(fixed).isNotEmpty || knowledge?.named(fixed) != null)) {
      yield* _correct(s, text, fixed);
      await _persist(s);
      return;
    }
    if (text.isNotEmpty && imageDataUrl == null) {
      // dalam sesi yang sudah punya foto atau resep, permintaan lanjutan seperti "aku mau yang cepat" tetap soal dapur
      final inContext = s.imageDataUrl != null || s.current != null;
      final guard = Guardrails.checkInput(text, knownIngredient: inContext || Guardrails.kitchenRequest(text), ragScore: ragScore(text));
      if (!guard.allowed) {
        yield TokenEvent(guard.reply);
        await _remember(s, text, guard.reply, 'pengaman');
        yield DoneEvent(guard.reply, 'pengaman');
        await _persist(s);
        return;
      }
    }
    final it = text.isNotEmpty ? await _intent(text) : Intent(imageDataUrl != null && s.mode == 'hidangan' ? 'hidangan' : 'rekomendasi');
    if (imageDataUrl != null && s.mode == 'hidangan' && it.action == 'rekomendasi') it.action = 'hidangan';
    // pertanyaan gizi ("mi instan masih cocok untuk saya?", "berapa kalori nasi goreng?") dijawab dari fakta gizi,
    // bukan dengan rekomendasi resep
    if (it.action == 'rekomendasi' && _nutritionQuestion.hasMatch(text.toLowerCase())) it.action = 'obrolan';
    // "buah naga bisa dibuat apa?": makanan yang tidak ada di kosakata maupun nama resep dijawab dari fakta, bukan
    // dengan resep acak yang kebetulan berbagi kata
    if (it.action == 'rekomendasi' &&
        it.include.isEmpty &&
        mentions(text).isEmpty &&
        findRecipe(recipes, text) == null &&
        (knowledge?.link(text).isNotEmpty ?? false)) {
      it.action = 'obrolan';
    }
    // "kue cubit dibuat dari apa?" tanpa foto, atau menyebut makanan yang ada di basis pengetahuan, adalah pertanyaan
    // pengetahuan, bukan permintaan menebak hidangan di foto
    if (it.action == 'hidangan' && imageDataUrl == null && (s.imageDataUrl == null || (knowledge?.link(text).isNotEmpty ?? false))) {
      it.action = 'obrolan';
    }
    // bahan yang baru disebut lewat ketikan ("ada telur juga") diakui di awal jawaban
    final added = it.include.difference(s.have());
    _applyPrefs(s, it);
    var task = it.action;
    final extra = <String, String>{if (added.isNotEmpty) 'added': added.map(displayName).join(', ')};

    if (it.action == 'cek') {
      yield* _check(s, text, it);
      await _persist(s);
      return;
    }
    // foto bahan tanpa satu pun bahan yang dikenali: jangan menyarankan resep tebakan
    final known = s.detections.where((d) => d.key != null).length;
    if (imageDataUrl != null && s.mode == 'bahan' && s.guess != null) {
      final key = resolve(s.guess!);
      if (known == 0 && key != null) {
        // bahan yang ada di buku resep tetapi terlewat detektor: dipakai sebagai bahan milik pengguna
        s.prefs.include.add(key);
        extra['guess'] = 'Detektor belum menandai bahan ini, tetapi tampaknya ini ${s.guess}.';
      } else if (known == 0) {
        yield* _guessed(s, text, s.guess!);
        await _persist(s);
        return;
      } else if (key == null && text.isEmpty && s.detections.map((d) => d.key).whereType<String>().toSet().length == 1) {
        // detektor dan model penglihatan tidak sepakat (buah naga ditandai sebagai artichoke): sebut keduanya
        final g = grouped(s.detections).firstWhere((g) => g.key != null);
        yield* _guessed(s, text, s.guess!, marked: '${g.label} (${g.numbers.map((n) => '#$n').join(', ')})');
        await _persist(s);
        return;
      }
    }
    if (imageDataUrl != null && s.mode == 'bahan' && known == 0 && s.prefs.include.isEmpty) {
      final n = s.detections.length;
      final msg = n == 0
          ? 'Mohon maaf, saya belum dapat melihat bahan dengan jelas di foto ini. Silakan foto lebih dekat dengan cahaya yang cukup, atau sebutkan bahan yang Anda miliki.'
          : 'Saya melihat $n benda (${n == 1 ? '#1' : '#1 sampai #$n'}), tetapi belum yakin jenis bahannya. Silakan sebutkan bahannya, misalnya "itu apel dan pisang", atau foto lebih dekat.';
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
            s.candidates.insert(
              0,
              found.isNotEmpty
                  ? found.first
                  : Match(chosen, 0, [], [
                      for (final i in chosen.items)
                        if (!i.optional && !pantry.contains(i.key)) i.key,
                    ]),
            );
          }
          s.current = chosen.id;
          task = 'detail';
        } else {
          _rerank(s, skipShown: false);
          task = 'rekomendasi';
        }
      case 'ganti':
        _rerank(s, skipShown: true, query: text);
        task = 'rekomendasi';
      case 'detail' || 'substitusi':
        if (s.currentMatch == null) _rerank(s, skipShown: false);
        if (it.action == 'substitusi') extra['ingredient'] = it.ingredient ?? 'bahan tersebut';
      case 'rekomendasi' || 'hidangan':
        _rerank(s, skipShown: false, query: text);
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
      answer = 'Belum ada foto. Silakan kirim foto bahan Anda terlebih dahulu, lalu saya periksa satu per satu.';
    } else if (names.isEmpty) {
      answer = 'Bahan apa yang ingin diperiksa? Silakan sebutkan namanya, misalnya: apakah ada wortel?';
    } else if (eyes == null && s.visionResult == null) {
      answer = 'Model penglihatan belum siap. Mohon coba lagi sebentar.';
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
          lines.add(before.isNotEmpty ? 'Benar, ada $name di foto ($tag).' : 'Benar, ada $name. Sekarang sudah saya tandai ($tag).');
        } else if (present == true) {
          lines.add('Tampaknya ada $name, tetapi letaknya kurang jelas.');
        } else {
          lines.add('Saya tidak melihat $name di foto ini.');
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
    final cur = s.currentMatch;
    final swapKnown = task == 'substitusi' && cur != null && cur.recipe.swaps.containsKey(resolve(extra['ingredient'] ?? '') ?? '');
    // Fakta selalu dari buku resep (nama resep, bahan bernomor, langkah, pengganti yang tercatat).
    final grounded = cur != null && (task == 'rekomendasi' || task == 'detail' || task == 'hidangan' || swapKnown);
    if (grounded) {
      var core = greet(s, template(s, task, extra));
      if (extra['added'] != null) core = 'Baik, ${extra['added']} saya catat. $core';
      if (extra['guess'] != null) core = '${extra['guess']} $core';
      if (extra['fixed'] != null) core = '${extra['fixed']} $core';
      // mode enak dan sehat: satu saran agar resep lebih ringan, dari pedoman umum (lihat core/health.dart)
      if ((healthMode || s.prefs.tags.contains('sehat')) && (task == 'rekomendasi' || task == 'ganti')) {
        final tip = healthTip(cur.recipe);
        if (tip.isNotEmpty) core = core.replaceFirst(RegExp(r' Apakah Anda ingin'), ' $tip Apakah Anda ingin');
      }
      var source = 'templat';
      if (answerStyle == 'natural' && brain != null && task != 'detail') {
        // gaya natural: model menulis ulang jawaban buku resep menjadi kalimat lisan; hasilnya dipakai hanya bila semua
        // nama, nomor, dan angka tetap ada dan tidak ada bahan atau angka baru
        yield StatusEvent('Menyusun jawaban');
        final natural = await _naturalize(text, core);
        if (natural != null) {
          core = natural;
          source = 'llm';
        }
      }
      yield TokenEvent(core);
      await _remember(s, text.isEmpty ? '(foto baru)' : text, core, source);
      yield DoneEvent(core, source);
      return;
    }
    // permintaan resep tanpa resep yang cocok (misalnya bahan di foto tidak punya resep di bawah 15 menit): jangan
    // biarkan model mengarang resep lain, cukup katakan terus terang dan sarankan longgarkan syaratnya
    if (cur == null && const {'rekomendasi', 'ganti', 'pilih', 'detail'}.contains(task) && (s.imageDataUrl != null || s.have().isNotEmpty)) {
      final answer = template(s, task, extra);
      yield TokenEvent(answer);
      await _remember(s, text.isEmpty ? '(foto baru)' : text, answer, 'templat');
      yield DoneEvent(answer, 'templat');
      return;
    }
    // pertanyaan pengetahuan dapur yang cocok kuat dengan sebuah catatan: faktanya dari catatan itu. Catatan yang
    // tidak menyebut bahan yang ditanyakan dilewati, misalnya soal apel tidak dijawab dengan catatan tentang telur.
    final asked = mentions(text).toSet();
    final notes = [
      for (final n in knowledge?.search(text, k: 2) ?? const <(Note, double, int)>[])
        if (asked.isEmpty || mentions('${n.$1.title} ${n.$1.body}').any(asked.contains)) n,
    ];
    // Catatan disalin apa adanya hanya bila meliput sebagian besar kata pertanyaan ("berapa lama merebus telur").
    // Catatan yang hanya berbagi satu dua kata, misalnya soal menyimpan pisang untuk pertanyaan beda pisang ambon dan
    // kepok, tidak dipakai sebagai jawaban; model menjawab sendiri dengan catatan yang cukup dekat sebagai rujukan.
    final terms = knowledge?.termCount(text) ?? 0;
    double cover((Note, double, int) n) => terms == 0 ? 0 : n.$3 / terms;
    bool titled((Note, double, int) n) => knowledge!.titleShares(n.$1, text);
    // pertanyaan tentang isi foto ("ini buah apa?") dijawab dari foto, bukan dari catatan yang kebetulan berbagi kata
    final linked = knowledge?.link(text) ?? const <Fact>[];
    final aboutPhoto = s.imageDataUrl != null && linked.isEmpty && RegExp(r'\b(ini|itu|foto|gambar)\b').hasMatch(text.toLowerCase());
    final strong = aboutPhoto
        ? <(Note, double, int)>[]
        : notes.where((n) => (n.$3 >= 2 || n.$2 >= Guardrails.ragThreshold) && cover(n) >= .6 && titled(n)).toList();
    final related = aboutPhoto ? <(Note, double, int)>[] : notes.where((n) => titled(n) && cover(n) >= .3).toList();
    // pengganti bahan yang tidak ada di resep terpilih juga dijawab dari catatan ("kalau tidak ada mentega, pakai apa?")
    final offRecipe = task == 'substitusi' && !(cur?.recipe.items.any((i) => i.key == resolve(extra['ingredient'] ?? '')) ?? false);
    if ((task == 'obrolan' || offRecipe) && strong.isNotEmpty) {
      final (answer, source) = await _fromNotes(text, strong.map((n) => n.$1).toList());
      yield TokenEvent(answer);
      await _remember(s, text, answer, source);
      yield DoneEvent(answer, source);
      return;
    }
    if (task == 'obrolan' && aboutPhoto && s.guess != null) {
      yield* _guessed(s, text, s.guess!);
      return;
    }
    if (task == 'obrolan' && brain != null) {
      // RAG: catatan dapur yang cukup dekat ditambah fakta Wikidata dan USDA untuk makanan yang disebut namanya
      final facts = [
        for (final n in related.take(2)) 'Catatan dapur "${n.$1.title}": ${n.$1.body}',
        for (final f in linked) f.text,
        // perbandingan dengan kebutuhan harian pengguna sudah dihitung di sini; model cukup menyampaikannya
        if (needs != null)
          for (final f in linked.where((f) => f.nutrition)) ?compareWithNeeds(f.title, f.text, needs!),
        if (needs != null && _personal.hasMatch(text.toLowerCase())) needs!.factLine,
      ];
      yield* _chat(s, text, facts, photo: aboutPhoto || linked.isEmpty);
      return;
    }
    var prompt = context(s, task, extra);
    // RAG: pertanyaan bebas dan pengganti bahan dijawab berpijak pada catatan dapur dan buku resep
    if (notes.isNotEmpty) prompt += '\nPENGETAHUAN DAPUR:\n${notes.map((n) => '- ${n.$1.title}: ${n.$1.body}').join('\n')}';
    final refs = retriever.search(text, k: notes.isEmpty ? 3 : 1);
    if (refs.isNotEmpty) prompt += '\nREFERENSI BUKU RESEP:\n${refs.map((h) => _reference(h.recipe)).join('\n')}';
    if (text.isNotEmpty) prompt += '\n\nPERMINTAAN PENGGUNA: $text';
    var full = '';
    if (brain != null) {
      final chain = AnswerChain(brain!);
      try {
        await for (final piece in chain.run(system: promptBrainSystem, memory: s.memory.window(), prompt: prompt)) {
          full += piece;
          yield TokenEvent(piece);
        }
      } catch (e) {
        full = '';
      }
    }
    var source = 'llm';
    if (full.trim().isNotEmpty) full = Guardrails.checkOutput(fixRefs(full, s.detections));
    full = completeSentences(full);
    // penjelasan berputar atau kosong: pakai catatan dapur yang relevan bila ada
    if ((full.trim().isEmpty || Guardrails.isCircular(full)) && notes.isNotEmpty) {
      full = notes.first.$1.body;
      source = 'catatan';
    }
    if (full.trim().isEmpty) {
      full = template(s, task, extra);
      source = 'templat';
    }
    await _remember(s, text.isEmpty ? '(foto baru)' : text, full, source);
    yield DoneEvent(full, source);
  }

  /// Obrolan bebas: sapaan, ucapan terima kasih, dan pertanyaan pengetahuan dapur. Model 0,8B diberi perintah pendek dan
  /// konteks seperlunya, karena perintah resep yang panjang membuatnya melantur, menjelaskan rencananya sendiri, dan
  /// mengarang resep. Catatan dapur yang relevan disertakan sebagai rujukan (RAG), bukan disalin mentah.
  Stream<MeiraEvent> _chat(Session s, String text, List<String> facts, {bool photo = true}) async* {
    // pertanyaan fakta tanpa sumber tidak diserahkan ke model kecil, karena ia akan mengarang dengan yakin
    if (facts.isEmpty && !Guardrails.smallTalk(text) && ingredientQuestion(text)) {
      const answer =
          'Maaf, saya belum punya informasi yang pasti tentang itu. Saya bisa membantu memilih resep dari bahan yang ada, '
          'menjelaskan cara memasaknya, atau menjawab pertanyaan tentang bahan dan hidangan yang saya kenal.';
      yield TokenEvent(answer);
      await _remember(s, text, answer, 'pengaman');
      yield DoneEvent(answer, 'pengaman');
      return;
    }
    // isi foto dan resep yang sedang dibahas hanya disertakan bila pertanyaannya tentang foto; untuk "beda kepiting
    // dan udang" baris itu ikut diulang model dan membuat jawaban panjang
    final context = [
      if (photo && s.detections.isNotEmpty) 'Bahan di foto pengguna: ${grouped(s.detections).map((g) => g.label).join(', ')}.',
      if (photo && s.guess != null) 'Foto pengguna tampaknya berisi ${s.guess} (dugaan model penglihatan).',
      if (photo && s.currentMatch != null) 'Resep yang sedang dibahas: ${s.currentMatch!.recipe.name}.',
      ...facts,
    ];
    final name = userName?.trim() ?? '';
    final system = name.isEmpty ? promptChatSystem : '$promptChatSystem Nama pengguna: $name.';
    final user = context.isEmpty ? text : 'FAKTA:\n${context.join('\n')}\n\nPertanyaan: $text';
    var full = '';
    try {
      await for (final piece in brain!.stream(
        [
          // tanpa riwayat: adaptor dilatih dengan satu pertanyaan dan faktanya, dan dengan riwayat model kecil cenderung
          // menyalin jawaban sebelumnya
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': user},
        ],
        maxTokens: 200,
        sampling: chatSampling,
        extra: brain!.chatAdapter,
      )) {
        full += piece;
        yield TokenEvent(piece);
      }
    } catch (_) {
      // aliran terputus atau terlalu lama diam: pakai kalimat utuh yang sudah diterima
    }
    full = completeSentences(Guardrails.checkOutput(full));
    var source = 'llm';
    if (full.isEmpty) {
      full = 'Maaf, saya belum bisa menjawab itu. Silakan tanyakan hal lain seputar bahan, resep, atau cara memasak.';
      source = 'templat';
    }
    await _remember(s, text, full, source);
    yield DoneEvent(full, source);
  }

  /// Skor kecocokan tertinggi pertanyaan dengan buku resep atau catatan dapur (untuk guardrail topik).
  /// Kecocokan satu kata saja (mis. "besok", "kali") tidak dihitung sebagai bukti topik dapur.
  double ragScore(String text) {
    final r = retriever.search(text, k: 1, minScore: 0).where((h) => h.matched >= 2);
    final n = (knowledge?.search(text, k: 1, minScore: 0) ?? const []).where((h) => h.$3 >= 2);
    return [...r.map((h) => h.score), ...n.map((h) => h.$2), 0.0].reduce((a, b) => a > b ? a : b);
  }

  /// Jawaban dari catatan dapur. Gaya natural: model merangkai ulang catatan untuk menjawab pertanyaan, lalu
  /// jawabannya diperiksa (tanpa angka atau isi baru, tidak berputar); bila tidak lolos, catatannya yang dipakai.
  Future<(String, String)> _fromNotes(String text, List<Note> notes) async {
    final plain = notes.first.body;
    lastDraft = '';
    if (!rewriteNotes || brain == null) return (plain, 'catatan');
    final source = notes.map((n) => '- ${n.title}: ${n.body}').join('\n');
    lastNotes = source;
    try {
      var out = await AnswerChain(
        brain!,
      ).complete(system: promptBrainSystem, prompt: 'CATATAN DAPUR:\n$source\n\nPERTANYAAN: $text\n\nTUGAS: $promptNoteTask');
      lastDraft = out;
      out = Guardrails.checkOutput(out);
      if (out.isNotEmpty && !Guardrails.isCircular(out) && Guardrails.supported(out, source, question: text)) return (out, 'llm');
    } catch (_) {}
    return (plain, 'catatan');
  }

  /// Gaya natural: model menulis ulang jawaban buku resep menjadi kalimat lisan. Mengembalikan null bila tulisan ulang
  /// tidak lolos [naturalMatches], sehingga jawaban buku resep yang dipakai.
  Future<String?> _naturalize(String text, String core) async {
    try {
      final out = await brain!.chat(
        [
          {'role': 'system', 'content': promptParaphraseSystem},
          {'role': 'user', 'content': '${text.isEmpty ? 'Pengguna mengirim foto bahan.' : 'Permintaan pengguna: $text'}\nTEKS: $core'},
        ],
        maxTokens: 220,
        sampling: chatSampling,
        extra: brain!.chatAdapter,
      );
      final line = out.trim().replaceAll(RegExp(r'[—–]'), ',');
      if (!naturalMatches(core, line, recipes.map((r) => r.name))) return null;
      // makanan dari permintaan pengguna yang tidak ada di jawaban buku resep ("Kepiting Saus Tiram cocok untuk buah
      // naga") ditolak
      final foods = {for (final f in knowledge?.link(core, max: 12) ?? const <Fact>[]) f.title};
      return (knowledge?.link(line, max: 12) ?? const <Fact>[]).every((f) => foods.contains(f.title)) ? line : null;
    } catch (_) {
      return null;
    }
  }

  /// Koreksi pengguna atas isi foto. Bila foto hanya punya satu kelompok penanda, penanda itu diganti namanya; bila
  /// lebih, bahan yang disebut dicatat sebagai bahan milik pengguna. Bahan yang ada di buku resep langsung dipakai
  /// untuk mencari resep; makanan lain (misalnya buah naga) dijelaskan dari basis pengetahuan.
  Stream<MeiraEvent> _correct(Session s, String text, String name) async* {
    // nama persis dari kosakata saja; pencocokan kabur bisa mengubah "buah naga" menjadi bahan lain
    final keys = mentions(name);
    final key = keys.length == 1 ? keys.first : null;
    final label = key != null ? displayName(key) : (knowledge?.named(name)?.title.toLowerCase() ?? name);
    final groups = grouped(s.detections).where((g) => g.label != label).toList();
    var note = 'Baik, ini $label.';
    if (key != null && s.detections.any((d) => d.key == key)) {
      note = 'Baik, $label memang sudah saya tandai.';
    } else if (groups.length == 1) {
      final wrong = groups.first;
      s.detections = [
        for (final d in s.detections)
          wrong.numbers.contains(d.number)
              ? Detection(key: key, label: label, rawLabel: label, box: d.box, number: d.number, group: d.group, packaged: d.packaged)
              : d,
      ];
      note = 'Baik, ini $label. Penanda ${wrong.numbers.map((n) => '#$n').join(', ')} sudah saya ubah dari ${wrong.label}.';
    } else if (key != null) {
      s.prefs.include.add(key);
      note = 'Baik, $label saya catat sebagai bahan Anda.';
    }
    s.guess = key == null ? label : null;
    yield DetectionsEvent(s.detections, null);
    if (key == null) {
      s
        ..candidates = []
        ..current = null;
      yield RecipesEvent();
      yield* _guessed(s, text, label, fixed: note);
      return;
    }
    _rerank(s, skipShown: false);
    yield RecipesEvent();
    yield* _answer(s, text, 'rekomendasi', {'fixed': note});
  }

  /// Nama bahan utama menurut model penglihatan, dalam bahasa Indonesia bila dikenal ("dragon fruit" menjadi buah
  /// naga). Nama yang tidak ada di kosakata maupun basis pengetahuan tidak dipercaya, dan nama yang sudah ditandai
  /// detektor tidak perlu disebut lagi.
  String? _guess(Map<String, dynamic> sc, List<Detection> dets) {
    final items = [for (final x in (sc['bahan_utama'] as List?) ?? const []) '$x'.trim()]..removeWhere((x) => x.isEmpty);
    if (items.isEmpty) return null;
    final key = resolve(items.first);
    if (key != null) return dets.any((d) => d.key == key) ? null : displayName(key);
    return knowledge?.named(items.first)?.title.toLowerCase();
  }

  /// Foto bahan yang tidak dikenali detektor tetapi dikenali model penglihatan, misalnya buah naga: sebut dugaannya,
  /// jelaskan singkat dari basis pengetahuan, lalu minta bahan lain untuk mencari resep.
  Stream<MeiraEvent> _guessed(Session s, String text, String name, {String? marked, String? fixed}) async* {
    final fact = knowledge?.named(name);
    final facts = [
      for (final n in knowledge?.search(name, k: 1) ?? const <(Note, double, int)>[])
        if (knowledge!.titleShares(n.$1, name)) 'Catatan dapur "${n.$1.title}": ${n.$1.body}',
      if (fact != null) fact.text,
    ];
    var about = '';
    if (facts.isNotEmpty && brain != null) {
      yield StatusEvent('Mencari keterangan $name');
      try {
        final out = await brain!.chat(
          [
            {'role': 'system', 'content': promptChatSystem},
            {'role': 'user', 'content': 'FAKTA:\n${facts.join('\n')}\n\nPertanyaan: $name itu apa?'},
          ],
          maxTokens: 120,
          sampling: chatSampling,
          extra: brain!.chatAdapter,
        );
        about = completeSentences(Guardrails.checkOutput(out));
        if (Guardrails.isCircular(about) || RegExp(r'belum punya informasi', caseSensitive: false).hasMatch(about)) about = '';
      } catch (_) {}
    }
    final answer = [
      if (fixed != null)
        fixed
      else if (marked == null)
        'Tampaknya ini $name. Bahan ini belum bisa ditandai oleh detektor, jadi namanya masih dugaan model penglihatan.'
      else
        'Saya belum yakin dengan foto ini. Detektor menandai $marked, tetapi model penglihatan menduga ini $name.',
      if (about.isNotEmpty) about,
      if (fixed != null)
        'Buku resep MEIRA belum punya resep dengan $name. Bila ingin saran resep, sebutkan bahan lain yang Anda miliki.'
      else if (marked == null)
        'Bila ingin saran resep, sebutkan bahan lain yang Anda miliki, misalnya "ada susu dan madu".'
      else
        'Bila penanda detektor benar, minta saja saran resep dan saya carikan dari bahan itu. Bila salah, ketik misalnya "ini $name".',
    ].join(' ');
    yield TokenEvent(answer);
    await _remember(s, text.isEmpty ? '(foto baru)' : text, answer, about.isEmpty ? 'templat' : 'llm');
    yield DoneEvent(answer, about.isEmpty ? 'templat' : 'llm');
  }

  String _reference(Recipe r) {
    final main = r.items.where((i) => i.main).map((i) => i.name).join(', ');
    final steps = [for (var i = 0; i < r.steps.length && i < 4; i++) '${i + 1}. ${r.steps[i]}'].join(' ');
    return '- ${r.name} (${r.minutes} menit; bahan utama: $main). $steps${r.tip.isEmpty ? '' : ' Tip: ${r.tip}'}';
  }

  static const _plainStarts = {'Saya', 'Tampaknya', 'Berikut', 'Benar', 'Belum', 'Bahan', 'Untuk', 'Mohon', 'Baik', 'Ada', 'Dari'};

  /// Jawaban pertama dalam percakapan dibuka dengan nama pengguna: "Khai, saya menyarankan ...".
  String greet(Session s, String answer) {
    final name = userName?.trim() ?? '';
    if (name.isEmpty || s.memory.turns.isNotEmpty || answer.isEmpty) return answer;
    final first = answer.split(' ').first;
    final rest = _plainStarts.contains(first) ? answer[0].toLowerCase() + answer.substring(1) : answer;
    return '$name, $rest';
  }

  Future<void> _remember(Session s, String user, String answer, String source) async {
    s.memory.add(user, answer);
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
    final items = r.items
        .map((it) {
          final mark = nums.containsKey(it.key)
              ? 'terlihat ${_nums(nums[it.key]!)}'
              : m.have.contains(it.key)
              ? 'dimiliki pengguna'
              : pantry.contains(it.key)
              ? 'bumbu dasar'
              : it.optional
              ? 'opsional'
              : mode == 'hidangan'
              ? 'perkiraan, tidak terlihat'
              : detectableKeys.contains(it.key)
              ? 'PERLU DISIAPKAN'
              : 'tidak bisa dicek kamera, pastikan tersedia';
          return '${it.name} ${it.amount} [$mark]';
        })
        .join('; ');
    var text = '${r.name} (${r.minutes} menit, ${r.servings} porsi, ${r.difficulty}). ${r.desc}\nBahan: $items';
    if (full) {
      text += '\nLangkah: ${[for (var i = 0; i < r.steps.length; i++) '${i + 1}. ${r.steps[i]}'].join(' ')}';
      if (r.tip.isNotEmpty) text += '\nTip: ${r.tip}';
    }
    return text;
  }

  static const _tasks = {
    'rekomendasi':
        'Rekomendasikan RESEP TERPILIH dalam 3 sampai 5 kalimat: sebut bahan dari foto beserta nomornya, bahan yang perlu disiapkan, '
        'dan lama memasak. Sebut singkat KANDIDAT LAIN sebagai alternatif, lalu tawarkan untuk menjelaskan langkahnya.',
    'hidangan':
        'Foto ini makanan jadi. Sebut perkiraan nama hidangannya, bahan yang TERLIHAT beserta nomornya, lalu bahan lain yang biasanya '
        'dipakai (sebut sebagai perkiraan). Bila ada RESEP TERPILIH yang cocok, pakai daftar bahannya dan tawarkan langkah membuatnya. Maksimal 5 kalimat.',
    'detail': 'Jelaskan cara membuat RESEP TERPILIH: sebut bahan yang perlu disiapkan, lalu langkah singkat bernomor.',
    'substitusi':
        'Jawab bahan pengganti untuk {ingredient} dalam RESEP TERPILIH. Gunakan saran pengganti dari buku resep bila ada. Maksimal 3 kalimat.',
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
      if (s.mode == 'hidangan')
        'PERKIRAAN HIDANGAN: ${s.dish ?? 'tidak yakin'}; bahan perkiraan: ${s.dishGuess.isEmpty ? '-' : s.dishGuess.map(displayName).join(', ')}',
      'BAHAN TAMBAHAN MENURUT PENGGUNA: ${p.include.isEmpty ? '-' : p.include.map(displayName).join(', ')}',
      'PREFERENSI: ${prefs.isEmpty ? '-' : prefs}',
      'RINGKASAN SEBELUMNYA: ${summary.isEmpty ? '-' : summary}',
      'RESEP TERPILIH: ${cur != null ? _recipeBlock(cur, nums, task != 'rekomendasi', s.mode) : 'tidak ada resep di buku yang cocok'}',
      if (cur != null && cur.recipe.swaps.isNotEmpty)
        'SARAN PENGGANTI: ${cur.recipe.swaps.entries.map((e) => '${displayName(e.key)} -> ${e.value}').join('; ')}',
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
      var txt = s.dish != null ? 'Tampaknya ini ${s.dish}.' : 'Saya belum yakin nama hidangannya.';
      if (seen.isNotEmpty) txt += ' Yang terlihat di foto: ${seen.join(', ')}.';
      if (cur != null) {
        final guess = [
          for (final i in cur.recipe.items)
            if (!nums.containsKey(i.key) && !i.optional && !pantry.contains(i.key)) i.name,
        ];
        return '$txt Menurut resep ${cur.recipe.name}, hidangan ini biasanya juga memakai ${guess.join(', ')} (perkiraan). Apakah Anda ingin saya jelaskan cara membuatnya?';
      }
      if (s.dishGuess.isNotEmpty) txt += ' Bahan yang biasanya dipakai (perkiraan) adalah ${s.dishGuess.map(displayName).join(', ')}.';
      return txt;
    }
    if (cur == null) {
      return 'Mohon maaf, saya belum menemukan resep yang cocok di buku resep. Silakan coba foto lain, sebutkan bahan yang Anda miliki, atau longgarkan batas waktunya.';
    }
    final r = cur.recipe;
    final seen = [
      for (final k in cur.have)
        if (nums.containsKey(k)) '${displayName(k)} (${nums[k]!.map((n) => '#$n').join(', ')})',
    ];
    // bahan yang bisa dikenali kamera tapi tidak terlihat = memang kurang; sisanya hanya perlu dipastikan
    final missing = [
      for (final k in cur.missing)
        if (detectableKeys.contains(k)) displayName(k),
    ];
    final confirm = [
      for (final k in cur.missing)
        if (!detectableKeys.contains(k)) displayName(k),
    ];
    if (task == 'detail') {
      // satu langkah per baris supaya mudah diikuti sambil memasak
      final steps = [for (var i = 0; i < r.steps.length; i++) '${i + 1}. ${r.steps[i]}'].join('\n');
      final prep = [...missing, ...confirm];
      return 'Berikut cara membuat ${r.name}.${prep.isNotEmpty ? ' Siapkan terlebih dahulu ${prep.join(', ')}.' : ''}\n$steps';
    }
    if (task == 'substitusi') {
      final k = resolve(extra['ingredient'] ?? '');
      if (k != null && r.swaps.containsKey(k)) return 'Untuk ${r.name}, ${displayName(k)} dapat diganti dengan ${r.swaps[k]}.';
      return 'Buku resep belum memiliki saran pengganti ${extra['ingredient']} untuk ${r.name}.';
    }
    var txt = 'Saya menyarankan ${r.name}, dengan waktu memasak sekitar ${r.minutes} menit.';
    if (seen.isNotEmpty) txt += ' Dari foto, sudah tersedia ${seen.join(', ')}.';
    if (missing.isNotEmpty) txt += ' Bahan yang perlu disiapkan adalah ${missing.join(', ')}.';
    if (confirm.isNotEmpty) txt += ' Mohon pastikan juga tersedia ${confirm.join(', ')}.';
    final others = [
      for (final m in s.candidates)
        if (m != cur) m.recipe.name,
    ];
    if (others.isNotEmpty) txt += ' Sebagai alternatif, Anda dapat memilih ${others.join(' atau ')}.';
    return '$txt Apakah Anda ingin saya jelaskan langkah-langkahnya?';
  }
}

final _ref = RegExp(r'\s*\(?\s*(?:#|nomor\s+|no\.\s*)(\d+)(?:\s*(?:,|dan|-|–)\s*(?:#|nomor\s+)?\d+)*\s*\)?', caseSensitive: false);

/// Pertahankan rujukan nomor (#n) hanya bila nama bahan nomor itu memang disebut tepat sebelumnya,
/// lalu bersihkan label konteks yang bocor dan tanda pisah panjang.
/// Buang kalimat terakhir yang terpotong batas token agar jawaban tidak berhenti di tengah kata.
String completeSentences(String text) {
  final t = text.trim();
  if (t.isEmpty || RegExp(r'[.!?]["”)]?$').hasMatch(t)) return t;
  final end = t.lastIndexOf(RegExp(r'[.!?](\s|$)'));
  return end > 0 ? t.substring(0, end + 1) : t;
}

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
  var cleaned = out
      .toString()
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

final _informal = RegExp(r'\b(kamu|nggak|gak|ngga|banget|lho|sih|dong|nih|kok|aja|bikin)\b', caseSensitive: false);
final _emoji = RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true);

/// Tulisan ulang gaya natural sah bila semua nama resep, nomor (#n), angka, dan bahan dari [core] tetap ada, tidak ada
/// bahan atau angka baru, tanpa daftar bernomor, emoji, atau bahasa terlalu santai, dan paling banyak lima kalimat.
/// Aturannya sama dengan penyaring data latih di scripts/make_paraphrase_sft.py.
bool naturalMatches(String core, String rewrite, Iterable<String> recipeNames) {
  final a = rewrite.toLowerCase(), c = core.toLowerCase();
  if (rewrite.isEmpty || _informal.hasMatch(rewrite) || _emoji.hasMatch(rewrite) || RegExp(r'(^|\n)\s*\d+[.)]').hasMatch(rewrite)) {
    return false;
  }
  if (RegExp(r'[.!?](\s|$)').allMatches(rewrite).length > 5 || rewrite.length > core.length * 1.6) return false;
  for (final name in recipeNames) {
    if (c.contains(name.toLowerCase()) && !a.contains(name.toLowerCase())) return false;
  }
  Set<String> nums(String t) => RegExp(r'\d+').allMatches(t).map((m) => m[0]!).toSet();
  Set<String> refs(String t) => RegExp(r'#\d+').allMatches(t).map((m) => m[0]!).toSet();
  if (!nums(core).containsAll(nums(rewrite)) || !nums(rewrite).containsAll(nums(core))) return false;
  if (!refs(rewrite).containsAll(refs(core))) return false;
  if (!mentions(rewrite).toSet().containsAll(mentions(core)) || !mentions(core).toSet().containsAll(mentions(rewrite))) return false;
  if (core.trimRight().endsWith('?') && !rewrite.trimRight().endsWith('?')) return false;
  return _statusKept(core, rewrite);
}

final _need = RegExp(
  r'siapkan|disiapkan|perlu|pastikan|belum|butuh|dibutuhkan|diperlukan|sediakan|tambahkan|kurang|tinggal|lengkapi',
  caseSensitive: false,
);
final _haveWords = RegExp(r'tersedia|sudah ada|sudah memiliki|sudah punya|terlihat|dari foto|di foto', caseSensitive: false);
final _alt = RegExp(r'alternatif|pilihan lain|bisa juga|juga bisa|atau|lainnya|selain itu', caseSensitive: false);

/// Bahan yang perlu disiapkan tidak boleh berubah menjadi bahan yang sudah ada, dan resep alternatif tetap disebut
/// sebagai alternatif.
bool _statusKept(String core, String rewrite) {
  final sentences = rewrite.trim().split(RegExp(r'(?<=[.!?])\s+')).where((x) => x.isNotEmpty).toList();
  final missing = <String>{
    for (final m in RegExp(r'(?:Bahan yang perlu disiapkan adalah|Mohon pastikan juga tersedia) ([^.]*)\.').allMatches(core)) ...mentions(m[1]!),
  };
  for (final key in missing) {
    final found = sentences.where((x) => mentions(x).contains(key)).toList();
    if (found.isEmpty || !found.any(_need.hasMatch)) return false;
    for (final x in found) {
      for (final clause in x.split(RegExp(r',|;|\bsehingga\b|\btetapi\b|\bnamun\b'))) {
        if (mentions(clause).contains(key) && _haveWords.hasMatch(clause) && !_need.hasMatch(clause)) return false;
      }
    }
  }
  final alt = RegExp(r'Sebagai alternatif, Anda dapat memilih ([^.]*)\.').firstMatch(core);
  for (final name in alt == null ? const <String>[] : alt[1]!.split(' atau ')) {
    final found = sentences.where((x) => x.toLowerCase().contains(name.toLowerCase())).toList();
    if (found.isEmpty || !found.any(_alt.hasMatch)) return false;
  }
  return true;
}

final _fixPhrase = RegExp(
  r'^(?:bukan\s+[\w -]+?\s*(?:tapi|tetapi|melainkan)\s+)?(?:(?:yang\s+)?(?:ini|itu)|gambar(?:nya)?|foto(?:nya)?)(?:\s+(?:ini|itu))?'
  r'(?:\s+yang\s+(?:saya|aku|ku)\s*(?:berikan|kirim|kasih|foto|unggah))?(?:\s+(?:adalah|ialah|merupakan|tuh|sebenarnya|sebetulnya|sih))*'
  r'\s+(.+?)(?:\s+(?:kok|lho|loh|ya|kan|dong|sih|bukan|tau))*$',
);
final _fixBut = RegExp(r'^bukan\s+[\w -]+?\s*(?:tapi|tetapi|melainkan)\s+(?:ini\s+|itu\s+)?(.+)$');
final _question = RegExp(r'\?|\b(apa|apakah|bagaimana|gimana|berapa|mana|siapa|kenapa|mengapa|bisa|boleh|cara|resep|bedanya|beda)\b');

/// Nama makanan dari koreksi pengguna atas isi foto ("ini buah naga", "gambar yang saya berikan adalah buah naga",
/// "bukan kepiting, tapi buah naga"), atau null bila kalimatnya bukan koreksi. Pertanyaan seperti "ini buah apa?"
/// bukan koreksi.
String? correction(String text) {
  final t = text.toLowerCase().replaceAll(RegExp(r'[^\w\s-]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  // "ini ada telur juga" atau "ini telur dan tomat" menambah bahan, bukan mengoreksi penanda
  if (t.isEmpty || _question.hasMatch(text.toLowerCase()) || RegExp(r'\b(ada|juga|punya|tambah|masih|dan|sama)\b').hasMatch(t)) return null;
  final m = _fixBut.firstMatch(t) ?? _fixPhrase.firstMatch(t);
  final name = m?[1]?.trim();
  if (name == null || name.isEmpty || name.split(' ').length > 4) return null;
  return name;
}

final _nutritionQuestion = RegExp(
  r'\b(gizi|kalori|kkal|protein|lemak|karbohidrat|natrium|kandungan|cocok untuk (saya|aku)|masih ideal|ideal (nggak|gak|tidak|enggak)|'
  r'sehat (nggak|gak|tidak|enggak)|aman untuk diet|boleh (dimakan|makan) (saat|waktu) diet)\b',
);
final _personal = RegExp(r'\b(saya|aku|untukku|buatku|diet|ideal|kebutuhan|harian|berat badan)\b');
