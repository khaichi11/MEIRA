/// Daftar model lokal, pengunduhan sekali jalan (bisa dilanjutkan), dan impor dari file.
library;

import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'device.dart';

class ModelFile {
  const ModelFile(this.name, this.url, this.approxMb, {this.archive = false});
  final String name; // nama file atau folder hasil ekstraksi
  final String url;
  final int approxMb;
  final bool archive; // .tar.bz2 yang diekstrak ke folder [name]
}

class ModelPack {
  const ModelPack(this.id, this.title, this.subtitle, this.files, {this.required = true});
  final String id;
  final String title;
  final String subtitle;
  final List<ModelFile> files;
  final bool required;

  int get approxMb => files.fold(0, (a, f) => a + f.approxMb);
}

const _hf = 'https://huggingface.co';

/// Model "otak" (instruct) juga dipakai sebagai "mata" selama model fine-tune belum dipasang.
const brainPack = ModelPack('otak', 'Otak', 'Qwen3.5-0.8B instruct, mengenali hidangan dan menyusun jawaban', [
  ModelFile('qwen3.5-0.8b-instruct-Q4_K_M.gguf', '$_hf/unsloth/Qwen3.5-0.8B-GGUF/resolve/main/Qwen3.5-0.8B-Q4_K_M.gguf', 532),
  ModelFile('qwen3.5-0.8b-instruct-mmproj-F16.gguf', '$_hf/unsloth/Qwen3.5-0.8B-GGUF/resolve/main/mmproj-F16.gguf', 204),
]);

/// Hasil fine-tune MEIRA (Qwen3.5-0.8B-Base + LoRA, digabung). URL bisa diganti di Pengaturan.
const eyesPack = ModelPack('mata', 'Mata', 'Qwen3.5-0.8B-Base hasil fine-tune MEIRA, menandai bahan', [
  ModelFile('meira-eyes-0.8b-Q4_K_M.gguf', '$_hf/khaichi11/MEIRA-eyes/resolve/main/meira-eyes-0.8b-Q4_K_M.gguf', 532),
  ModelFile('meira-eyes-0.8b-mmproj-F16.gguf', '$_hf/khaichi11/MEIRA-eyes/resolve/main/meira-eyes-0.8b-mmproj-F16.gguf', 204),
], required: false);

/// Versi 2B: lebih teliti pada foto ramai, tetapi hampir tiga kali lebih lama (lihat docs/evaluasi.md di MEIRA-Before).
const eyesAccuratePack = ModelPack('mata-akurat', 'Mata akurat', 'Qwen3.5-2B-Base hasil fine-tune MEIRA, lebih teliti tetapi lebih lambat', [
  ModelFile('meira-eyes-2b-Q4_K_M.gguf', '$_hf/khaichi11/MEIRA-eyes/resolve/main/meira-eyes-2b-Q4_K_M.gguf', 1216),
  ModelFile('meira-eyes-2b-mmproj-F16.gguf', '$_hf/khaichi11/MEIRA-eyes/resolve/main/meira-eyes-2b-mmproj-F16.gguf', 638),
], required: false);

/// Whisper small dipilih karena lolos gerbang WER (0,17 vs 0,21 untuk base) pada perintah dapur.
const earsPack = ModelPack('telinga', 'Telinga', 'Whisper small (int8), mengubah suara menjadi teks', [
  ModelFile('whisper-small-encoder.int8.onnx', '$_hf/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-encoder.int8.onnx', 112),
  ModelFile('whisper-small-decoder.int8.onnx', '$_hf/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-decoder.int8.onnx', 262),
  ModelFile('whisper-small-tokens.txt', '$_hf/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-tokens.txt', 1),
]);

/// Opsional: suara bawaan memakai mesin TTS sistem. Bobot Piper dirilis di repo rhasspy/piper-voices (MIT),
/// tetapi lisensi data latih suaranya tidak dicantumkan jelas oleh pembuatnya.
const voicePack = ModelPack('suara', 'Suara Piper', 'Opsional. Lisensi data latih suara ini tidak dicantumkan jelas oleh pembuatnya', [
  ModelFile('vits-piper-id_ID-news_tts-medium-int8',
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-id_ID-news_tts-medium-int8.tar.bz2', 21,
      archive: true),
], required: false);

