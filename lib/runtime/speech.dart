/// Suara on-device: Whisper (sherpa-onnx) untuk mendengar, mesin TTS bawaan ponsel untuk berbicara.
///
/// Whisper berjalan di isolate tersendiri supaya UI tetap lancar, dimuat saat pertama dipakai,
/// dan dilepas dari RAM setelah [idleTimeout] tanpa aktivitas. Suara bawaan ponsel tidak ikut dibagikan
/// bersama aplikasi, sehingga tidak ada lisensi suara pihak ketiga yang perlu dipenuhi.
library;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

import 'models.dart';

class SpeechPaths {
  SpeechPaths({required this.encoder, required this.decoder, required this.tokens});
  final String encoder, decoder, tokens;

  static SpeechPaths of(Models m) => SpeechPaths(
    encoder: m.path('whisper-small-encoder.int8.onnx'),
    decoder: m.path('whisper-small-decoder.int8.onnx'),
    tokens: m.path('whisper-small-tokens.txt'),
  );

  bool get hasAsr => File(encoder).existsSync() && File(decoder).existsSync();
}

class Speech {
  Speech(this.paths, {this.idleTimeout = const Duration(minutes: 2), this.threads = 2});

  final FlutterTts _systemTts = FlutterTts();
  bool _systemReady = false;
  String? voiceName; // pilihan pengguna; kosong = dipilih otomatis

  /// Suara bahasa Indonesia yang terpasang di mesin TTS sistem, terbaik lebih dulu
  /// (bisa offline, kualitas tertinggi, suara neural).
  Future<List<Map<String, String>>> indonesianVoices() async {
    final raw = (await _systemTts.getVoices as List?) ?? const [];
    const quality = {'very high': 4, 'high': 3, 'normal': 2, 'low': 1, 'very low': 0};
    int score(Map v) {
      final offline = !{'1', 'true'}.contains('${v['network_required']}'.toLowerCase());
      final name = '${v['name']}'.toLowerCase();
      return (offline ? 10 : 0) + (quality['${v['quality']}'.toLowerCase()] ?? 2) + (name.contains('local') ? 1 : 0);
    }

    final ids = [
      for (final v in raw)
        if (v is Map && RegExp(r'^(id|in)([-_]|$)', caseSensitive: false).hasMatch('${v['locale']}')) v,
    ]..sort((a, b) => score(b).compareTo(score(a)));
    return [
      for (final v in ids)
        {
          'name': '${v['name']}',
          'locale': '${v['locale']}',
          'offline': '${!{'1', 'true'}.contains('${v['network_required']}'.toLowerCase())}',
        },
    ];
  }

  Future<void> _prepareSystemVoice() async {
    await _systemTts.setLanguage('id-ID');
    await _systemTts.awaitSpeakCompletion(true);
    await _systemTts.setPitch(1.0);
    final voices = await indonesianVoices();
    final chosen = voices.where((v) => v['name'] == voiceName).firstOrNull ?? voices.firstOrNull;
    if (chosen != null) await _systemTts.setVoice({'name': chosen['name']!, 'locale': chosen['locale']!});
    _systemReady = true;
  }

  Future<void> setVoice(String? name) async {
    voiceName = name;
    _systemReady = false;
  }

  bool get canSpeak => true;

  final SpeechPaths paths;
  final Duration idleTimeout;
  final int threads;
  SendPort? _worker;
  Isolate? _isolate;
  Timer? _idle;
  int _seq = 0;
  final _pending = <int, Completer<dynamic>>{};

  final AudioRecorder _rec = AudioRecorder();
  final _pcm = BytesBuilder(copy: false);
  StreamSubscription<Uint8List>? _micSub;

  /// Level suara 0..1 untuk animasi tombol dan deteksi jeda.
  final StreamController<double> level = StreamController.broadcast();
  bool get recording => _micSub != null;

  // ------------------------------------------------------------ isolate
  Future<SendPort> _ensure() async {
    _idle?.cancel();
    _idle = Timer(idleTimeout, unload);
    if (_worker != null) return _worker!;
    final ready = ReceivePort();
    final replies = ReceivePort();
    _isolate = await Isolate.spawn(_workerMain, [ready.sendPort, replies.sendPort, paths.encoder, paths.decoder, paths.tokens, threads]);
    _worker = await ready.first as SendPort;
    replies.listen((msg) {
      final (id, result) = msg as (int, dynamic);
      _pending.remove(id)?.complete(result);
    });
    return _worker!;
  }

  Future<T> _call<T>(String op, Object? arg) async {
    final w = await _ensure();
    final id = ++_seq;
    final c = Completer<dynamic>();
    _pending[id] = c;
    w.send((id, op, arg));
    final r = await c.future;
    if (r is String && r.startsWith('ERROR:')) throw StateError(r.substring(6));
    return r as T;
  }

  /// Lepaskan Whisper dari memori.
  void unload() {
    _idle?.cancel();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _worker = null;
  }

  // ------------------------------------------------------------ mendengar
  Future<bool> hasPermission() => _rec.hasPermission();

