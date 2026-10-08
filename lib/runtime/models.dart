/// Daftar model lokal, pengunduhan sekali jalan (bisa dilanjutkan), dan impor dari file.
library;

import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;

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

/// Whisper small dipilih karena lolos gerbang WER (0,17 vs 0,21 untuk base) pada perintah dapur.
const earsPack = ModelPack('telinga', 'Telinga', 'Whisper small (int8), mengubah suara menjadi teks', [
  ModelFile('whisper-small-encoder.int8.onnx', '$_hf/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-encoder.int8.onnx', 112),
  ModelFile('whisper-small-decoder.int8.onnx', '$_hf/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-decoder.int8.onnx', 262),
  ModelFile('whisper-small-tokens.txt', '$_hf/csukuangfj/sherpa-onnx-whisper-small/resolve/main/small-tokens.txt', 1),
]);

const allPacks = [brainPack, earsPack];

/// Yang diunduh saat penyiapan. Detektor bahan dan OCR sudah ada di dalam APK, dan suara memakai mesin TTS ponsel.
List<ModelPack> setupPacks() => [brainPack, earsPack];

class Models {
  Models._(this.dir);
  final Directory dir;

  static Future<Models> open() async => Models._(await Device.modelsDir());

  String path(String name) => '${dir.path}/$name';

  bool installed(ModelPack p) => p.files.every((f) => f.archive ? Directory(path(f.name)).existsSync() : File(path(f.name)).existsSync());

  List<ModelPack> missingRequired() => [for (final p in allPacks) if (p.required && !installed(p)) p];

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
      await _fetch(f.url, target, (d) => onProgress(base + d, total));
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
