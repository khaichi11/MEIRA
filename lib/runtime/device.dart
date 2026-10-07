/// Informasi perangkat: lokasi biner native, folder model, RAM, dan jumlah thread.
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Device {
  static const _channel = MethodChannel('meira/native');
  static String? _nativeDir;
  static String? _home;

  static bool get isAndroid => Platform.isAndroid;

  /// Inti besar saja yang dipakai (HP biasanya 4 inti besar + 4 inti hemat daya).
  static int get inferenceThreads => isAndroid ? math.min(4, math.max(2, Platform.numberOfProcessors ~/ 2)) : math.max(2, Platform.numberOfProcessors ~/ 2);

  static Future<String> llamaServerPath() async {
    if (isAndroid) {
      _nativeDir ??= await _channel.invokeMethod<String>('nativeLibraryDir');
      return '$_nativeDir/libllama_server.so';
    }
    final home = await meiraHome();
    final found = Directory('$home/external/llama.cpp')
        .listSync(recursive: true)
        .whereType<File>()
        .firstWhere((f) => f.path.endsWith('/llama-server'), orElse: () => throw StateError('llama-server tidak ditemukan di $home/external/llama.cpp'));
    return found.path;
  }

  /// Folder proyek MEIRA di desktop (berisi external/llama.cpp).
  static Future<String> meiraHome() async {
    if (_home != null) return _home!;
    final env = Platform.environment['MEIRA_HOME'];
    final candidates = [?env, Directory.current.path, Directory.current.parent.path, '${Platform.environment['HOME']}/MEIRA'];
    var dir = File(Platform.resolvedExecutable).parent;
    for (var i = 0; i < 8; i++) {
      candidates.add(dir.path);
      dir = dir.parent;
    }
    for (final c in candidates) {
      if (Directory('$c/external/llama.cpp').existsSync()) return _home = c;
    }
    return _home = '${Platform.environment['HOME']}/MEIRA';
  }

  /// Folder model di perangkat. Android: penyimpanan aplikasi (bisa diisi lewat USB di Android/data/...).
  static Future<Directory> modelsDir() async {
    Directory base;
    if (isAndroid) {
      base = (await getExternalStorageDirectory()) ?? await getApplicationSupportDirectory();
    } else {
      base = Directory('${await meiraHome()}/models');
    }
    final d = Directory('${base.path}/${isAndroid ? 'models' : 'app'}');
    await d.create(recursive: true);
    return d;
  }

  static Future<Directory> dataDir() async {
    final d = Directory('${(await getApplicationSupportDirectory()).path}/meira');
    await d.create(recursive: true);
    return d;
  }

  /// RAM total dalam GB (dari /proc/meminfo; berlaku di Android dan Linux).
  static double totalRamGb() {
    try {
      final line = File('/proc/meminfo').readAsLinesSync().firstWhere((l) => l.startsWith('MemTotal'));
      return int.parse(RegExp(r'\d+').firstMatch(line)!.group(0)!) / 1024 / 1024;
    } catch (_) {
      return 4;
    }
  }
}