  Future<void> startListening() async {
    _pcm.clear();
    final stream = await _rec.startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: 16000, numChannels: 1));
    unawaited(_ensure()); // muat Whisper sambil pengguna bicara
    _micSub = stream.listen((chunk) {
      _pcm.add(chunk);
      level.add(_rms(chunk));
    });
  }

  /// Hentikan rekaman lalu tulis ucapan menjadi teks (null bila terlalu pendek).
  Future<String?> stopAndTranscribe() async {
    await _rec.stop();
    await _micSub?.cancel();
    _micSub = null;
    level.add(0);
    final bytes = _pcm.takeBytes();
    if (bytes.length < 16000) return null; // < 0,5 detik
    final pcm = Int16List.view(bytes.buffer, bytes.offsetInBytes, bytes.length ~/ 2);
    final samples = Float32List(pcm.length);
    for (var i = 0; i < pcm.length; i++) {
      samples[i] = pcm[i] / 32768.0;
    }
    final text = await _call<String>('asr', samples);
    return text.trim();
  }

  Future<void> cancelListening() async {
    if (!recording) return;
    await _rec.stop();
    await _micSub?.cancel();
    _micSub = null;
    _pcm.clear();
    level.add(0);
  }

  static double _rms(Uint8List chunk) {
    final s = Int16List.view(chunk.buffer, chunk.offsetInBytes, chunk.length ~/ 2);
    if (s.isEmpty) return 0;
    var sum = 0.0;
    for (final v in s) {
      sum += v * v;
    }
    final rms = math.sqrt(sum / s.length) / 32768.0;
    return (rms * 6).clamp(0.0, 1.0);
  }

  // ------------------------------------------------------------ berbicara
  Future<void> speak(String text, {double speed = 1.0}) async {
    final clean = speakable(text);
    if (clean.isEmpty) return;
    if (!_systemReady) await _prepareSystemVoice();
    await _systemTts.setSpeechRate(.48 * speed); // sedikit di bawah normal agar jelas saat memasak
    await _systemTts.speak(clean);
  }

  Future<void> stopSpeaking() => _systemTts.stop();

  Future<void> dispose() async {
    unload();
    await _micSub?.cancel();
    await _rec.dispose();
    await level.close();
  }
}

/// Rapikan teks agar enak dibacakan: nomor penanda, satuan resep, dan tanda baca.
String speakable(String text) {
  var t = text.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '');
  t = t.replaceAll(RegExp(r'[*_`>#]+(?=\s|$)'), '');
  t = t.replaceAllMapped(RegExp(r'\(#(\d+)(?:\s*,\s*#\d+)*\)'), (m) => 'nomor ${m.group(1)}');
  t = t.replaceAllMapped(RegExp(r'#(\d+)'), (m) => 'nomor ${m.group(1)}');
  t = t.replaceAllMapped(RegExp(r'^\s*(\d+)\.\s+', multiLine: true), (m) => 'Langkah ${m.group(1)}. ');
  const fractions = {'1/2': 'setengah', '1/4': 'seperempat', '3/4': 'tiga perempat', '1/3': 'sepertiga'};
  fractions.forEach((f, w) => t = t.replaceAll(RegExp('(?<![\\d/])${RegExp.escape(f)}(?![\\d/])'), w));
  const units = {
    r'\bsdm\b': 'sendok makan',
    r'\bsdt\b': 'sendok teh',
    r'\bml\b': 'mililiter',
    r'\bkg\b': 'kilogram',
    r'\bdtk\b': 'detik',
    r'\bmnt\b': 'menit',
    r'\bmis\.': 'misalnya',
    r'\bdll\b\.?': 'dan lain-lain',
    r'°\s*C\b': ' derajat Celsius',
  };
  units.forEach((p, r) => t = t.replaceAll(RegExp(p), r));
  t = t.replaceAllMapped(RegExp(r'(\d)\s*g\b'), (m) => '${m.group(1)} gram');
  t = t.replaceAllMapped(RegExp(r'(\d+)/(\d+)'), (m) => '${m.group(1)} per ${m.group(2)}');
  t = t.replaceAllMapped(RegExp(r'(\d+)\s*-\s*(\d+)'), (m) => '${m.group(1)} sampai ${m.group(2)}');
  t = t.replaceAll('—', ', ').replaceAll('–', ', ');
  t = t.replaceAll(RegExp(r'\s*\n+\s*'), '. ').replaceAll(RegExp(r'\.\s*\.'), '.');
  return t.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

// ---------------------------------------------------------------- isolate kerja
void _workerMain(List<dynamic> args) {
  final ready = args[0] as SendPort, replies = args[1] as SendPort;
  final encoder = args[2] as String, decoder = args[3] as String, tokens = args[4] as String;
  final threads = args[5] as int;
  so.initBindings();
  so.OfflineRecognizer? asr;
  final inbox = ReceivePort();
  ready.send(inbox.sendPort);
  inbox.listen((msg) {
    final (id, op, arg) = msg as (int, String, Object?);
    try {
      if (op == 'asr') {
        asr ??= so.OfflineRecognizer(
          so.OfflineRecognizerConfig(
            model: so.OfflineModelConfig(
              whisper: so.OfflineWhisperModelConfig(encoder: encoder, decoder: decoder, language: 'id', task: 'transcribe'),
              tokens: tokens,
              numThreads: threads,
              debug: false,
            ),
          ),
        );
        final stream = asr!.createStream();
        stream.acceptWaveform(samples: arg as Float32List, sampleRate: 16000);
        asr!.decode(stream);
        final text = asr!.getResult(stream).text;
        stream.free();
        replies.send((id, text));
      }
    } catch (e) {
      replies.send((id, 'ERROR:$e'));
    }
  });
}
