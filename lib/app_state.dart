/// Keadaan aplikasi: model on-device, sesi percakapan, suara, dan pengaturan.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/grounding.dart';
import 'core/history.dart';
import 'core/pipeline.dart';
import 'core/recipes.dart';
import 'core/vocab.dart';
import 'llm/knowledge.dart';
import 'runtime/device.dart';
import 'runtime/llama.dart';
import 'runtime/models.dart';
import 'runtime/speech.dart';
import 'vision/vision.dart';

enum Phase { booting, needsModels, ready, failed }

enum VoiceState { idle, listening, transcribing, speaking }

enum Role { user, meira, status, error }

class Message {
  Message(this.role, this.text, {this.photo, this.source, this.streaming = false});
  final Role role;
  String text;
  final Uint8List? photo;
  String? source;
  bool streaming;
}

class BootStep {
  BootStep(this.title);
  final String title;
  bool done = false;
}

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  // ------------------------------------------------------------- komponen
  late Models models;
  late History history;
  List<Recipe> recipes = [];
  KnowledgeBase? knowledge;
  LlamaServer? _brainServer;
  Speech? speech;
  Meira? meira;

  Phase phase = Phase.booting;
  String bootError = '';
  final steps = [BootStep('Membuka buku resep'), BootStep('Menyiapkan model penglihatan'), BootStep('Menyiapkan model bahasa'), BootStep('Pemanasan')];
  String get bootLabel => steps.firstWhere((s) => !s.done, orElse: () => steps.last).title;
  double get bootProgress => steps.where((s) => s.done).length / steps.length;
  Vision? vision; // detektor bahan dan OCR kemasan, terpisah dari model bahasa
  VisionInput? _visionInput;

  // ------------------------------------------------------------- pengaturan
  bool speakAnswers = false;
  bool handsFree = false;
  bool releaseInBackground = true;
  int imageSide = 512; // foto untuk model bahasa (makanan jadi); detektor selalu memakai 640 x 640
  String photoMode = 'otomatis';
  String answerStyle = 'ringkas';
  bool thorough = false;
  String? voiceName;
  String? userName; // nama panggilan, disimpan di perangkat
  bool readPackages = true;

  // ------------------------------------------------------------- sesi
  Session? session;
  Uint8List? photo; // foto yang ditampilkan
  Size? photoSize;
  List<Detection> detections = [];
  List<Detection> partial = [];
  String? sceneMode;
  String? dish;
  double? detectSeconds;
  bool busy = false;
  bool scanning = false;
  Set<int> highlighted = {};
  final List<Message> messages = [];
  VoiceState voice = VoiceState.idle;
  Timer? _vad;
  StreamSubscription<double>? _vadSub;
  Timer? _backgroundTimer;
  bool _observing = false;

  List<Match> get candidates => session?.candidates ?? [];
  Match? get currentMatch => session?.currentMatch;

  // =============================================================== boot
  Future<void> boot() async {
    final started = DateTime.now();
    phase = Phase.booting;
    bootError = '';
    for (final s in steps) {
      s.done = false;
    }
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      speakAnswers = p.getBool('speak') ?? false;
      handsFree = false;
      releaseInBackground = p.getBool('release_bg') ?? true;
      imageSide = p.getInt('image_side') ?? 512;
      photoMode = p.getString('photo_mode') ?? 'otomatis';
      answerStyle = p.getString('answer_style') ?? 'ringkas';
      thorough = p.getBool('thorough') ?? false;
      voiceName = p.getString('voice_name');
      userName = p.getString('user_name');
      readPackages = p.getBool('read_packages') ?? true;

      models = await Models.open();
      if (models.missingRequired().isNotEmpty) {
        phase = Phase.needsModels;
        notifyListeners();
        return;
      }
      recipes = parseRecipes(await rootBundle.loadString('assets/resep.md'));
      knowledge = KnowledgeBase.parse(await rootBundle.loadString('assets/pengetahuan.md'));
      history = await History.open();
      _done(0);
      vision ??= IsolateVision(await _visionPaths(), threads: math.min(4, Device.inferenceThreads));
      _done(1);
      await _startModels();
      speech = Speech(SpeechPaths.of(models), threads: math.min(4, Device.inferenceThreads))..voiceName = voiceName;
      meira = Meira(
        recipes: recipes,
        history: history,
        eyes: null,
        vision: vision,
        brain: _brainServer?.client,
        useLlmIntent: false, // aturan 0,99 (set terpisah 1,0) jauh di atas model 0,31 sampai 0,61; lihat docs/evaluasi.md
        answerStyle: answerStyle,
        parallelVision: false,
        thorough: thorough,
        readPackages: readPackages,
        knowledge: knowledge,
      )..userName = userName;
      await _warmup();
      _done(3);
      final wait = 5000 - DateTime.now().difference(started).inMilliseconds;
      if (wait > 0) await Future.delayed(Duration(milliseconds: wait));
      phase = Phase.ready;
      if (!_observing) {
        WidgetsBinding.instance.addObserver(this);
        _observing = true;
      }
    } catch (e) {
      bootError = '$e';
      phase = Phase.failed;
    }
    notifyListeners();
  }

  void _done(int i) {
    steps[i].done = true;
    notifyListeners();
  }

  /// Model bahasa hanya untuk percakapan dan mengenali makanan jadi; penandaan bahan dikerjakan detektor.
  Future<void> _startModels() async {
    final brainModel = models.path(brainPack.files[0].name), brainProj = models.path(brainPack.files[1].name);
    _brainServer = LlamaServer(name: 'otak', model: brainModel, mmproj: brainProj, port: 8392);
    await _brainServer!.start(maxImageTokens: _imageTokens);
    _done(2);
  }

  /// Model penglihatan dibawa di dalam APK (±30 MB); disalin sekali ke folder model karena ONNX Runtime membaca berkas.
  Future<VisionPaths> _visionPaths() async {
    final dir = Directory('${models.dir.path}/penglihatan')..createSync(recursive: true);
    for (final name in visionAssets) {
      final f = File('${dir.path}/$name');
      final data = await rootBundle.load('assets/models/$name');
      if (!f.existsSync() || f.lengthSync() != data.lengthInBytes) {
        await f.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
      }
    }
    return VisionPaths(
      detector: '${dir.path}/meira-det.onnx',
      ocrDet: '${dir.path}/ppocrv5-det.onnx',
      ocrRec: '${dir.path}/ppocrv5-latin-rec.onnx',
      ocrKeys: '${dir.path}/ppocrv5-latin-keys.txt',
    );
  }

  static const visionAssets = [
    'meira-det.onnx', 'meira-det.labels.txt', 'meira-det.json', 'ppocrv5-det.onnx', 'ppocrv5-latin-rec.onnx', 'ppocrv5-latin-keys.txt',
  ];

  /// Foto untuk detektor (640 x 640, sama dengan saat pelatihan) dan untuk OCR (sisi terpanjang 960 piksel).
  static Future<VisionInput> visionInput(Uint8List bytes) async {
    Future<(Uint8List, int, int)> rgba(int? w, int? h) async {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: w, targetHeight: h);
      final img = (await codec.getNextFrame()).image;
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      return (data!.buffer.asUint8List(), img.width, img.height);
    }

    final probe = (await (await ui.instantiateImageCodec(bytes)).getNextFrame()).image;
    final scale = math.min(1.0, 960 / math.max(probe.width, probe.height));
    final (square, _, _) = await rgba(640, 640);
    final (full, w, h) = await rgba((probe.width * scale).round(), (probe.height * scale).round());
    return VisionInput(square: square, squareSize: 640, full: full, width: w, height: h);
  }

  int get _imageTokens => ((imageSide / 32) * (imageSide / 32)).round();

  Future<void> _warmup() async {
    try {
      await _brainServer?.client.chat([
        {'role': 'user', 'content': 'Jawab satu kata: siap?'},
      ], maxTokens: 3);
    } catch (_) {}
  }

  Future<void> shutdown() async {
    await _stopModels();
    speech?.unload();
  }

  Future<void> _stopModels() async {
    final servers = {_brainServer}.whereType<LlamaServer>();
    for (final s in servers) {
      await s.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!releaseInBackground) return;
    if (state == AppLifecycleState.paused) {
      // lepas model dari RAM bila aplikasi ditinggal lebih dari 3 menit
      _backgroundTimer = Timer(const Duration(minutes: 3), () async {
        await _stopModels();
        speech?.unload();
      });
    } else if (state == AppLifecycleState.resumed) {
      _backgroundTimer?.cancel();
      if (_brainServer != null && !_brainServer!.running) unawaited(_restart());
    }
  }

  Future<void> _restart() async {
    phase = Phase.booting;
    notifyListeners();
    await boot();
  }

  // =============================================================== foto
  /// Foto untuk model: diperkecil ke [imageSide] piksel; bila [flip], dicerminkan untuk mode deteksi teliti.
  Future<String> _modelImage(Uint8List bytes, {bool flip = false}) async {
    final probe = await ui.instantiateImageCodec(bytes);
    final f = await probe.getNextFrame();
    final w = f.image.width, h = f.image.height;
    final scale = imageSide / math.max(w, h);
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: scale < 1 ? (w * scale).round() : w, targetHeight: scale < 1 ? (h * scale).round() : h);
    var small = (await codec.getNextFrame()).image;
    if (flip) {
      final rec = ui.PictureRecorder();
      ui.Canvas(rec)
        ..translate(small.width.toDouble(), 0)
        ..scale(-1, 1)
        ..drawImage(small, ui.Offset.zero, ui.Paint());
      small = await rec.endRecording().toImage(small.width, small.height);
    }
    final png = await small.toByteData(format: ui.ImageByteFormat.png);
    return 'data:image/png;base64,${base64Encode(png!.buffer.asUint8List())}';
  }

  Future<Uint8List> _thumb(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 200);
    final img = (await codec.getNextFrame()).image;
    return (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> sendPhoto(Uint8List bytes, {String text = ''}) async {
    final probe = await (await ui.instantiateImageCodec(bytes)).getNextFrame();
    photo = bytes;
    photoSize = Size(probe.image.width.toDouble(), probe.image.height.toDouble());
    detections = [];
    partial = [];
    sceneMode = null;
    dish = null;
    session = _newSession();
    notifyListeners();
    final dataUrl = await _modelImage(bytes);
    _visionInput = await visionInput(bytes);
    unawaited(_thumb(bytes).then((t) => history.savePhoto(session!.id, bytes, t)));
    await send(text: text, imageDataUrl: dataUrl, photoBytes: bytes);
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  // riwayat untuk LLM lebih ringkas di HP supaya prompt cepat diproses CPU
  int get _memoryBudget => 700;

  Session _newSession() => Session(_newId(), memoryBudget: _memoryBudget);

  // =============================================================== percakapan
  /// Foto tambahan dalam percakapan yang sama: bahannya ikut dihitung, foto utama dan penandanya tetap.
  Future<void> addPhoto(Uint8List bytes) async {
    if (session == null || photo == null) return sendPhoto(bytes);
    final input = await visionInput(bytes);
    await send(photoBytes: bytes, turn: () => meira!.addPhoto(session!, input));
  }

  Future<void> send({String text = '', String? imageDataUrl, Uint8List? photoBytes, bool spoken = false, Stream<MeiraEvent> Function()? turn}) async {
    if (busy || meira == null) return;
    if (text.trim().isEmpty && imageDataUrl == null && turn == null) return;
    session ??= _newSession();
    busy = true;
    scanning = imageDataUrl != null;
    await stopSpeaking();
    messages.add(Message(Role.user, text.trim(), photo: photoBytes));
    Message? answer;
    Message? status;
    notifyListeners();
    try {
      final vin = imageDataUrl != null ? _visionInput : null;
      _visionInput = null;
      final events = turn?.call() ?? meira!.turn(session!, text: text, imageDataUrl: imageDataUrl, visionInput: vin, mode: photoMode);
      await for (final ev in events) {
        switch (ev) {
          case StatusEvent(:final text):
            status ??= (Message(Role.status, '')..let(messages.add));
            status.text = text;
          case PartialEvent(:final items):
            partial = items;
          case DetectionsEvent(:final items, :final seconds):
            scanning = false;
            partial = [];
            detections = List.of(items);
            if (seconds != null) detectSeconds = seconds;
          case SceneEvent(:final mode, dish: final d):
            sceneMode = mode;
            dish = d;
          case RecipesEvent():
            break;
          case TokenEvent(:final text):
            if (status != null) {
              messages.remove(status);
              status = null;
            }
            answer ??= (Message(Role.meira, '', streaming: true)..let(messages.add));
            answer.text += text;
          case DoneEvent(:final text, :final source):
            answer ??= (Message(Role.meira, '')..let(messages.add));
            answer
              ..text = text
              ..streaming = false
              ..source = source;
            if (speakAnswers || spoken) unawaited(speak(text));
          case ErrorEvent(:final text):
            messages.add(Message(Role.error, text));
        }
        notifyListeners();
      }
    } catch (e) {
      messages.add(Message(Role.error, 'Terjadi kendala: $e'));
    } finally {
      if (status != null) messages.remove(status);
      busy = false;
      scanning = false;
      notifyListeners();
      if (handsFree && voice == VoiceState.idle) unawaited(_listenHandsFree());
    }
  }

  /// Koreksi pengguna: ganti bahan pada penanda [number], atau hapus bila [key] null.
  Future<void> correctMarker(int number, String? key) async {
    final s = session;
    if (s == null) return;
    final i = s.detections.indexWhere((d) => d.number == number);
    if (i < 0) return;
    final old = s.detections[i];
    if (key == null) {
      s.detections.removeAt(i);
    } else {
      s.detections[i] = Detection(key: key, label: displayName(key), rawLabel: displayName(key), box: old.box, group: old.group);
    }
    await meira?.refresh(s);
    detections = List.of(s.detections);
    highlighted = {};
    notifyListeners();
  }

  /// Simpan foto ini beserta penandanya sebagai contoh latih. Dipanggil setelah pengguna memastikan
  /// setiap bahan sudah bertanda dan tidak ada penanda yang salah.
  Future<String?> saveToDataset() async {
    final s = session;
    if (s == null || photo == null || photoSize == null) return null;
    return CustomDataset.save(
      jpeg: photo!,
      width: photoSize!.width.round(),
      height: photoSize!.height.round(),
      objects: [for (final d in s.detections) if (d.key != null && !d.packaged) {'key': d.key, 'label': d.label, 'box': d.box, 'group': d.group}],
      absent: const [],
      author: '',
      license: 'CC BY 4.0',
    );
  }

  void selectRecipe(String id) {
    session?.current = id;
    notifyListeners();
  }

  void highlight(Iterable<int> ns) {
    highlighted = ns.toSet();
    notifyListeners();
  }

  void newConversation() {
    session = null;
    photo = null;
    photoSize = null;
    detections = [];
    partial = [];
    sceneMode = null;
    dish = null;
    messages.clear();
    notifyListeners();
  }

  Future<void> resume(String id) async {
    final row = await history.load(id);
    if (row == null) return;
    final (state, msgs) = row;
    final s = Session.restore(id, state, recipes, memoryBudget: _memoryBudget);
    final f = history.photoFile(id);
    if (f.existsSync()) {
      final bytes = await f.readAsBytes();
      final probe = await (await ui.instantiateImageCodec(bytes)).getNextFrame();
      photo = bytes;
      photoSize = Size(probe.image.width.toDouble(), probe.image.height.toDouble());
      s.imageDataUrl = await _modelImage(bytes);
    } else {
      photo = null;
      photoSize = null;
    }
    session = s;
    detections = List.of(s.detections);
    partial = [];
    sceneMode = s.mode;
    dish = s.dish;
    detectSeconds = null;
    messages
      ..clear()
      ..addAll([for (final m in msgs) Message(m.role == 'user' ? Role.user : Role.meira, m.text, source: m.meta['source'] as String?)]);
    notifyListeners();
  }

  // =============================================================== suara
  Future<void> speak(String text) async {
    final sp = speech;
    if (sp == null || !sp.canSpeak) return;
    try {
      voice = VoiceState.speaking;
      notifyListeners();
      await sp.speak(text);
    } catch (_) {
      // suara gagal tidak boleh menghentikan percakapan
    } finally {
      if (voice == VoiceState.speaking) voice = VoiceState.idle;
      notifyListeners();
      if (handsFree && !busy) unawaited(_listenHandsFree());
    }
  }

  Future<void> stopSpeaking() async {
    if (voice == VoiceState.speaking) {
      await speech?.stopSpeaking();
      voice = VoiceState.idle;
    }
  }

  /// Tekan untuk bicara, tekan lagi untuk kirim. Mengembalikan pesan galat bila ada.
  Future<String?> toggleMic() async {
    _stopVad();
    final sp = speech;
    if (sp == null || !sp.paths.hasAsr) return 'Model suara belum terpasang';
    if (voice == VoiceState.listening) return _finishListening();
    await stopSpeaking();
    if (!await sp.hasPermission()) return 'Izin mikrofon ditolak';
    await sp.startListening();
    voice = VoiceState.listening;
    notifyListeners();
    return null;
  }

  Future<String?> _finishListening() async {
    voice = VoiceState.transcribing;
    notifyListeners();
    try {
      final text = await speech!.stopAndTranscribe();
      voice = VoiceState.idle;
      notifyListeners();
      if (text == null || text.isEmpty) {
        if (handsFree) unawaited(_listenHandsFree());
        return text == null ? null : 'Suara kurang jelas';
      }
      await send(text: text, spoken: true);
      return null;
    } catch (e) {
      voice = VoiceState.idle;
      notifyListeners();
      return 'Suara tidak terbaca: $e';
    }
  }

  Future<void> setHandsFree(bool v) async {
    handsFree = v;
    if (v) {
      speakAnswers = true;
      unawaited(_listenHandsFree());
    } else {
      _stopVad();
      await speech?.cancelListening();
      voice = VoiceState.idle;
    }
    notifyListeners();
  }

  /// Mode percakapan suara: rekam terus, kirim otomatis setelah hening sekitar 1,2 detik.
  Future<void> _listenHandsFree() async {
    final sp = speech;
    if (!handsFree || busy || voice != VoiceState.idle || sp == null || !sp.paths.hasAsr) return;
    if (!await sp.hasPermission()) return;
    await sp.startListening();
    voice = VoiceState.listening;
    notifyListeners();
    var heard = false;
    var lastLoud = DateTime.now();
    final started = DateTime.now();
    _vadSub = sp.level.stream.listen((l) {
      if (l > .12) {
        heard = true;
        lastLoud = DateTime.now();
      }
    });
    _vad = Timer.periodic(const Duration(milliseconds: 150), (_) {
      final now = DateTime.now();
      if ((heard && now.difference(lastLoud).inMilliseconds > 1200) || now.difference(started).inSeconds > 15) {
        _stopVad();
        if (heard) {
          _finishListening();
        } else {
          sp.cancelListening().then((_) {
            voice = VoiceState.idle;
            notifyListeners();
            _listenHandsFree();
          });
        }
      }
    });
  }

  void _stopVad() {
    _vad?.cancel();
    _vad = null;
    _vadSub?.cancel();
    _vadSub = null;
  }

  // =============================================================== pengaturan
  Future<void> setPref(String key, Object value) async {
    final p = await SharedPreferences.getInstance();
    switch (key) {
      case 'speak':
        speakAnswers = value as bool;
        await p.setBool(key, speakAnswers);
      case 'release_bg':
        releaseInBackground = value as bool;
        await p.setBool(key, releaseInBackground);
      case 'image_side':
        imageSide = value as int;
        await p.setInt(key, imageSide);
      case 'photo_mode':
        photoMode = value as String;
        await p.setString(key, photoMode);
      case 'user_name':
        userName = (value as String).trim();
        meira?.userName = userName;
        await p.setString(key, userName!);
      case 'voice_name':
        voiceName = value as String;
        await speech?.setVoice(voiceName);
        await p.setString(key, voiceName!);
      case 'thorough':
        thorough = value as bool;
        meira?.thorough = thorough;
        await p.setBool(key, thorough);
      case 'read_packages':
        readPackages = value as bool;
        meira?.readPackages = readPackages;
        await p.setBool(key, readPackages);
      case 'answer_style':
        answerStyle = value as String;
        meira?.answerStyle = answerStyle;
        await p.setString(key, answerStyle);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stopVad();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(shutdown());
    super.dispose();
  }
}

extension Let<T> on T {
  T let(void Function(T) f) {
    f(this);
    return this;
  }
}

/// Dipakai layar Studio: simpan contoh dataset buatan sendiri di perangkat.
class CustomDataset {
  static Future<Directory> dir() async {
    final d = Directory('${(await Device.dataDir()).path}/meira-custom');
    await Directory('${d.path}/images').create(recursive: true);
    return d;
  }

  static Future<String> save({required Uint8List jpeg, required int width, required int height, required List<Map<String, dynamic>> objects, required List<String> absent, required String author, required String license}) async {
    final d = await dir();
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    await File('${d.path}/images/$id.jpg').writeAsBytes(jpeg);
    final rec = {
      'id': id, 'file': 'images/$id.jpg', 'width': width, 'height': height, 'split': 'train', 'source': 'meira-studio',
      'objects': objects, 'verified_present': {for (final o in objects) if (o['key'] != null) o['key']}.toList(),
      'verified_absent': absent, 'license': license, 'author': author, 'author_url': '', 'source_url': '', 'title': '',
    };
    await File('${d.path}/annotations.jsonl').writeAsString('${jsonEncode(rec)}\n', mode: FileMode.append);
    return id;
  }

  static Future<List<Map<String, dynamic>>> items() async {
    final f = File('${(await dir()).path}/annotations.jsonl');
    if (!f.existsSync()) return [];
    return [for (final l in await f.readAsLines()) if (l.trim().isNotEmpty) jsonDecode(l) as Map<String, dynamic>].reversed.toList();
  }

  static Future<void> delete(String id) async {
    final d = await dir();
    final f = File('${d.path}/annotations.jsonl');
    if (f.existsSync()) {
      final keep = [for (final l in await f.readAsLines()) if (l.trim().isNotEmpty && (jsonDecode(l) as Map)['id'] != id) l];
      await f.writeAsString(keep.isEmpty ? '' : '${keep.join('\n')}\n');
    }
    final img = File('${d.path}/images/$id.jpg');
    if (img.existsSync()) await img.delete();
  }
}