const allPacks = [brainPack, eyesPack, eyesAccuratePack, earsPack, voicePack];

/// Yang diunduh saat penyiapan: satu model mata yang sesuai RAM ponsel. Suara Piper dan model mata lainnya
/// dapat dipasang dari Pengaturan.
List<ModelPack> setupPacks(double ramGb) => [brainPack, ramGb >= 7.5 ? eyesAccuratePack : eyesPack, earsPack];

class Models {
  Models._(this.dir);
  final Directory dir;

  static Future<Models> open() async => Models._(await Device.modelsDir());

  String path(String name) => '${dir.path}/$name';

  bool installed(ModelPack p) => p.files.every((f) => f.archive ? Directory(path(f.name)).existsSync() : File(path(f.name)).existsSync());

  List<ModelPack> missingRequired() => [for (final p in allPacks) if (p.required && !installed(p)) p];

  Future<String> urlFor(ModelPack p, ModelFile f) async {
    if (!p.id.startsWith('mata')) return f.url;
    final base = (await SharedPreferences.getInstance()).getString('eyes_base_url');
    return base == null || base.isEmpty ? f.url : '${base.replaceAll(RegExp(r'/+$'), '')}/${f.name}';
  }

  /// Unduh satu paket. [onProgress] menerima (byte selesai, perkiraan total byte).
  Future<void> download(ModelPack p, void Function(int done, int total) onProgress) async {
    final total = p.approxMb * 1024 * 1024;
    var base = 0;
    for (final f in p.files) {
      final target = f.archive ? '${path(f.name)}.tar.bz2' : path(f.name);
      if (!f.archive && File(target).existsSync()) {
        base += f.approxMb * 1024 * 1024;
        continue;
      }
      if (f.archive && Directory(path(f.name)).existsSync()) {
        base += f.approxMb * 1024 * 1024;
        continue;
      }
      await _fetch(await urlFor(p, f), target, (d) => onProgress(base + d, total));
      if (f.archive) await _extract(target, dir.path);
      base += f.approxMb * 1024 * 1024;
    }
    onProgress(total, total);
  }

  Future<void> _fetch(String url, String target, void Function(int) onBytes) async {
    final part = File('$target.part');
    final have = part.existsSync() ? part.lengthSync() : 0;
    final req = http.Request('GET', Uri.parse(url));
    if (have > 0) req.headers['Range'] = 'bytes=$have-';
    final res = await http.Client().send(req);
    if (res.statusCode != 200 && res.statusCode != 206) throw HttpException('unduhan gagal (${res.statusCode}): $url');
    final resume = res.statusCode == 206;
    final sink = part.openWrite(mode: resume ? FileMode.append : FileMode.write);
    var done = resume ? have : 0;
    await for (final chunk in res.stream) {
      sink.add(chunk);
      done += chunk.length;
      onBytes(done);
    }
    await sink.close();
    await part.rename(target);
  }

  Future<void> _extract(String archivePath, String outDir) async {
    final bytes = BZip2Decoder().decodeBytes(await File(archivePath).readAsBytes());
    final tar = TarDecoder().decodeBytes(bytes);
    for (final f in tar.files) {
      final out = '$outDir/${f.name}';
      if (f.isFile) {
        await File(out).create(recursive: true);
        await File(out).writeAsBytes(f.content as List<int>);
      } else {
        await Directory(out).create(recursive: true);
      }
    }
    await File(archivePath).delete();
  }

  /// Salin file model yang dipilih pengguna (mis. hasil export dari laptop) ke folder model.
  Future<List<String>> import(List<String> paths) async {
    final known = {for (final p in allPacks) for (final f in p.files) f.name};
    final copied = <String>[];
    for (final src in paths) {
      final name = src.split(Platform.pathSeparator).last;
      if (!known.contains(name)) continue;
      await File(src).copy(path(name));
      copied.add(name);
    }
    return copied;
  }

  Future<void> remove(ModelPack p) async {
    for (final f in p.files) {
      final e = f.archive ? Directory(path(f.name)) : File(path(f.name));
      if (e.existsSync()) await e.delete(recursive: true);
    }
  }

  int usedBytes() {
    var total = 0;
    for (final e in dir.listSync(recursive: true)) {
      if (e is File) total += e.lengthSync();
    }
    return total;
  }
}
