/// Informasi perangkat Android: lokasi biner native, folder model dan data, RAM, dan jumlah thread.
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Device {
  static const _channel = MethodChannel('meira/native');
  static String? _nativeDir;

  /// Inti besar saja yang dipakai (HP umumnya 4 inti besar + 4 inti hemat daya).
  static int get inferenceThreads => math.min(4, math.max(2, Platform.numberOfProcessors ~/ 2));

  /// llama-server dikemas sebagai libllama_server.so agar diekstrak ke folder library native yang boleh dieksekusi.
  static Future<String> llamaServerPath() async {
    _nativeDir ??= await _channel.invokeMethod<String>('nativeLibraryDir');
    return '$_nativeDir/libllama_server.so';
  }

  /// Folder model: penyimpanan aplikasi yang bisa diisi lewat USB (Android/data/id.meira.meira/files/models).
  static Future<Directory> modelsDir() async {
    final base = (await getExternalStorageDirectory()) ?? await getApplicationSupportDirectory();
    final d = Directory('${base.path}/models');
    await d.create(recursive: true);
    return d;
  }

  static Future<Directory> dataDir() async {
    final d = Directory('${(await getApplicationSupportDirectory()).path}/meira');
    await d.create(recursive: true);
    return d;
  }

  /// RAM total dalam GB, dibaca dari /proc/meminfo.
  static double totalRamGb() {
    try {
      final line = File('/proc/meminfo').readAsLinesSync().firstWhere((l) => l.startsWith('MemTotal'));
      return int.parse(RegExp(r'\d+').firstMatch(line)!.group(0)!) / 1024 / 1024;
    } catch (_) {
      return 4;
    }
  }
}
