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
import 'context.dart';
import 'fasting.dart';
import 'grounding.dart';
import 'health.dart';
import 'intake.dart';
import 'label.dart';
import 'history.dart';
import 'recipes.dart';
import 'slang.dart';
import 'tools.dart';
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

/// Tombol aksi di bawah jawaban, misalnya membuka Gizi Seimbang (kunci rute dari tools.dart).
class ActionsEvent extends MeiraEvent {
  ActionsEvent(this.routes);
  final List<String> routes;
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
  NutritionLabel? label; // label gizi kemasan yang terbaca dari foto
  String? lastTopic; // makanan atau catatan yang terakhir dibahas, untuk pertanyaan lanjutan seperti "apa lanjutannya?"
  bool lastNutrition = false; // jawaban terakhir berupa fakta gizi
  String? pending; // pertanyaan MEIRA yang menunggu jawaban ya atau tidak, misalnya tawaran menjelaskan langkah
  String tab = 'resep'; // tab tempat percakapan ini dimulai (resep atau gizi), supaya dibuka kembali di tab yang sama
  Set<String> situation = {}; // keadaan pengguna yang disebut di percakapan ini, misalnya sedang berpuasa (context.dart)
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
    'last_topic': lastTopic,
    'last_nutrition': lastNutrition,
    'pending': pending,
    'situation': situation.toList(),
    'tab': tab,
  };

  static Session restore(String id, Map<String, dynamic> st, List<Recipe> recipes, {int memoryBudget = 1100}) {
    final s = Session(id, memoryBudget: memoryBudget)
      ..mode = st['mode'] ?? 'bahan'
      ..dish = st['dish']
      ..dishGuess = ((st['dish_guess'] as List?) ?? []).cast<String>()
      ..detections = [for (final d in (st['detections'] as List?) ?? []) Detection.fromJson(d)]
      ..prefs = Prefs.fromJson(st['prefs'])
      ..shown = ((st['shown'] as List?) ?? []).cast<String>()
      ..current = st['current']
      ..lastTopic = st['last_topic']
      ..lastNutrition = st['last_nutrition'] == true
      ..pending = st['pending']
      ..situation = {...((st['situation'] as List?) ?? []).cast<String>()}
      ..tab = st['tab'] == 'gizi' ? 'gizi' : 'resep';
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
    this.appData,
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
  AppData? appData; // data fitur yang bisa dibaca dan diubah lewat obrolan
  String chatMode = 'resep'; // pada mode gizi, pertanyaan umum dijawab sebagai soal gizi, bukan saran resep
  /// Potongan foto asli beresolusi lebih tinggi untuk OCR kedua di sekitar label gizi (diisi AppState per foto).
  Future<VisionInput?> Function(List<double> box)? zoom;
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
    if (vision != null && s.visionInput != null) {
      final lines = await vision!.read(s.visionInput!);
      s.label = nutritionLabel(lines);
      // label gizi bertulisan kecil: baca ulang potongan di sekitar judulnya dengan resolusi lebih tinggi
      final header = lines.where((l) => RegExp(r'nilai gizi|nutrition facts', caseSensitive: false).hasMatch(l.text)).firstOrNull;
      if (header != null && zoom != null) {
        final w = header.box[2] - header.box[0];
        final crop = await zoom!([
          math.max(0, header.box[0] - w * .6),
          math.max(0, header.box[1] - .02),
          math.min(1, header.box[2] + w * .6),
          math.min(1, header.box[1] + w * 2.6),
        ]);
        if (crop != null) {
          final again = nutritionLabel(await vision!.read(crop));
          if (again != null && (s.label == null || again.fieldCount >= s.label!.fieldCount)) s.label = again;
        }
      }
      return packagesFromText(lines, s.detections);
    }
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
    // "sayur apa yang cocok buat anak?" di tab Resep tetap meminta saran resep walau berbentuk pertanyaan
    final suggest = chatMode == 'resep' && _suggestRequest.hasMatch(text.toLowerCase());
    if (rule.action == 'rekomendasi' && !suggest && (Guardrails.smallTalk(text) || chatQuestion(text, knowledge))) return rule..action = 'obrolan';
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
    // bahasa santai diubah ke bentuk baku untuk aturan, pencarian, dan model; riwayat tetap menyimpan kalimat asli
    text = formalize(text);
    // keadaan yang disebut pengguna ("saya sedang puasa") diingat untuk seluruh sesi; pertanyaan yang ditunggu
    // jawabannya hanya berlaku untuk balasan berikutnya
    final situation = text.isEmpty ? (added: <String>{}, removed: <String>{}) : updateSituation(s.situation, text, hasPlan: appData?.fasting != null);
    // keadaan yang memengaruhi saran resep: vegetarian hanya resep tanpa daging, diet mendahulukan resep yang ringan
    for (final (k, tag) in const [('vegetarian', 'vegetarian'), ('diet', 'sehat')]) {
      if (situation.added.contains(k)) s.prefs.tags.add(tag);
      if (situation.removed.contains(k)) s.prefs.tags.remove(tag);
    }
    final pending = s.pending;
    s.pending = null;
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
        ..guess = null
        ..label = null;
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
      // tulisan kemasan dan label gizi dibaca pada semua foto; penanda kemasan hanya untuk foto bahan
      if (readPackages) {
        yield StatusEvent('Membaca kemasan');
        final pkg = await _packages(s);
        if (s.mode == 'bahan' && pkg.isNotEmpty) {
          s.detections = number([...s.detections, ...pkg]);
          yield DetectionsEvent(s.detections, null);
        }
        if (s.label != null && text.isEmpty) {
          // foto label gizi: jawabannya angka dari label dibandingkan kebutuhan harian, beserta saran porsi
          final answer = labelAnswer(s.label!, Targets.of(needs));
          yield TokenEvent(answer);
          yield ActionsEvent(const ['gizi']);
          await _remember(s, '(foto label gizi)', answer, 'label');
          yield DoneEvent(answer, 'label');
          await _persist(s);
          return;
        }
      }
    }
    // koreksi angka label gizi yang terbaca keliru ("lemaknya 5 g"), lalu jawab ulang dengan angka yang benar
    if (imageDataUrl == null && s.label != null) {
      if (labelCorrection(text) case (final field, final value)) {
        s.label = s.label!.corrected(field, value);
        final answer = 'Baik, sudah saya perbaiki. ${labelAnswer(s.label!, Targets.of(needs))}';
        yield TokenEvent(answer);
        await _remember(s, text, answer, 'label');
        yield DoneEvent(answer, 'label');
        await _persist(s);
        return;
      }
    }
    // pertanyaan lanjutan tentang label gizi yang sudah terbaca ("kalau saya makan semuanya?")
    if (imageDataUrl == null && s.label != null && _labelFollowUp.hasMatch(text.toLowerCase())) {
      final whole = RegExp(r'\b(semua|semuanya|seluruh|sekaligus|satu kemasan|sebungkus|habis)').hasMatch(text.toLowerCase());
      final answer = labelAnswer(s.label!, Targets.of(needs), whole: whole);
      yield TokenEvent(answer);
      await _remember(s, text, answer, 'label');
      yield DoneEvent(answer, 'label');
      await _persist(s);
      return;
    }

    // "ini gizi atau resep?": dijelaskan dari tab yang sedang dibuka
    if (imageDataUrl == null && _tabQuestion.hasMatch(text.toLowerCase())) {
      final here = chatMode == 'gizi' ? 'Gizi' : 'Resep';
      final answer =
          'Anda sedang di tab $here. Tab Resep untuk mencari resep dari foto bahan atau nama hidangan beserta langkahnya, '
          'sedangkan tab Gizi untuk kandungan gizi, kecocokan makanan dengan kebutuhan harian, label gizi kemasan, catatan '
          'makan, dan jendela makan. Setiap tab menyimpan percakapannya sendiri.';
      yield TokenEvent(answer);
      await _remember(s, text, answer, 'fitur');
      yield DoneEvent(answer, 'fitur');
      return;
    }
    // pertanyaan lanjutan tanpa topik ("apa lanjutannya?") melanjutkan topik terakhir, bukan ditolak sebagai di luar topik
    // "terus gimana biar lebih sehat?", "kalau tiap hari?", dan "porsinya berapa?" tentang makanan yang baru dibahas
    final kind = imageDataUrl == null && s.lastNutrition && s.lastTopic != null ? _nutritionFollowUp(text) : null;
    final lastFact = kind == null ? null : knowledge?.link(s.lastTopic!, nutrition: true).where((f) => f.nutrition).firstOrNull;
    final newFood = knowledge?.link(text, nutrition: true).where((f) => f.nutrition && f.title != lastFact?.title).isNotEmpty ?? false;
    if (lastFact != null && !newFood) {
      final answer =
          '${kind == 'tips' ? _nutritionAnswer(text, lastFact, more: true) : _portionAnswer(lastFact, often: kind == 'often')} '
                  '${situationAdvice(s.situation)}'
              .trim();
      yield* _say(s, text, answer, 'fakta');
      await _persist(s);
      return;
    }
    if (imageDataUrl == null && s.lastTopic != null && _followUp.hasMatch(text.toLowerCase())) {
      final gizi = s.lastNutrition ? knowledge?.link(s.lastTopic!, nutrition: true).where((f) => f.nutrition).firstOrNull : null;
      if (gizi != null) {
        yield* _say(s, text, _nutritionAnswer(text, gizi, more: true), 'fakta');
        return;
      }
      text = 'Jelaskan lebih lengkap tentang ${s.lastTopic}';
    }
    // pesan yang hanya memberi tahu keadaan dijawab dengan penegasan, bukan dicocokkan ke catatan yang kebetulan berbagi
    // kata ("sedang" pada catatan api kecil, sedang, dan besar)
    if (imageDataUrl == null && (situation.added.isNotEmpty || situation.removed.isNotEmpty) && onlySituation(text)) {
      final plan = appData?.fasting;
      final window = situation.added.contains('puasa_if') && plan != null
          ? ' Jendela makan Anda pukul ${clock(plan.startMinute)} sampai ${clock(plan.endMinute)}.'
          : '';
      final answer = '${situationAck(situation.added, situation.removed)}$window';
      yield TokenEvent(answer);
      await _remember(s, text, answer, 'templat');
      yield DoneEvent(answer, 'templat');
      await _persist(s);
      return;
    }
    // jawaban atas tawaran MEIRA sendiri ("Apakah Anda ingin saya jelaskan langkah-langkahnya?" lalu "iya")
    if (imageDataUrl == null && pending == 'langkah' && s.currentMatch != null) {
      if (isYes(text)) {
        yield RecipesEvent();
        yield* _answer(s, text, 'detail', {});
        await _persist(s);
        return;
      }
      if (isNo(text)) {
        const answer = 'Baik. Kalau nanti ingin langkahnya atau resep lain, tinggal bilang saja.';
        yield TokenEvent(answer);
        await _remember(s, text, answer, 'templat');
        yield DoneEvent(answer, 'templat');
        await _persist(s);
        return;
      }
    }
    // "Mau saya tampilkan resepnya?" sesudah menjelaskan sebuah hidangan: "iya" berarti resep hidangan itu
    if (imageDataUrl == null && pending != null && pending.startsWith('resep:')) {
      if (isYes(text)) {
        text = 'resep ${pending.substring(6)}';
      } else if (isNo(text)) {
        const answer = 'Baik. Kalau nanti ingin mencoba memasaknya, tinggal minta resepnya.';
        yield TokenEvent(answer);
        await _remember(s, text, answer, 'templat');
        yield DoneEvent(answer, 'templat');
        await _persist(s);
        return;
      }
    }
    // "iya" atau "nggak" tanpa tawaran yang ditunggu ditanggapi singkat, bukan dianggap permintaan resep
    if (imageDataUrl == null && pending == null && (isYes(text) || isNo(text))) {
      final answer = isNo(text)
          ? 'Baik. Kalau ada yang ingin ditanyakan atau dimasak, tinggal bilang saja.'
          : 'Baik. Silakan sebutkan bahan yang Anda punya atau pertanyaan tentang makanan, nanti saya bantu.';
      yield TokenEvent(answer);
      await _remember(s, text, answer, 'templat');
      yield DoneEvent(answer, 'templat');
      return;
    }
    // perintah fitur: catat berat atau makanan, isi data tubuh, tanya IMT, progres, jejak masak, atau buka fitur
    final tool = imageDataUrl == null && text.isNotEmpty ? (appData != null ? appTool(text, appData!) : greetingTool(text, null)) : null;
    // ucapan terima kasih dan sapaan singkat dijawab langsung, supaya tidak dicocokkan ke catatan dapur yang kebetulan
    // memuat kata "MEIRA" atau dijawab model dengan topik lain
    final chat = tool == null && imageDataUrl == null ? smallTalkReply(text) : null;
    if (chat != null) {
      yield TokenEvent(chat);
      await _remember(s, text, chat, 'templat');
      yield DoneEvent(chat, 'templat');
      return;
    }
    if (tool != null) {
      await tool.effect?.call();
      yield TokenEvent(tool.text);
      if (tool.actions.isNotEmpty) yield ActionsEvent(tool.actions);
      await _remember(s, text, tool.text, 'fitur');
      yield DoneEvent(tool.text, 'fitur');
      await _persist(s);
      return;
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
      // percakapan yang sedang membahas sebuah makanan juga dihitung, supaya pertanyaan susulan yang pendek tidak ditolak
      final inContext =
          (s.imageDataUrl != null || s.current != null || (s.lastTopic != null && text.split(' ').length <= 8)) && !Guardrails.offTopicSubject(text);
      // istilah yang ada di catatan dapur atau basis pengetahuan ("adonan", "ungkep", "klepon") juga soal dapur
      final query = withSituation(text, s.situation);
      final known = knowledge != null && (knowledge!.covers(query) || knowledge!.link(text).isNotEmpty);
      final guard = Guardrails.checkInput(text, knownIngredient: inContext || known || Guardrails.kitchenRequest(text), ragScore: ragScore(query));
      // pertanyaan makanan untuk kondisi kesehatan ("bolehkah penderita diabetes makan durian?") dijawab dengan fakta gizi
      // makanannya, atau dengan catatan umum yang cocok ("buah apa yang bagus untuk diabetes"), beserta anjuran ke dokter;
      // diagnosis dan pengobatan tetap ditolak
      final foodFacts =
          guard.verdict == GuardVerdict.medical &&
          ((knowledge?.link(text, nutrition: true).any((f) => f.nutrition) ?? false) || _strongNote(query) != null);
      if (!guard.allowed && !foodFacts) {
        yield TokenEvent(guard.reply);
        if (guard.verdict == GuardVerdict.offTopic) yield ActionsEvent(const ['resep', 'gizi', 'tur']);
        await _remember(s, text, guard.reply, 'pengaman');
        yield DoneEvent(guard.reply, 'pengaman');
        await _persist(s);
        return;
      }
    }
    final it = text.isNotEmpty ? await _intent(text) : Intent(imageDataUrl != null && s.mode == 'hidangan' ? 'hidangan' : 'rekomendasi');
    // pertanyaan tentang sifat, keamanan, asal, atau kiat ("boleh masak pakai minyak bekas?", "rendang asalnya dari mana?",
    // "gimana caranya kurusin badan?") dijawab dari pengetahuan, bukan dengan resep acak; "caranya?" sesudah resep
    // ditawarkan tetap berarti langkah resep itu
    final lower = text.toLowerCase();
    final followsRecipe = it.action == 'detail' && s.currentMatch != null && text.split(' ').length <= 6;
    if ((it.action == 'rekomendasi' || it.action == 'detail') &&
        imageDataUrl == null &&
        !followsRecipe &&
        _knowledgeQuestion(lower) &&
        !_recipeRequest.hasMatch(lower) &&
        !(chatMode == 'resep' && _suggestRequest.hasMatch(lower))) {
      it.action = 'obrolan';
    }
    // "jelaskan tentang rendang" atau "gudeg itu makanan apa?" meminta penjelasan hidangan, bukan resepnya
    if (imageDataUrl == null &&
        it.action != 'obrolan' &&
        (knowledge?.link(text).any((f) => !f.nutrition && f.summary.isNotEmpty && f.names.any((n) => whatIs(text, n))) ?? false)) {
      it.action = 'obrolan';
    }
    // "berapa lama masaknya?", "untuk berapa orang?", "susah nggak?", "pakai alat apa?" tentang resep yang sedang dibahas
    final about = s.currentMatch == null || imageDataUrl != null ? null : recipeFact(s.currentMatch!.recipe, lower);
    if (about != null) {
      yield TokenEvent(about);
      await _remember(s, text, about, 'templat');
      yield DoneEvent(about, 'templat');
      await _persist(s);
      return;
    }
    // "bisa diganti pakai nasi merah?": bahan pengganti untuk resep yang sedang dibahas
    final swap = s.currentMatch == null ? null : _replacement.firstMatch(lower);
    if (swap != null && imageDataUrl == null) {
      final answer = _swapAnswer(s.currentMatch!.recipe, swap[1]!.trim());
      yield TokenEvent(answer);
      await _remember(s, text, answer, 'templat');
      yield DoneEvent(answer, 'templat');
      await _persist(s);
      return;
    }
    if (imageDataUrl != null && s.mode == 'hidangan' && it.action == 'rekomendasi') it.action = 'hidangan';
    if (chatMode == 'gizi' && it.action == 'rekomendasi' && !RegExp(r'\b(resep|masak|bikin|cara membuat)\b').hasMatch(text.toLowerCase())) {
      it.action = 'obrolan';
    }
    // pertanyaan gizi ("mi instan masih cocok untuk saya?", "berapa kalori nasi goreng?") dijawab dari fakta gizi,
    // bukan dengan rekomendasi resep
    final suggest = chatMode == 'resep' && _suggestRequest.hasMatch(text.toLowerCase());
    if (it.action == 'rekomendasi' &&
        !suggest &&
        (_nutritionQuestion.hasMatch(text.toLowerCase()) ||
            (KnowledgeBase.asksNutrition(text) &&
                !_cookingWords.hasMatch(text.toLowerCase()) &&
                (knowledge?.link(text, nutrition: true).any((f) => f.nutrition) ?? false)))) {
      it.action = 'obrolan';
    }
    // "buah naga bisa dibuat apa?": makanan yang tidak ada di kosakata maupun nama resep dijawab dari fakta, bukan
    // dengan resep acak yang kebetulan berbagi kata
    if (it.action == 'rekomendasi' &&
        it.include.isEmpty &&
        mentions(text).isEmpty &&
        findRecipe(recipes, text) == null &&
        !suggest &&
        (knowledge?.link(text).isNotEmpty ?? false)) {
      it.action = 'obrolan';
    }
    // "resep rendang" atau "cara bikin soto ayam" tanpa foto: resep yang disebut namanya dipakai langsung; bila tidak
    // ada di buku resep, MEIRA berterus terang lalu menjelaskan hidangannya dari basis pengetahuan
    var noRecipe = '';
    if (imageDataUrl == null && s.have().isEmpty && (it.action == 'rekomendasi' || it.action == 'detail')) {
      // "gimana cara bikinnya?" sesudah membahas rendang berarti resep rendang
      var named =
          findRecipe(recipes, text) ??
          (it.action == 'detail' && s.currentMatch == null && s.lastTopic != null ? findRecipe(recipes, s.lastTopic!) : null);
      // "kue lapis legit" bukan Kue Lapis: hidangan lain di basis pengetahuan yang disebut namanya tidak dicocokkan ke
      // resep yang hanya berbagi sebagian kata
      final dish = named == null ? null : knowledge?.link(text).where((f) => !f.nutrition).firstOrNull;
      if (dish != null) {
        final t = ' ${norm(text)} ', recipe = norm(named!.name);
        final said = dish.names.map(norm).where((n) => t.contains(' $n ')).fold('', (a, b) => b.length > a.length ? b : a);
        if (said.isNotEmpty && said != recipe && !recipe.contains(said)) named = null;
      }
      // hidangan lain yang disebut di tengah percakapan ("ayam goreng biar renyah gimana?") tidak dijawab dengan resep
      // yang sedang dibahas; pertanyaan kiat ("biar", "supaya") dijawab dari catatan dapur bila ada
      final current = s.currentMatch?.recipe;
      final elsewhere = current == null || (named != null && named.id != current.id && !_namesRecipe(current, text));
      final tip =
          RegExp(r'\b(biar|supaya|agar|tips?|kiat)\b').hasMatch(text) &&
          (knowledge?.search(text, k: 1).any((n) => knowledge!.titleShares(n.$1, text)) ?? false);
      if (!elsewhere) {
        // tetap membahas resep yang sama
      } else if (tip) {
        it.action = 'obrolan';
      } else if (named != null) {
        s.candidates = rank([named], const {}, Prefs(), k: 1);
        if (s.candidates.isEmpty) s.candidates = [Match(named, 0, [], [])];
        s.current = named.id;
        if (!s.shown.contains(named.id)) s.shown.add(named.id);
      } else if (RegExp(r'\b(resep|cara (bikin|buat|membuat|masak))\b').hasMatch(text.toLowerCase()) && (knowledge?.link(text).isNotEmpty ?? false)) {
        final dish = knowledge!.link(text).first.title;
        final similar = retriever.search(text, k: 2).map((h) => h.recipe.name).toList();
        noRecipe = 'Resep ${dish.toLowerCase()} belum ada di buku resep MEIRA.${similar.isEmpty ? '' : ' Yang mirip: ${similar.join(' atau ')}.'}';
        it.action = 'obrolan';
      }
    }
    // "kue cubit dibuat dari apa?" tanpa foto, atau menyebut makanan yang ada di basis pengetahuan, adalah pertanyaan
    // pengetahuan, bukan permintaan menebak hidangan di foto
    if (it.action == 'hidangan' && imageDataUrl == null && (s.imageDataUrl == null || (knowledge?.link(text).isNotEmpty ?? false))) {
      it.action = 'obrolan';
    }
    // dalam sesi foto, menyebut bahan lain tanpa bertanya ("buah naga dan pisang") berarti bahan itu ikut dipakai
    if (s.imageDataUrl != null && imageDataUrl == null && it.action == 'rekomendasi' && !text.contains('?')) {
      it.include.addAll(mentions(text).where((k) => !s.have().contains(k) && !it.exclude.contains(k)));
    }
    // bahan yang baru disebut lewat ketikan ("ada telur juga") diakui di awal jawaban
    final added = it.include.difference(s.have());
    _applyPrefs(s, it);
    var task = it.action;
    final extra = <String, String>{if (added.isNotEmpty) 'added': added.map(displayName).join(', '), if (noRecipe.isNotEmpty) 'norecipe': noRecipe};

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
          ? 'Bahan di foto ini belum terlihat jelas. Coba foto lebih dekat dengan cahaya yang cukup, atau sebutkan bahan yang Anda miliki.'
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
        // resep yang baru saja dipilih dari namanya ("resep rendang") tidak diganti hasil pencarian
        final picked = imageDataUrl == null && s.currentMatch != null && findRecipe(recipes, text)?.id == s.current;
        if (!picked) _rerank(s, skipShown: false, query: text);
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
      // bahan yang diminta tetapi tidak dipakai resep terpilih disebut terus terang, beserta resep yang memakainya
      final unused = [
        for (final k in s.prefs.include)
          if (!cur.recipe.items.any((i) => i.key == k)) k,
      ];
      if ((task == 'rekomendasi' || task == 'hidangan') && unused.isNotEmpty) {
        final names = unused.map(displayName).join(' dan ');
        final using = recipes
            .where((r) => r.id != cur.recipe.id && unused.every((k) => r.items.any((i) => i.key == k)))
            .take(2)
            .map((r) => r.name)
            .toList();
        final note =
            'Buku resep belum punya resep yang memakai bahan di foto bersama $names, jadi $names belum dipakai di ${cur.recipe.name}.'
            '${using.isEmpty ? '' : ' Resep yang memakai $names antara lain ${using.join(' dan ')}.'}';
        core = core.replaceFirst(RegExp(r' Apakah Anda ingin'), ' $note Apakah Anda ingin');
      }
      if (extra['guess'] != null) core = '${extra['guess']} $core';
      if (extra['fixed'] != null) core = '${extra['fixed']} $core';
      // mode enak dan sehat: sebutkan resep yang tergeser bila ada, lalu alasan resep ini ringan atau satu saran agar
      // lebih ringan (lihat core/health.dart)
      if ((healthMode || s.prefs.tags.contains('sehat')) && (task == 'rekomendasi' || task == 'ganti')) {
        Recipe? tastier;
        final have = {...s.have(), if (s.mode == 'hidangan') ...s.dishGuess};
        if (task == 'rekomendasi' && have.isNotEmpty) {
          final plain = rank(recipes, have, Prefs.fromJson(s.prefs.toJson()), k: 1);
          if (plain.isNotEmpty) tastier = plain.first.recipe;
        }
        final note = healthNote(cur.recipe, tastier: tastier);
        if (note.isNotEmpty) core = core.replaceFirst(RegExp(r' Apakah Anda ingin'), ' $note Apakah Anda ingin');
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
    final query = withSituation(text, s.situation);
    final notes = [
      for (final n in knowledge?.search(query, k: 4) ?? const <(Note, double, int)>[])
        if ((asked.isEmpty || mentions('${n.$1.title} ${n.$1.keywords} ${n.$1.body}').any(asked.contains)) &&
            // catatan puasa hanya untuk pengguna yang sedang berpuasa atau pertanyaan tentang puasa
            (_fastingTalk.hasMatch(query.toLowerCase()) || !_fastingTalk.hasMatch(n.$1.title.toLowerCase())) &&
            // catatan perbandingan ("Beda ayam goreng dan ayam bakar") hanya untuk pertanyaan perbandingan
            (!n.$1.title.startsWith('Beda ') || _compareWords.hasMatch(query.toLowerCase())))
          n,
    ].take(2).toList();
    // Catatan disalin apa adanya hanya bila meliput sebagian besar kata pertanyaan ("berapa lama merebus telur").
    // Catatan yang hanya berbagi satu dua kata, misalnya soal menyimpan pisang untuk pertanyaan beda pisang ambon dan
    // kepok, tidak dipakai sebagai jawaban; model menjawab sendiri dengan catatan yang cukup dekat sebagai rujukan.
    final terms = knowledge?.termCount(query) ?? 0;
    double cover((Note, double, int) n) => terms == 0 ? 0 : n.$3 / terms;
    bool titled((Note, double, int) n) => knowledge!.titleShares(n.$1, query);
    // pertanyaan tentang isi foto ("ini buah apa?") dijawab dari foto, bukan dari catatan yang kebetulan berbagi kata
    // pertanyaan susulan tanpa nama makanan ("bahannya apa saja?", "kalau itu enaknya dimasak apa?") memakai makanan yang
    // baru dibahas
    final direct = knowledge?.link(text) ?? const <Fact>[];
    final carried = direct.isEmpty && s.lastTopic != null && _refersBack(text.toLowerCase()) ? s.lastTopic : null;
    final linked = carried == null ? direct : (knowledge?.link('$text $carried') ?? const <Fact>[]);
    final aboutPhoto = s.imageDataUrl != null && linked.isEmpty && RegExp(r'\b(ini|itu|foto|gambar)\b').hasMatch(text.toLowerCase());
    final strong = aboutPhoto
        ? <(Note, double, int)>[]
        : notes.where((n) => (n.$3 >= 2 || n.$2 >= Guardrails.ragThreshold || terms == 1) && cover(n) >= .6 && titled(n)).toList();
    final related = aboutPhoto ? <(Note, double, int)>[] : notes.where((n) => titled(n) && cover(n) >= .3).toList();
    // pertanyaan gizi, keamanan, atau kecocokan makanan dijawab dari fakta gizi USDA yang sudah dihitung, bukan dari
    // catatan cara memasak dan bukan dari karangan model ("kandungan nasi goreng", "apakah aman makan mie instan")
    // "kamu tahu kecap jamur?" di tab Gizi tetap pertanyaan definisi, bukan pertanyaan gizi
    final defines = linked.any((f) => !f.nutrition && f.summary.isNotEmpty && f.names.any((n) => whatIs(text, n)));
    final asksGizi = !defines && (KnowledgeBase.asksNutrition(text) || (chatMode == 'gizi' && !_cookingWords.hasMatch(text.toLowerCase())));
    // "ayam setengah matang aman?" adalah soal keamanan pangan, dan "batas gula sehari?" soal anjuran harian: keduanya
    // dijawab dari catatan, bukan dengan angka gizi per 100 gram yang menyimpulkan "aman dimakan"
    final lowerText = text.toLowerCase();
    // "beda gula aren dan gula pasir" juga dijawab dari catatan perbandingan bila ada, bukan dari angka gizi
    final compares = _compareWords.hasMatch(lowerText) && strong.isNotEmpty && strong.first.$1.title.startsWith('Beda ');
    final noteFirst =
        strong.isNotEmpty && (_safety.hasMatch(lowerText) || lowerText.contains('batas') || !_suitability.hasMatch(lowerText) || compares);
    if (task == 'obrolan' && asksGizi && !noteFirst && !_safety.hasMatch(lowerText)) {
      final gizi = (knowledge?.link(text, nutrition: true) ?? const <Fact>[]).where((f) => f.nutrition).toList();
      if (gizi.isNotEmpty) {
        // "beda gula merah dan gula pasir": kedua makanan dibandingkan, bukan hanya yang pertama disebut
        final compare = gizi.length >= 2 && _compareWords.hasMatch(text.toLowerCase()) ? compareNutrition(gizi[0], gizi[1], question: text) : null;
        // hidangan yang belum ada datanya ("kopi susu") disebut terus terang sebelum angka bahannya
        final base = gizi.first.title.replaceFirst('Kandungan gizi ', '');
        final dish = unknownDishes(text).firstOrNull ?? _longerDish(text, gizi.first);
        final note = dish == null ? '' : 'Data gizi untuk $dish belum ada, jadi berikut angka untuk $base. ';
        final fried = dish != null && RegExp(r'\b(goreng|gorengan|mendoan|krispi|crispy|kremes|geprek|penyet|katsu|tepung|keripik)\b').hasMatch(dish)
            ? ' Karena $dish digoreng, kalori dan lemaknya lebih tinggi dari angka ini, jadi sebaiknya sesekali saja.'
            : '';
        // sedang berpuasa: "boleh minum teh manis?" dijawab menurut jenis puasanya, bukan hanya angka gizinya
        final fasting = compare == null ? _fastingAnswer(gizi.first, lowerText, s) : null;
        if (fasting != null) {
          s.lastTopic = gizi.first.title.replaceFirst('Kandungan gizi ', '');
          s.lastNutrition = true;
          yield* _say(s, text, fasting, 'fakta');
          return;
        }
        final medical = RegExp(r'\b(diabetes|darah tinggi|hipertensi|kolesterol|asam urat|hamil|ginjal)\b').hasMatch(lowerText);
        final answer = '${compare ?? '$note${_nutritionAnswer(text, gizi.first)}$fried'} ${situationAdvice(s.situation, medicalNoted: medical)}'
            .trim();
        s.lastTopic = gizi.first.title.replaceFirst('Kandungan gizi ', '');
        s.lastNutrition = true;
        yield* _say(s, text, answer, 'fakta');
        return;
      }
    }
    // "bahannya apa saja?" atau "rendang terbuat dari apa?": dari buku resep bila ada, selain itu dari Wikidata
    if (task == 'obrolan' && _ingredientsQuestion.hasMatch(lowerText) && s.imageDataUrl == null) {
      final topic = linked.firstOrNull?.title ?? carried ?? s.currentMatch?.recipe.name;
      final book = topic == null ? null : _bookFor(topic);
      final wiki = linked.where((f) => f.text.contains('Bahan: ')).firstOrNull;
      final optional = book == null ? const <String>[] : [for (final i in book.items.where((i) => i.optional)) i.name];
      final answer = book != null
          ? '${book.name} di buku resep MEIRA memakai ${_list([for (final i in book.items.where((i) => !i.optional && i.key != 'water')) i.name])}.'
                '${optional.isEmpty ? '' : ' Sebagai pelengkap, bisa ditambah ${_list(optional)}.'}'
          : wiki == null
          ? null
          : 'Bahan ${wiki.title} antara lain ${RegExp(r'Bahan: ([^.]+)\.').firstMatch(wiki.text)![1]}.';
      if (answer != null) {
        s.lastTopic = topic;
        yield* _say(s, text, answer, 'fakta');
        return;
      }
    }
    // "rendang asalnya dari mana?": dijawab dari keterangan dan kolom asal Wikidata, bukan dari catatan perbandingan
    final origin = task == 'obrolan' && _originQuestion.hasMatch(lowerText) ? linked.where((f) => f.text.contains('Asal: ')).firstOrNull : null;
    if (origin != null) {
      s.lastTopic = origin.title;
      yield* _say(s, text, originAnswer(origin), 'fakta');
      return;
    }
    // "apa itu klepon?" atau "gudeg itu makanan apa?": dari ringkasan Wikipedia, lalu resepnya ditawarkan bila hidangan
    // itu ada di buku resep
    final defined = task == 'obrolan' && s.imageDataUrl == null
        ? linked.where((f) => !f.nutrition && f.summary.isNotEmpty && f.names.any((n) => whatIs(text, n))).firstOrNull
        : null;
    if (defined != null) {
      final book = _bookFor(defined.title);
      final d = norm(defined.title);
      final some = book == null
          ? [
              for (final r in recipes)
                if (' ${norm(r.name)} '.contains(' $d ')) r.name,
            ]
          : const <String>[];
      final offer = book != null
          ? ' Resep ${book.name} ada di buku resep MEIRA. Mau saya tampilkan?'
          : some.isEmpty
          ? ''
          : ' Di buku resep MEIRA ada beberapa resep dengan ${defined.title.toLowerCase()}, misalnya ${some.take(2).join(' dan ')}. Mau saya carikan?';
      s.lastTopic = defined.title;
      yield* _say(
        s,
        text,
        '${defined.summary}$offer',
        'fakta',
        pending: book != null ? 'resep:${book.name}' : (some.isEmpty ? null : 'resep:${defined.title.toLowerCase()}'),
      );
      return;
    }
    if (linked.isNotEmpty) s.lastTopic = linked.first.title.replaceFirst('Kandungan gizi ', '');
    if (strong.isNotEmpty) s.lastTopic = strong.first.$1.title;
    s.lastNutrition = false;
    // pengganti bahan yang tidak ada di resep terpilih juga dijawab dari catatan ("kalau tidak ada mentega, pakai apa?")
    final offRecipe = task == 'substitusi' && !(cur?.recipe.items.any((i) => i.key == resolve(extra['ingredient'] ?? '')) ?? false);
    if ((task == 'obrolan' || offRecipe) && strong.isNotEmpty) {
      if (!rewriteNotes) {
        yield* _say(s, text, noteAnswer(text, strong.first.$1), 'catatan');
        return;
      }
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
      // RAG: catatan dapur yang cukup dekat ditambah fakta Wikidata dan USDA untuk makanan yang disebut namanya. Bila
      // hidangannya ada di buku resep, bahan dari buku resep yang dipakai; daftar bahan Wikidata untuk hidangan itu
      // dibuang karena kadang keliru (klepon tertulis dari tepung beras, padahal tepung ketan)
      final book = namedRecipe(recipes, text);
      final facts = [
        if (book != null) _bookFact(book),
        for (final n in related.take(2)) 'Catatan dapur "${n.$1.title}": ${n.$1.body}',
        for (final f in linked)
          book != null && f.title.toLowerCase() == book.name.toLowerCase() ? f.text.replaceFirst(RegExp(r' Bahan: [^.]*\.'), '') : f.text,
        // ringkasan Wikipedia hanya untuk makanan utama yang ditanyakan, supaya konteks model kecil tetap pendek
        if (linked.firstOrNull case final f? when linked.length <= 2 && !f.nutrition && f.summary.isNotEmpty)
          'Wikipedia tentang ${f.title}: ${f.summary}',
        // perbandingan dengan kebutuhan harian pengguna sudah dihitung di sini; model cukup menyampaikannya
        if (needs != null)
          for (final f in linked.where((f) => f.nutrition)) ?compareWithNeeds(f.title, f.text, needs!),
        if (needs != null && _personal.hasMatch(text.toLowerCase())) needs!.factLine,
        // catatan makan hari ini ikut sebagai fakta saat pertanyaannya tentang diri pengguna
        if (appData != null && _personal.hasMatch(text.toLowerCase())) ?intakeFact(appData!),
      ];
      final more = book == null || book.desc.isEmpty
          ? null
          : 'Hidangan ini berupa ${book.desc[0].toLowerCase()}${book.desc.substring(1)} Resepnya ada di buku resep MEIRA.';
      yield* _chat(s, text, facts, photo: aboutPhoto || linked.isEmpty, prefix: extra['norecipe'] ?? '', more: more);
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
      yield StatusEvent('Menyusun jawaban');
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
  Stream<MeiraEvent> _chat(Session s, String text, List<String> facts, {bool photo = true, String prefix = '', String? more}) async* {
    // pertanyaan tanpa sumber tidak diserahkan ke model kecil: adaptornya dilatih menjawab dari fakta, dan tanpa fakta ia
    // mengarang atau menjawab hal lain ("Masih belum, saya siap membantu memilih resepnya")
    if (facts.isEmpty && !Guardrails.smallTalk(text)) {
      const answer =
          'Untuk yang satu itu saya belum punya informasi yang bisa dipegang, jadi saya tidak ingin menebak. Saya bisa '
          'membantu memilih resep dari bahan yang ada, menjelaskan cara memasak, atau menjawab soal bahan, hidangan, dan '
          'gizi makanan yang saya kenal.';
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
      ?situationFact(s.situation),
      ...facts,
    ];
    final name = userName?.trim() ?? '';
    final system = name.isEmpty ? promptChatSystem : '$promptChatSystem Nama pengguna: $name.';
    yield StatusEvent('Menyusun jawaban');
    final user = context.isEmpty ? text : 'FAKTA:\n${context.join('\n')}\n\nPertanyaan: $text';
    if (prefix.isNotEmpty) yield TokenEvent('$prefix ');
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
    // jawaban satu kalimat pendek ("Gudeg itu hidangan khas Yogyakarta.") dilengkapi kalimat dari buku resep
    if (more != null && full.isNotEmpty && full.length < 80 && !full.trim().contains(RegExp(r'[.!?]\s+\S'))) {
      yield TokenEvent(' $more');
      full = '$full $more';
    }
    if (prefix.isNotEmpty) full = '$prefix $full'.trim();
    var source = 'llm';
    if (full.isEmpty) {
      full = 'Yang itu belum bisa saya jawab dengan pasti. Coba tanyakan soal bahan, resep, gizi, atau cara memasak.';
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
  /// Menyampaikan jawaban dari catatan atau fakta. Dengan gaya natural, model menulis ulang [draft] menjadi kalimat
  /// lisan yang menanggapi pertanyaan; tulisan ulang dipakai hanya bila lolos [naturalMatches] dan [voiceMatches].
  /// Soal keamanan pangan selalu memakai kalimat catatannya sendiri.
  Stream<MeiraEvent> _say(Session s, String text, String draft, String source, {String? pending}) async* {
    var answer = draft;
    var src = source;
    if (answerStyle == 'natural' && brain != null && !_safety.hasMatch(text.toLowerCase())) {
      yield StatusEvent('Menyusun jawaban');
      final natural = await _naturalize(text, draft, strict: true);
      if (natural != null) {
        answer = natural;
        src = 'llm';
      }
    }
    yield TokenEvent(answer);
    await _remember(s, text, answer, src);
    if (pending != null) s.pending = pending;
    yield DoneEvent(answer, src);
  }

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
  Future<String?> _naturalize(String text, String core, {bool strict = false}) async {
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
      if (strict && !voiceMatches(core, line, text)) return null;
      // makanan dari permintaan pengguna yang tidak ada di jawaban buku resep ("Kepiting Saus Tiram cocok untuk buah
      // naga") ditolak; untuk jawaban pengetahuan, makanan yang disebut pengguna boleh ikut disebut
      final foods = {for (final f in knowledge?.link(strict ? '$core $text' : core, max: 12) ?? const <Fact>[]) f.title};
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

  /// Jawaban gizi dari fakta USDA: kandungan per 100 gram, perbandingan dengan kebutuhan harian (milik pengguna bila
  /// data tubuh sudah diisi, atau kebutuhan umum orang dewasa), porsi umum, dan saran singkat. Semua angka dihitung di
  /// sini, jadi tidak ada yang dikarang.
  String _nutritionAnswer(String question, Fact f, {bool more = false}) {
    final q = question.toLowerCase();
    final name = f.title.replaceFirst('Kandungan gizi ', '');
    final n = Nutrients.parse(f.text);
    if (n == null) return f.text.replaceAll(RegExp(r' \((?:[^()]|\([^()]*\))*\)'), '');
    String g(double v) => fmt(v);
    final compare = compareWithNeeds(f.title, f.text, needs ?? generalNeeds, who: needs != null ? 'Anda' : 'orang dewasa pada umumnya') ?? '';
    final portion = portions[name];
    // pertanyaan lanjutan: saran cara makan yang lebih seimbang, bukan mengulang angka yang sama
    if (more) {
      final tips = [
        if (n.sodium * 2.5 / 1000 >= 5 * .3) 'pakai setengah bumbu atau jangan habiskan kuahnya supaya garamnya berkurang',
        if (n.fat >= 67 * .3) 'pilih yang dikukus, direbus, atau dipanggang, dan tiriskan minyaknya',
        if (n.sugar >= 50 * .3) 'kurangi gula tambahan atau pilih yang tanpa gula',
        if (n.protein < 5) 'tambahkan lauk berprotein seperti telur, tahu, tempe, atau ayam',
        'padukan dengan sayur atau buah supaya seratnya cukup',
      ];
      final serving = portion == null ? '' : ' Satu ${portion.$2} sekitar ${portion.$1.round()} gram sudah cukup untuk sekali makan.';
      return 'Agar $name lebih seimbang, ${tips.take(3).join(', ')}.$serving';
    }
    // zat yang tidak tercatat di USDA (misalnya gula durian) tidak ditulis 0
    bool has(String w) => RegExp('$w [\\d,]+ ').hasMatch(f.text);
    final t = Targets.of(needs);
    final who = needs != null ? 'Anda' : 'orang dewasa';
    final (grams, unit) = portion ?? (100.0, 'porsi 100 gram');
    final unitName = unit.contains('100 g') ? 'porsi 100 gram' : unit;
    final one = n.scale(grams / 100);
    // zat yang paling banyak memakan batas harian dalam satu porsi umum
    final shares = [
      if (has('natrium')) ('garam', one.salt / t.salt),
      if (has('gula')) ('gula', one.sugar / t.sugar),
      if (has('lemak')) ('lemak', one.fat / t.fat),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final top = shares.firstOrNull;
    final high = compare.contains('tinggi') || (top != null && top.$2 >= .4);
    final perPortion =
        'Satu $unitName $name${portion == null ? '' : ' (sekitar ${grams.round()} g)'} berisi kira-kira ${one.energy.round()} kkal'
        '${top == null ? '' : ' dan memenuhi sekitar ${(top.$2 * 100).round()}% batas ${top.$1} harian $who'}.';
    final tip = [
      if (n.sodium * 2.5 / 1000 >= 5 * .3) 'pakai setengah bumbunya atau jangan habiskan kuahnya',
      if (n.fat >= 67 * .3) 'pilih yang dikukus, direbus, atau dipanggang',
      if (n.sugar >= 50 * .3) 'kurangi gula tambahannya',
      if (n.protein < 5 && n.energy > 150) 'tambahkan lauk berprotein seperti telur atau tempe',
    ].take(2).toList();
    final condition = RegExp(r'\b(diabetes|darah tinggi|hipertensi|kolesterol|asam urat|hamil|ginjal)\b').hasMatch(q)
        ? ' Untuk kondisi kesehatan tertentu, ikuti saran dokter atau ahli gizi.'
        : '';
    final asks = RegExp(r'\b(aman|boleh|bolehkah|cocok|sehat|bahaya|berbahaya|ideal|diet|gemuk|gendut|menggemukkan)\b').hasMatch(q);
    if (asks) {
      // pertanyaan kecocokan dijawab dulu dengan kesimpulan, baru angka satu porsi dan saran praktis
      final fattening = RegExp(r'\b(gemuk|gendut|menggemukkan)\b').hasMatch(q);
      final verdict = fattening
          ? (high
                ? 'Bisa, kalau sering dimakan dalam porsi besar, karena kandungannya cukup tinggi.'
                : 'Tidak, selama porsinya wajar; berat badan ditentukan oleh jumlah energi sepanjang hari.')
          : high
          ? 'Boleh, tetapi sebaiknya sesekali saja dan porsinya kecil.'
          : 'Boleh, $name aman dimakan dalam porsi wajar.';
      final advice = tip.isEmpty
          ? (high ? ' Imbangi dengan sayur dan makanan yang tidak asin, manis, atau berminyak di waktu makan lain.' : '')
          : ' Agar lebih ringan, ${_list(tip)}, lalu imbangi dengan sayur.';
      return '$verdict $perPortion$advice$condition'.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    // pertanyaan kandungan: zat yang ditanyakan lebih dulu ("protein telur berapa?"), untuk satu porsi umum bila ada,
    // lalu rincian per 100 gram
    final items = [
      'protein ${g(n.protein)} g',
      if (has('lemak')) 'lemak ${g(n.fat)} g',
      if (has('karbohidrat')) 'karbohidrat ${g(n.carbs)} g',
      if (has('gula')) 'gula ${g(n.sugar)} g',
      if (has('natrium')) 'natrium ${n.sodium.round()} mg',
    ];
    var asked = _askedNutrient(q);
    if (asked != null && asked != 'energi' && !has(asked)) asked = null;
    final energyShare = ((portion == null ? n.energy : one.energy) / t.energy * 100).round();
    final serving = 'Satu $unitName $name (sekitar ${grams.round()} gram)';
    final lead = asked != null
        ? (portion == null
              ? '$name berisi sekitar ${_amount(asked, n)} per 100 gram.'
              : '$serving berisi kira-kira ${_amount(asked, one)}, atau sekitar ${_amount(asked, n)} per 100 gram.')
        : portion == null
        ? '$name berisi sekitar ${n.energy.round()} kkal per 100 gram, kira-kira $energyShare% kebutuhan energi harian $who.'
        : '$serving berisi kira-kira ${one.energy.round()} kkal, sekitar $energyShare% kebutuhan energi harian $who.';
    final detail = portion == null && asked == null
        ? ' Menurut data USDA, kandungan lainnya per 100 gram adalah ${_list(items)}.'
        : ' Menurut data USDA, per 100 gram isinya sekitar ${n.energy.round()} kkal, dengan ${_list(items)}.';
    final caution = high ? ' Kandungan ${top?.$1 ?? 'lemak'}nya cukup tinggi, jadi porsinya sebaiknya dibatasi.' : '';
    return '${lead[0].toUpperCase()}${lead.substring(1)}$detail$caution$condition'.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Zat gizi yang ditanyakan secara khusus ("kalori", "protein", "garam"), atau null.
  static String? _askedNutrient(String q) =>
      switch (RegExp(r'\b(kalori|kkal|energi|protein|lemak|karbohidrat|karbo|gula|garam|natrium|sodium)\b').firstMatch(q)?[1]) {
        null => null,
        'kalori' || 'kkal' || 'energi' => 'energi',
        'karbohidrat' || 'karbo' => 'karbohidrat',
        'garam' || 'natrium' || 'sodium' => 'natrium',
        final w => w,
      };

  static String _amount(String field, Nutrients n) => switch (field) {
    'energi' => '${n.energy.round()} kkal',
    'protein' => '${fmt(n.protein)} g protein',
    'lemak' => '${fmt(n.fat)} g lemak',
    'karbohidrat' => '${fmt(n.carbs)} g karbohidrat',
    'gula' => '${fmt(n.sugar)} g gula',
    _ => '${n.sodium.round()} mg natrium',
  };

  /// Jawaban untuk makan atau minum [f] saat pengguna berpuasa: pembatasan waktu makan memakai jendela makan, puasa
  /// Ramadan memakai sahur dan berbuka. Null bila pengguna tidak sedang berpuasa atau pertanyaannya bukan soal boleh.
  String? _fastingAnswer(Fact f, String q, Session s) {
    final ramadan = s.situation.contains('puasa'), window = s.situation.contains('puasa_if');
    if ((!ramadan && !window) || !RegExp(r'\b(boleh|bisa|gimana|bagaimana|kalau|cocok|enak|aman)\b').hasMatch(q)) return null;
    final name = f.title.replaceFirst('Kandungan gizi ', '');
    final n = Nutrients.parse(f.text);
    if (n == null) return null;
    final (grams, unit) = portions[name] ?? (100.0, 'porsi 100 gram');
    final unitName = unit.contains('100 g') ? 'porsi 100 gram' : unit;
    final one = n.scale(grams / 100);
    final drink = RegExp(r'\b(minum|minuman)\b').hasMatch(q) || unit == 'gelas' || unit == 'kaleng';
    final verb = drink ? 'diminum' : 'dimakan';
    if (window) {
      final plan = appData?.fasting;
      final hours = plan == null ? '' : ', yaitu pukul ${clock(plan.startMinute)} sampai ${clock(plan.endMinute)}';
      return one.energy <= 10
          ? '$name hampir tidak berenergi (sekitar ${one.energy.round()} kkal per $unitName), jadi boleh $verb di luar jendela makan.'
          : '$name berisi sekitar ${one.energy.round()} kkal per $unitName, jadi sebaiknya $verb di dalam jendela makan saja$hours.';
    }
    final t = Targets.of(needs);
    final salty = one.salt / t.salt >= .3, sweet = one.sugar / t.sugar >= .3;
    final when = q.contains('sahur')
        ? (salty
              ? ' Untuk sahur, $name kurang cocok karena garamnya tinggi sehingga membuat cepat haus.'
              : ' Untuk sahur, pilih juga lauk berprotein dan sayur supaya kenyang lebih lama.')
        : q.contains('buka') || q.contains('berbuka')
        ? (sweet ? ' Untuk berbuka, cukup sedikit saja karena gulanya tinggi.' : ' Saat berbuka, awali dengan air putih lalu makan secukupnya.')
        : '';
    return 'Saat puasa Ramadan, $name baru bisa $verb saat sahur atau berbuka. Satu $unitName berisi kira-kira ${one.energy.round()} kkal.$when';
  }

  /// Resep di buku untuk hidangan [dish]: namanya disebut utuh, atau satu-satunya resep yang namanya memuat nama hidangan
  /// itu ("Rendang" menjadi Rendang Daging).
  Recipe? _bookFor(String dish) {
    final exact = namedRecipe(recipes, dish);
    if (exact != null) return exact;
    final d = norm(dish);
    final hits = recipes.where((r) => ' ${norm(r.name)} '.contains(' $d ')).toList();
    return hits.length == 1 ? hits.first : null;
  }

  /// Nama hidangan di [text] yang lebih panjang dari nama makanan [f] dan memuatnya ("tempe mendoan" untuk fakta gizi
  /// tempe), atau null.
  String? _longerDish(String text, Fact f) {
    final t = ' ${norm(text)} ';
    final base = f.names.map(norm).where((n) => t.contains(' $n ')).fold('', (a, b) => b.length > a.length ? b : a);
    if (base.isEmpty) return null;
    return knowledge?.namesIn(text).where((n) => n.length > base.length && n.contains(base)).firstOrNull;
  }

  /// Catatan dapur yang judulnya cocok dan meliput sebagian besar kata pertanyaan, atau null.
  Note? _strongNote(String query) {
    final kb = knowledge;
    if (kb == null) return null;
    final terms = kb.termCount(query);
    for (final (note, _, hits) in kb.search(query, k: 1)) {
      if (terms > 0 && hits / terms >= .5 && kb.titleShares(note, query)) return note;
    }
    return null;
  }

  /// Jawaban "porsinya berapa?" atau "kalau tiap hari?" untuk makanan [f]: persentase batas harian dalam satu porsi umum.
  String _portionAnswer(Fact f, {required bool often}) {
    final name = f.title.replaceFirst('Kandungan gizi ', '');
    final n = Nutrients.parse(f.text)!;
    final (grams, unit) = portions[name] ?? (100.0, 'porsi (100 g)');
    final one = n.scale(grams / 100);
    final t = Targets.of(needs);
    final unitName = unit.contains('100 g') ? 'porsi 100 gram' : unit;
    final shares = [('garam', one.salt / t.salt), ('gula', one.sugar / t.sugar), ('lemak', one.fat / t.fat)]..sort((a, b) => b.$2.compareTo(a.$2));
    final top = shares.first;
    final heavy = top.$2 >= .4;
    final head =
        'Satu $unitName $name sekitar ${grams.round()} gram berisi kira-kira ${one.energy.round()} kkal '
        'dan memenuhi sekitar ${(top.$2 * 100).round()}% batas ${top.$1} harian.';
    if (!often) {
      return heavy
          ? '$head Jadi satu $unitName sudah cukup untuk sehari, dan makanan lain hari itu sebaiknya rendah ${top.$1}.'
          : '$head Porsi itu wajar untuk sekali makan.';
    }
    return heavy
        ? '$head Kalau dimakan setiap hari, sisa batas ${top.$1} untuk makanan lain hampir habis, jadi sebaiknya sesekali saja '
              'dan diimbangi sayur.'
        : '$head Boleh dimakan setiap hari dalam porsi itu sebagai bagian dari menu yang seimbang.';
  }

  /// Apakah teks menyebut resep [r] (kata khas namanya, bukan kata umum seperti "goreng").
  static bool _namesRecipe(Recipe r, String text) {
    final words = RegExp(r'[a-z]+').allMatches(r.name.toLowerCase()).map((m) => m[0]!).where((w) => w.length >= 4);
    final t = text.toLowerCase();
    return words.any((w) => !const {'goreng', 'rebus', 'kukus', 'bakar', 'tumis', 'sayur', 'kuah', 'saus', 'segar'}.contains(w) && t.contains(w));
  }

  static String _list(List<String> xs) => xs.length <= 1 ? xs.join() : '${xs.sublist(0, xs.length - 1).join(', ')}, dan ${xs.last}';

  /// Fakta hidangan dari buku resep: deskripsi, bahan utama, dan bumbu, untuk pertanyaan "apa itu klepon?".
  String _bookFact(Recipe r) {
    final main = [for (final i in r.items.where((i) => i.main)) i.name];
    final rest = [for (final i in r.items.where((i) => !i.main && !i.optional && i.key != 'water')) i.name];
    return 'Buku resep MEIRA, ${r.name}: ${r.desc} Bahan utama: ${main.join(', ')}. Bahan lain: ${rest.join(', ')}. '
        'Waktu memasak sekitar ${r.minutes} menit.';
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
    // tawaran menjelaskan langkah diingat, supaya balasan "iya" berikutnya dimengerti
    s.pending = _offersSteps.hasMatch(answer) && s.currentMatch != null ? 'langkah' : null;
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
      return 'Buku resep belum punya resep yang cocok untuk itu. Coba foto lain, sebutkan bahan yang Anda miliki, atau longgarkan batas waktunya.';
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
      final prep = s.imageDataUrl == null
          ? [
              for (final i in r.items)
                if (cur.missing.contains(i.key)) i.name,
            ]
          : [...missing, ...confirm];
      return 'Berikut cara membuat ${r.name}.${prep.isNotEmpty ? ' Siapkan terlebih dahulu ${prep.join(', ')}.' : ''}\n$steps';
    }
    if (task == 'substitusi') {
      final k = resolve(extra['ingredient'] ?? '');
      if (k != null && r.swaps.containsKey(k)) return 'Untuk ${r.name}, ${displayName(k)} dapat diganti dengan ${r.swaps[k]}.';
      return 'Buku resep belum memiliki saran pengganti ${extra['ingredient']} untuk ${r.name}.';
    }
    var txt = 'Bagaimana kalau ${r.name}? Waktu memasaknya sekitar ${r.minutes} menit.';
    if (seen.isNotEmpty) txt += ' Dari foto, sudah tersedia ${seen.join(', ')}.';
    if (s.imageDataUrl == null) {
      // tanpa foto tidak ada bahan yang "terlihat" atau "tidak terlihat": semua bahan disebut berurutan seperti di resep
      final all = [
        for (final i in r.items)
          if (cur.missing.contains(i.key)) i.name,
      ];
      if (all.isNotEmpty) txt += ' Bahan yang perlu disiapkan adalah ${all.join(', ')}.';
    } else {
      if (missing.isNotEmpty) txt += ' Bahan yang perlu disiapkan adalah ${missing.join(', ')}.';
      if (confirm.isNotEmpty) txt += ' Mohon pastikan juga tersedia ${confirm.join(', ')}.';
    }
    final others = [
      for (final m in s.candidates)
        if (m != cur) m.recipe.name,
    ];
    if (others.isNotEmpty) txt += ' Pilihan lainnya ${others.join(' atau ')}.';
    return '$txt Apakah Anda ingin saya jelaskan langkah-langkahnya?';
  }
}

final _ref = RegExp(r'\s*\(?\s*(?:#|nomor\s+|no\.\s*)(\d+)(?:\s*(?:,|dan|-|–)\s*(?:#|nomor\s+)?\d+)*\s*\)?', caseSensitive: false);

/// Pertahankan rujukan nomor (#n) hanya bila nama bahan nomor itu memang disebut tepat sebelumnya,
/// lalu bersihkan label konteks yang bocor dan tanda pisah panjang.
/// Buang kalimat terakhir yang terpotong batas token agar jawaban tidak berhenti di tengah kata.
/// Balasan "ya" atas tawaran MEIRA.
bool isYes(String text) => RegExp(
  r'^(?:iya|ya|yap|yup|yes|boleh|mau|oke|ok|okay|sip|siap|lanjut|gas|silakan|tolong|bisa|jelaskan|tentu|betul|benar)'
  r'(?: (?:dong|deh|ya|aja|saja|kak|min|banget|sekali|mau|boleh|lanjut|jelaskan|tolong|silakan|langkahnya|caranya|meira|lah|nih))*$',
).hasMatch(text.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim());

/// Balasan "tidak" atas tawaran MEIRA.
bool isNo(String text) => RegExp(
  r'^(?:tidak|nggak|gak|ga|enggak|ngga|no|nanti|skip|cukup)(?: (?:jadi|usah|dulu|aja|saja|deh|ya|kak|min|terima kasih|makasih|sekarang))*$',
).hasMatch(text.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim());

/// Jenis pertanyaan lanjutan tentang makanan yang baru dibahas: kiat ("biar lebih sehat"), frekuensi ("kalau tiap
/// hari"), atau porsi ("porsinya berapa"); null bila bukan.
String? _nutritionFollowUp(String text) {
  final t = text.toLowerCase();
  if (t.split(' ').length > 10) return null;
  if (RegExp(r'\b(tiap|setiap|sering|rutin|keseringan|terus-terusan)\b').hasMatch(t)) return 'often';
  if (RegExp(r'\b(porsi|porsinya|berapa banyak|seberapa banyak|sehari berapa|berapa (bungkus|butir|potong|gelas|piring|gram))\b').hasMatch(t)) {
    return 'portion';
  }
  if (RegExp(r'\b(biar|supaya|agar|gimana|bagaimana)\b.*\b(sehat|ringan|seimbang|aman)\b|\blebih sehat\b').hasMatch(t)) return 'tips';
  return null;
}

final _offersSteps = RegExp(r'jelaskan (langkah|cara membuat)');

/// Jawaban pertanyaan singkat tentang resep [r]: lama memasak, jumlah porsi, tingkat kesulitan, atau alat; null bila
/// pertanyaannya tentang hal lain.
String? recipeFact(Recipe r, String t) {
  if (t.split(' ').length > 9) return null;
  // "langkah ketiga maksudnya gimana?": satu langkah itu saja, bukan seluruh langkah diulang
  final step = RegExp(r'\blangkah (?:ke-?|nomor )?(\d+|[a-z]+)\b').firstMatch(t);
  final n = step == null
      ? null
      : (int.tryParse(step[1]!) ?? _ordinals[step[1]!.replaceFirst(RegExp(r'^ke'), '')] ?? (step[1] == 'terakhir' ? r.steps.length : null));
  if (n != null) {
    return n >= 1 && n <= r.steps.length ? 'Langkah $n untuk ${r.name}: ${r.steps[n - 1]}' : 'Resep ${r.name} hanya punya ${r.steps.length} langkah.';
  }
  if (RegExp(r'\b(berapa lama|berapa menit|lama masak|lama memasak|waktu masak|waktu memasak|butuh waktu)\b').hasMatch(t)) {
    return '${r.name} butuh waktu sekitar ${r.minutes} menit.';
  }
  if (RegExp(r'\b(berapa porsi|berapa orang|untuk berapa|jadi berapa|porsinya berapa|cukup untuk)\b').hasMatch(t)) {
    return 'Resep ${r.name} ini untuk sekitar ${r.servings} porsi.';
  }
  if (RegExp(r'\b(susah|sulit|gampang|mudah|ribet)\b').hasMatch(t)) {
    return 'Tingkat kesulitan ${r.name} tergolong ${r.difficulty}, dengan waktu sekitar ${r.minutes} menit.';
  }
  if (RegExp(r'\b(alat|alatnya|perlengkapan|peralatan)\b').hasMatch(t)) {
    return r.tools.isEmpty
        ? 'Buku resep tidak mencatat alat khusus untuk ${r.name}; alat dapur biasa sudah cukup.'
        : 'Alat yang dipakai untuk ${r.name}: ${r.tools.join(', ')}.';
  }
  return null;
}

const _ordinals = {
  'satu': 1,
  'pertama': 1,
  'dua': 2,
  'tiga': 3,
  'empat': 4,
  'lima': 5,
  'enam': 6,
  'tujuh': 7,
  'delapan': 8,
  'sembilan': 9,
  'sepuluh': 10,
};

final _ingredientsQuestion = RegExp(r'\b(bahannya|bahan apa|bahan-bahannya|terbuat dari|dibuat dari|isinya apa|isinya)\b|^bahan\b.*\bapa\b');

/// Pertanyaan susulan yang merujuk ke hal yang baru dibahas: kata ganti "-nya", "itu", "tadi", atau pertanyaan pendek.
bool _refersBack(String t) =>
    RegExp(r'\b\w+nya\b|\b(itu|tersebut|tadi|yang tadi|ini)\b').hasMatch(t) ||
    (_knowledgeQuestion(t) && t.split(RegExp(r'[^a-z]+')).where((w) => w.length > 2 && !_askWords.contains(w)).length <= 1);

// kata tanya dan kata umum yang bukan pokok pertanyaan: "kenapa?" atau "berapa kalori?" merujuk ke hal sebelumnya,
// "siapa presiden indonesia" tidak
const _askWords = {
  'apa',
  'apakah',
  'kenapa',
  'mengapa',
  'bagaimana',
  'gimana',
  'berapa',
  'kapan',
  'mana',
  'siapa',
  'boleh',
  'bolehkah',
  'bisa',
  'aman',
  'sih',
  'kok',
  'dong',
  'yang',
  'ada',
  'tidak',
  'nggak',
  'gak',
  'kalau',
  'kalo',
  'terus',
  'lalu',
  'juga',
  'saja',
  'aja',
  'lebih',
  'dari',
  'untuk',
  'buat',
  'kalori',
  'cara',
  'caranya',
  'asal',
  'asalnya',
  'enak',
  'sehat',
};

final _originQuestion = RegExp(r'\b(asal|asalnya|berasal|dari mana|darimana|daerah mana|khas mana|khas daerah)\b');

/// Asal sebuah hidangan menurut fakta Wikidata: keterangannya ("olahan daging yang berbumbu khas Minangkabau") dan
/// kolom asalnya.
String originAnswer(Fact f) {
  final name = f.title;
  final head = f.text.split(RegExp(r'\. (?=Jenis:|Bahan:|Asal:|Nama lain:)')).first;
  final desc = head.contains(': ') ? head.substring(head.indexOf(': ') + 2).replaceAll(RegExp(r'\.+$'), '') : '';
  final from = RegExp(r'Asal: ([^.]+)\.').firstMatch(f.text)?[1] ?? '';
  final what = desc.isEmpty ? '' : '${desc[0].toLowerCase()}${desc.substring(1)}';
  final title = '${name[0].toUpperCase()}${name.substring(1)}';
  // "makanan khas Banjar, Indonesia" sudah menyebut asalnya
  if (from.isEmpty || norm(what).contains(norm(from))) return '$title adalah $what.';
  return '$title berasal dari $from.${what.isEmpty ? '' : ' $title adalah $what.'}';
}

/// "apa itu klepon?", "gudeg itu makanan apa?", atau "jelaskan tentang rendang": pertanyaan definisi tentang [name].
bool whatIs(String text, String name) {
  final n = norm(name);
  var t = ' ${norm(text)} ';
  if (n.isEmpty || !t.contains(' $n ')) return false;
  t = t.replaceFirst(' $n ', ' # ').replaceAll(RegExp(r'\b(ya|sih|tuh|kak|min|dong|deh|nih|meira|sebenarnya)\b'), ' ');
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  return RegExp(
    r'^(apa itu|apaan|apa|jelaskan|jelaskan tentang|ceritakan|ceritakan tentang|tahu|kamu tahu|kenal|kamu kenal) #( itu)?$|'
    r'^# (itu )?(apa|apaan|(makanan|minuman|kue|buah|sayur|hidangan|masakan|jajanan|bahan|bumbu) apa)$',
  ).hasMatch(t);
}

/// Jawaban dari catatan [n]: kalimat yang paling menjawab pertanyaan diletakkan di depan ("kenapa nasi saya lembek?"
/// dibuka dengan "Nasi terlalu lembek berarti airnya kebanyakan"), sisanya mengikuti urutan catatan. Kalimat yang
/// merujuk ke kalimat sebelumnya ("Cara ini ...") tidak dipindah.
String noteAnswer(String question, Note n) {
  final sentences = n.body.split(RegExp(r'(?<=[.!?])\s+(?=[A-Z])'));
  if (sentences.length < 2) return n.body;
  var best = 0;
  var top = KnowledgeBase.shared(question, sentences.first);
  for (var i = 1; i < sentences.length; i++) {
    final score = KnowledgeBase.shared(question, sentences[i]);
    if (score > top) {
      best = i;
      top = score;
    }
  }
  if (best == 0 ||
      top < 2 ||
      KnowledgeBase.shared(question, sentences.first) > 0 ||
      RegExp(r'\bjuga\b|^(Ini|Itu|Cara ini|Hal ini|Karena itu|Selain itu|Namun|Tetapi|Jadi|Dengan begitu)\b').hasMatch(sentences[best])) {
    return n.body;
  }
  return [
    sentences[best],
    for (var i = 0; i < sentences.length; i++)
      if (i != best) sentences[i],
  ].join(' ');
}

/// Pemeriksaan tambahan untuk tulisan ulang jawaban pengetahuan: tidak mengulang atau membalas dengan pertanyaan,
/// tetap menyebut nama diri (daerah, suku, negara), dan tetap memuat larangan, batasan, atau anjuran ke dokter yang
/// ada di jawaban asli.
bool voiceMatches(String core, String rewrite, String question) {
  final a = rewrite.toLowerCase(), c = core.toLowerCase();
  if (a.contains('?') && !c.contains('?')) return false;
  final first = a.split(RegExp(r'(?<=[.!?])\s+')).first;
  final asked = norm(question).split(' ').where((w) => w.length > 2).toSet();
  final opening = norm(first).split(' ').toSet();
  if (asked.length >= 3 && asked.difference(opening).length <= asked.length * .2) return false;
  for (final m in RegExp(r'(?<=[a-z,] )[A-Z][a-z]+').allMatches(core)) {
    if (const {'Wikidata', 'Wikipedia', 'USDA', 'MEIRA', 'Anda'}.contains(m[0])) continue;
    if (!rewrite.contains(m[0]!)) return false;
  }
  for (final kind in [
    RegExp(r'\b(tidak|jangan|bukan|hindari|kurang)\b'),
    RegExp(r'\b(sesekali|batasi|dibatasi|secukupnya|sedikit|cukup)\b'),
    RegExp(r'\b(dokter|ahli gizi|bidan)\b'),
  ]) {
    if (kind.hasMatch(c) && !kind.hasMatch(a)) return false;
  }
  return true;
}

final _fastingTalk = RegExp(r'\b(puasa|jendela makan|pembatasan waktu makan|sahur|buka|berbuka|ramadan|ramadhan|intermittent|fasting|takjil)\b');

// keamanan pangan: makanan mentah, setengah matang, basi, atau minyak bekas
final _safety = RegExp(
  r'\b(setengah matang|mentah|kurang matang|basi|berjamur|busuk|kedaluwarsa|kadaluarsa|kadaluwarsa|expired|beracun|keracunan|jelantah|bekas)\b',
);

// pertanyaan tentang kandungan atau kecocokan sebuah makanan, yang dijawab dengan angka gizi
final _suitability = RegExp(
  r'\b(cocok|sehat|ideal|diet|kalori|kkal|gizi|nutrisi|kandungan|protein|lemak|karbohidrat|gula|garam|natrium|serat|vitamin|mineral|'
  r'gemuk|gendut|menggemukkan)\b',
);

// pertanyaan tentang sifat, keamanan, asal, atau kiat
bool _knowledgeQuestion(String t) =>
    t.contains('?') ||
    RegExp(
      r'\b(apa|apakah|kenapa|mengapa|bagaimana|gimana|boleh|bolehkah|aman|bahaya|berbahaya|berapa|kapan|asal|asalnya|'
      r'darimana|siapa|ciri|cirinya|maksud|arti|artinya|kok|bisakah|haruskah|perlu|perlukah)\b',
    ).hasMatch(t) ||
    RegExp(r'\b(tidak|kah)$').hasMatch(t);

// permintaan resep yang jelas
final _recipeRequest = RegExp(
  r'\b(resep|masak apa|memasak apa|bikin apa|buat apa|dibuat apa|diolah|olahan|dimasak|rekomendasi|saran|ide|menu|'
  r'cara (bikin|buat|membuat|masak|memasak|mengolah)(nya)?|bikinnya|masaknya|langkah|mau masak|ingin masak|pengen masak|enaknya dimasak|jadi apa)\b',
);

// "sayur apa yang cocok buat anak?": permintaan saran resep berbentuk pertanyaan
final _suggestRequest = RegExp(r'\b(apa|yang)\b.*\b(cocok|enak|bagus|pas)\b.*\b(buat|untuk)\b');

// "bisa diganti pakai nasi merah?", "ganti dengan tahu boleh?"
final _replacement = RegExp(
  r'\b(?:diganti|ganti|gantikan)\s+(?:pakai|pake|dengan|jadi|sama|ke)\s+([a-z ]{3,30}?)(?:\s+(?:tidak|nggak|gak|ga|bisa|boleh|aja|saja|ya|dong|kah))*\s*\??$',
);

/// Jawaban bahan pengganti untuk resep [r]: bahan resep yang paling mirip dengan [replacement] ("nasi merah" untuk
/// "nasi") diganti dalam jumlah yang sama; saran pengganti dari buku resep ikut disebut bila ada.
String _swapAnswer(Recipe r, String replacement) {
  final words = replacement.split(' ');
  final item =
      r.items.where((i) => i.name.toLowerCase() == replacement).firstOrNull ??
      r.items.where((i) => words.contains(i.name.toLowerCase().split(' ').first)).firstOrNull;
  if (item == null) {
    return 'Di resep ${r.name} tidak ada bahan yang mirip $replacement, jadi saya belum bisa memastikan hasilnya. '
        'Bahan utamanya ${[for (final i in r.items.where((i) => !i.optional).take(4)) i.name].join(', ')}.';
  }
  if (item.name.toLowerCase() == replacement) return '$replacement memang sudah dipakai di resep ${r.name}.';
  final note = r.swaps[item.key];
  return 'Bisa. Untuk ${r.name}, ${item.name} dapat diganti $replacement dengan jumlah yang sama.'
      '${note == null ? '' : ' Buku resep juga menyarankan pengganti ${item.name}: $note.'}';
}

final _compareWords = RegExp(
  r'\b(beda|bedanya|perbedaan|dibanding|dibandingkan|bandingkan|banding|vs|versus|lebih (sehat|baik|bagus) mana|mana yang lebih|'
  r'(bagusan|baikan|sehatan|mending|pilih) mana|mana yang (bagus|baik|sehat))\b',
);

/// Balasan untuk ucapan terima kasih, sapaan, atau persetujuan singkat; null bila pesan berisi hal lain.
String? smallTalkReply(String text) {
  final t = text.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  const tail = r'(?: (?:ya|yah|ya meira|meira|kak|min|banyak|banget|sekali|semua|deh|nih))*';
  if (RegExp('^(?:terima kasih|terimakasih|makasih|makasi|thanks|thank you|thx|trims|tengkyu)$tail\$').hasMatch(t)) {
    return 'Sama-sama. Kalau ingin mencari resep, menanyakan gizi makanan, atau mencatat makan hari ini, silakan tulis saja.';
  }
  if (RegExp('^(?:halo|hai|hi|hello|hey|pagi|siang|sore|malam|selamat (?:pagi|siang|sore|malam)|assalamualaikum)$tail\$').hasMatch(t)) {
    return 'Halo! Saya bisa mencarikan resep dari foto atau bahan yang ada, menjawab pertanyaan gizi, dan mencatat makan Anda. '
        'Mau mulai dari mana?';
  }
  if (RegExp('^(?:oke|ok|okay|baik|siap|sip|mantap)$tail\$').hasMatch(t)) return 'Baik. Kabari saja bila ada yang ingin ditanyakan.';
  if (RegExp(
    r'^(?:(?:ceritakan|ceritain|jelaskan|perkenalkan)(?: dong)? (?:tentang |soal )?(?:dirimu|dirimu sendiri|diri kamu|kamu|diri anda|meira)|'
    r'(?:kamu|anda|meira) (?:itu )?(?:siapa|apa)|siapa (?:kamu|anda|meira)|perkenalkan dirimu)(?: (?:dong|ya|sih|nih|deh))*$',
  ).hasMatch(t)) {
    return 'Saya MEIRA (Multimodal Eating Intelligence & Recipe Assistant), asisten masak dan gizi yang berjalan langsung di ponsel '
        'tanpa internet. Saya bisa mengenali bahan dari foto, menyarankan resep dari buku berisi 286 resep, menjawab pertanyaan gizi, '
        'serta mencatat makan, berat badan, dan jendela makan Anda.';
  }
  return null;
}

/// Perbandingan dua makanan per 100 gram dari fakta gizi USDA, beserta zat yang jelas berbeda. Selisih kecil (misalnya
/// natrium 1 dan 28 mg) tidak disebut sebagai perbedaan.
String? compareNutrition(Fact a, Fact b, {String question = ''}) {
  final na = Nutrients.parse(a.text), nb = Nutrients.parse(b.text);
  if (na == null || nb == null) return null;
  double fiber(Fact f) => double.tryParse(RegExp(r'serat ([\d,]+) g').firstMatch(f.text)?[1]?.replaceAll(',', '.') ?? '') ?? 0;
  // nama seperti yang ditulis pengguna bila itu salah satu sebutan makanannya ("gula pasir", bukan "gula")
  final q = ' ${question.toLowerCase()} ';
  String said(Fact f) => ([...f.names]..sort((m, n) => n.length.compareTo(m.length)))
      .map((n) => n.toLowerCase())
      .firstWhere((n) => q.contains(' $n '), orElse: () => f.title.replaceFirst('Kandungan gizi ', ''));
  final x = said(a), y = said(b);
  String line(String name, Nutrients n, double serat) =>
      '$name sekitar ${n.energy.round()} kkal, protein ${fmt(n.protein)} g, lemak ${fmt(n.fat)} g, serat ${fmt(serat)} g, '
      'gula ${fmt(n.sugar)} g, dan natrium ${n.sodium.round()} mg';
  // (nama, nilai a, nilai b, selisih minimum yang dianggap berarti)
  final rows = [
    ('energi', na.energy, nb.energy, 20.0),
    ('protein', na.protein, nb.protein, 2.0),
    ('lemak', na.fat, nb.fat, 2.0),
    ('serat', fiber(a), fiber(b), 1.0),
    ('gula', na.sugar, nb.sugar, 2.0),
    ('garam', na.sodium, nb.sodium, 100.0),
  ];
  final diffs = [
    for (final (label, va, vb, min) in rows)
      if ((va - vb).abs() >= min && (va - vb).abs() > .15 * math.max(va, vb)) '$label ${va > vb ? x : y} lebih tinggi',
  ];
  final verdict = diffs.isEmpty ? ' Kandungan keduanya hampir sama.' : ' ${_capital(diffs.join(', '))}.';
  return 'Per 100 gram, ${line(x, na, fiber(a))}, sedangkan ${line(y, nb, fiber(b))} (perkiraan USDA).$verdict';
}

String _capital(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String completeSentences(String text) {
  final t = text.trim();
  if (t.isEmpty || RegExp(r'[.!?]["”)]?$').hasMatch(t)) return t;
  final end = t.lastIndexOf(RegExp(r'[.!?](\s|$)'));
  if (end > 0) return t.substring(0, end + 1);
  // satu kalimat tanpa titik yang berhenti di kata sambung ("... informasi pasti tentang") jelas terpotong; dibuang
  // supaya pemanggil memakai jawaban cadangan
  return _dangling.hasMatch(t) ? '' : '$t.';
}

final _dangling = RegExp(
  r'\b(tentang|dan|atau|yang|dengan|untuk|di|ke|dari|pada|dalam|karena|seperti|serta|adalah|ialah|yaitu|bahwa|agar|supaya|'
  r'sehingga|tetapi|namun|juga|lebih|sangat|para|sebuah|seorang|bisa|dapat|akan|harus)$',
  caseSensitive: false,
);

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
  final alt = RegExp(r'(?:Sebagai alternatif, Anda dapat memilih|Pilihan lainnya) ([^.]*)\.').firstMatch(core);
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

final _tabQuestion = RegExp(r'\b(ini|sekarang|tab|fokus|mode)\b.*\b(gizi\b.*\batau\b.*\bresep|resep\b.*\batau\b.*\bgizi)\b');
final _followUp = RegExp(
  r'^\W*(apa |terus |lalu |trus )?(lanjut|lanjutannya|lanjutkan|terusnya|selanjutnya|apa lagi|lagi dong|yang lain|lebih lanjut|'
  r'lebih lengkap|lebih detail|jelaskan lagi|maksudnya|maksudnya apa|kenapa|kenapa begitu)\W*$',
);
final _cookingWords = RegExp(r'\b(cara|resep|masak|memasak|bikin|membuat|langkah|berapa lama|merebus|menggoreng|menyimpan|simpan)\b');
final _nutritionQuestion = RegExp(
  r'\b(gizi|kalori|kkal|protein|lemak|karbohidrat|natrium|kandungan|cocok untuk (saya|aku)|masih ideal|ideal (nggak|gak|tidak|enggak)|'
  r'sehat (nggak|gak|tidak|enggak)|aman untuk diet|boleh (dimakan|makan) (saat|waktu) diet)\b',
);
final _personal = RegExp(r'\b(saya|aku|untukku|buatku|diet|ideal|kebutuhan|harian|berat badan)\b');

final _labelFollowUp = RegExp(
  r'\b(semua|semuanya|seluruh|sekaligus|satu kemasan|sebungkus|habis|berapa sajian|porsi|sebaiknya|boleh dimakan|aman)\b',
);
