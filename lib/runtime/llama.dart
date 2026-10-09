/// llama-server lokal: dijalankan sebagai proses di perangkat ini, diakses lewat 127.0.0.1.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'device.dart';

/// Sampling yang disarankan Qwen3.5 untuk mode non-thinking.
const visionSampling = {'temperature': .7, 'top_p': .8, 'top_k': 20, 'presence_penalty': 1.5, 'seed': 7};
const textSampling = {'temperature': .7, 'top_p': .8, 'top_k': 20, 'presence_penalty': 1.0};

/// Obrolan singkat: lebih tenang dan tidak melantur, karena model 0,8B mudah mengarang bila suhunya tinggi.
const chatSampling = {'temperature': .3, 'top_p': .8, 'top_k': 20, 'presence_penalty': .5};
const greedy = {'temperature': 0.0, 'top_k': 1};

/// Model mata hasil fine-tune: greedy, sama dengan GROUNDING di meira/prompts.py.
const groundingSampling = {'temperature': 0.0, 'top_k': 1, 'seed': 7};

class LlamaServer {
  LlamaServer({required this.name, required this.model, this.mmproj, this.lora, required this.port, this.binary, this.gpuLayers = 0});

  final String name;
  final String model;
  final String? mmproj;
  final String? lora;
  final int port;
  final String? binary; // diisi saat uji di laptop; di HP diambil dari folder library native
  final int gpuLayers; // HP: 0 (CPU)
  Process? _proc;
  final List<String> log = [];

  late final LlmClient client = LlmClient('http://127.0.0.1:$port');
  bool get running => _proc != null;

  Future<void> start({int maxImageTokens = 256, int ctx = 4096}) async {
    if (_proc != null) return;
    final bin = binary ?? await Device.llamaServerPath();
    final args = [
      '-m',
      model,
      '--host',
      '127.0.0.1',
      '--port',
      '$port',
      '-c',
      '$ctx',
      '-t',
      '${Device.inferenceThreads}',
      '-ngl',
      '$gpuLayers',
      '--jinja',
      '--no-webui',
      '-a',
      'meira',
      '--parallel',
      '1',
      if (mmproj != null) ...['--mmproj', mmproj!, '--image-max-tokens', '$maxImageTokens'],
      if (lora != null) ...['--lora', lora!],
    ];
    _proc = await Process.start(bin, args, environment: {'LD_LIBRARY_PATH': File(bin).parent.path});
    _proc!.stdout.transform(utf8.decoder).listen(_keep);
    _proc!.stderr.transform(utf8.decoder).listen(_keep);
    final exited = _proc!.exitCode.then((c) {
      _proc = null;
      return c;
    });
    final deadline = DateTime.now().add(const Duration(seconds: 90));
    while (DateTime.now().isBefore(deadline)) {
      final code = await Future.any([exited, Future.delayed(const Duration(milliseconds: 300), () => null)]);
      if (code != null) throw StateError('$name berhenti (kode $code): ${log.reversed.take(3).join(' | ')}');
      if (await client.healthy()) return;
    }
    throw TimeoutError('$name tidak siap');
  }

  void _keep(String s) {
    for (final l in const LineSplitter().convert(s)) {
      log.add(l);
      if (log.length > 120) log.removeAt(0);
    }
  }

  Future<void> stop() async {
    _proc?.kill();
    await _proc?.exitCode.timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        _proc?.kill(ProcessSignal.sigkill);
        return -1;
      },
    );
    _proc = null;
  }
}

class TimeoutError implements Exception {
  TimeoutError(this.message);
  final String message;
  @override
  String toString() => message;
}

class LlmClient {
  LlmClient(this.baseUrl);
  final String baseUrl;
  final http.Client _http = http.Client();

  Map<String, dynamic> _payload(
    List<Map<String, dynamic>> messages,
    int maxTokens,
    Map<String, dynamic> sampling, {
    bool stream = false,
    Map<String, dynamic>? extra,
  }) => {
    'model': 'meira',
    'messages': messages,
    'max_tokens': maxTokens,
    'stream': stream,
    'chat_template_kwargs': {'enable_thinking': false},
    // pakai ulang KV cache untuk awalan prompt yang sama (prompt sistem + riwayat): jawaban berikutnya lebih cepat
    'cache_prompt': true,
    ...sampling,
    ...?extra,
  };

  Future<bool> healthy() async {
    try {
      final r = await _http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 2));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> chat(
    List<Map<String, dynamic>> messages, {
    int maxTokens = 512,
    Map<String, dynamic> sampling = textSampling,
    Map<String, dynamic>? extra,
  }) async {
    final r = await _http.post(
      Uri.parse('$baseUrl/v1/chat/completions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_payload(messages, maxTokens, sampling, extra: extra)),
    );
    if (r.statusCode != 200) throw HttpException('LLM ${r.statusCode}: ${r.body}');
    return (jsonDecode(utf8.decode(r.bodyBytes))['choices'][0]['message']['content'] as String?) ?? '';
  }

  /// Aliran token. Dipakai juga untuk deteksi: penanda tampil per baris selagi model menulis.
  /// [onFinish] menerima alasan berhenti ("stop" atau "length") untuk keperluan lanjut otomatis.
  Stream<String> stream(
    List<Map<String, dynamic>> messages, {
    int maxTokens = 512,
    Map<String, dynamic> sampling = textSampling,
    void Function(String reason)? onFinish,
  }) async* {
    final req = http.Request('POST', Uri.parse('$baseUrl/v1/chat/completions'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(_payload(messages, maxTokens, sampling, stream: true));
    final res = await _http.send(req);
    if (res.statusCode != 200) throw HttpException('LLM ${res.statusCode}');
    await for (final line in res.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final data = line.substring(5).trim();
      if (data == '[DONE]') break;
      try {
        final choice = jsonDecode(data)['choices'][0];
        final delta = choice['delta']['content'];
        if (delta is String && delta.isNotEmpty) yield delta;
        final reason = choice['finish_reason'];
        if (reason is String) onFinish?.call(reason);
      } catch (_) {}
    }
  }

  /// Jumlah token sebuah teks menurut tokenizer model (untuk anggaran konteks).
  Future<int> countTokens(String text) async {
    try {
      final r = await _http.post(Uri.parse('$baseUrl/tokenize'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'content': text}));
      return (jsonDecode(r.body)['tokens'] as List).length;
    } catch (_) {
      return (text.length / 3.2).ceil(); // perkiraan kasar untuk bahasa Indonesia
    }
  }

  static List<Map<String, dynamic>> visionMessages(String imageDataUrl, String prompt) => [
    {
      'role': 'user',
      'content': [
        {
          'type': 'image_url',
          'image_url': {'url': imageDataUrl},
        },
        {'type': 'text', 'text': prompt},
      ],
    },
  ];

  Future<Map<String, dynamic>?> json(List<Map<String, dynamic>> messages, String schemaJson, {int maxTokens = 200}) async {
    try {
      final text = await chat(
        messages,
        maxTokens: maxTokens,
        sampling: greedy,
        extra: {
          'response_format': {
            'type': 'json_schema',
            'json_schema': {'name': 'out', 'schema': jsonDecode(schemaJson)},
          },
        },
      );
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
