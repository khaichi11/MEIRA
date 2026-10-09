// ignore_for_file: avoid_print
// Rekam layar aplikasi sebagai bingkai PNG untuk GIF demo dan gambar dokumentasi, tanpa emulator: layar digambar di
// laptop dengan data contoh (jawaban model ditulis langsung). Jalankan:
//   MEIRA_FRAMES=build/frames flutter test test/demo_render_test.dart
// lalu: python3 tool/render_gif.py build/frames docs/img/demo.gif
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meira/app_state.dart';
import 'package:meira/core/body.dart';
import 'package:meira/core/history.dart';
import 'package:meira/core/fasting.dart';
import 'package:meira/core/intake.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/llm/knowledge.dart';
import 'package:meira/runtime/models.dart';
import 'package:meira/theme.dart';
import 'package:meira/ui/chat.dart';
import 'package:meira/ui/health.dart';
import 'package:meira/ui/home.dart';
import 'package:meira/ui/intro.dart';
import 'package:meira/ui/recipe_book.dart';
import 'package:meira/ui/tour.dart';
import 'package:meira/ui/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> _fonts() async {
  for (final (family, files) in [
    ('Poppins', ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold'].map((w) => 'assets/fonts/Poppins-$w.ttf')),
    ('Inter', ['assets/fonts/Inter.ttf']),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
    }
    await loader.load();
  }
  final root = Platform.environment['FLUTTER_ROOT'] ?? '${Platform.environment['HOME']}/flutter';
  final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

void main() {
  final out = Platform.environment['MEIRA_FRAMES'];
  testWidgets('bingkai demo', (tester) async {
    SharedPreferences.setMockInitialValues({'tour_done': true});
    final tmp = Directory.systemTemp.createTempSync('meira_demo');
    // folder aplikasi palsu untuk tab Riwayat dan Dataset
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => tmp.path,
    );
    sqfliteFfiInit();
    final history = await tester.runAsync(() => History.open(at: tmp, factory: databaseFactoryFfi));
    final models = Models.at(tmp);
    await tester.runAsync(_fonts);
    final kb = KnowledgeBase.parse(
      File('assets/pengetahuan.md').readAsStringSync(),
      facts: File('assets/pengetahuan_luas.jsonl').readAsStringSync(),
    );
    final s = AppState()
      ..recipes = parseRecipes(File('assets/resep.md').readAsStringSync())
      ..knowledge = kb
      ..userName = 'Khai'
      ..phase = Phase.ready
      ..bootStarted = true
      ..tourDone = true
      ..healthGoal = 'turun'
      ..healthyMode = true
      ..body = const BodyProfile(heightCm: 165, weightKg: 78.5, age: 30, male: true)
      ..fasting = const FastingPlan(16, 12 * 60)
      ..history = history!
      ..models = models;
    final now = DateTime.now();
    for (final (i, d) in [0, 1, 2, 3, 5, 6, 8, 9, 10, 13, 15, 16, 17, 20, 22, 23, 27, 29, 30, 34, 36, 41, 43, 44, 50].indexed) {
      for (var k = 0; k <= i % 3; k++) {
        s.cooks.add((now.subtract(Duration(days: d)), s.recipes[(i * 7 + k) % s.recipes.length].id));
      }
    }
    for (final (d, w) in [(42, 82.0), (35, 81.4), (28, 80.9), (21, 80.1), (14, 79.6), (7, 79.0), (0, 78.5)]) {
      s.weights.add((now.subtract(Duration(days: d)), w));
    }
    final foods = {for (final f in s.foods) for (final n in f.names) n: f};
    for (final (slot, name, grams) in [('Sarapan', 'roti tawar', 60.0), ('Sarapan', 'telur', 55.0), ('Makan siang', 'nasi', 150.0), ('Makan siang', 'ayam goreng', 100.0)]) {
      final f = foods[name]!;
      s.intake.add(IntakeEntry(DateTime(now.year, now.month, now.day, slot == 'Sarapan' ? 7 : 12), slot, f.name, grams, f.per100.scale(grams / 100)));
    }

    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    final key = GlobalKey();
    var frame = 0;
    final manifest = <Map<String, dynamic>>[];

    Future<void> capture(String scene, {int ms = 100}) async {
      if (out == null) return;
      await tester.runAsync(() async {
        final img = await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage(pixelRatio: 1);
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        final name = 'f${(frame++).toString().padLeft(4, '0')}.png';
        File('$out/$name').writeAsBytesSync(png!.buffer.asUint8List());
        manifest.add({'file': name, 'scene': scene, 'ms': ms});
      });
    }

    Future<void> run(String scene, Duration length, {int step = 100}) async {
      for (var t = 0; t < length.inMilliseconds; t += step) {
        await tester.pump(Duration(milliseconds: step));
        await capture(scene, ms: step);
      }
    }

    Future<void> show(Widget home) async {
      await tester.pumpWidget(
        Scope(
          state: s,
          child: RepaintBoundary(
            key: key,
            child: MaterialApp(debugShowCheckedModeBanner: false, theme: buildTheme(), home: home),
          ),
        ),
      );
    }

    if (out != null) Directory(out).createSync(recursive: true);

    // 1. pembuka: Halo, selamat datang, lalu wajan dan layar putih
    await show(IntroScreen(onDone: () {}));
    await run('pembuka', const Duration(milliseconds: 4600));

    // 2. beranda, digulir perlahan ke jejak masak dan Gizi Seimbang
    await show(const HomeShell());
    await run('beranda', const Duration(milliseconds: 1600));
    for (var i = 0; i < 14; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -36));
      await run('beranda', const Duration(milliseconds: 100));
    }
    await run('beranda', const Duration(milliseconds: 1500));

    // 3. obrolan fokus Gizi dengan data pengguna sendiri
    s
      ..chatMode = 'gizi'
      ..messages.addAll([
        Message(Role.user, 'Tadi siang saya makan nasi dan ayam goreng'),
        Message(Role.meira, 'Dicatat untuk makan siang. Energi hari ini sekitar 760 dari 1.790 kkal. Gula, lemak, dan garam masih dalam batas aman.')
          ..actions = const ['gizi'],
        Message(Role.user, 'Boleh makan sekarang?'),
        Message(
          Role.meira,
          'Menurut jadwal 16:8, sebaiknya tunggu sampai pukul 12.00. Air putih, teh, atau kopi tanpa gula tetap boleh.',
        )..actions = const ['puasa'],
      ]);
    await show(const ChatScreen());
    await run('obrolan', const Duration(milliseconds: 3000));

    // 4. Gizi Seimbang
    await show(const HealthScreen());
    await run('gizi', const Duration(milliseconds: 1800));
    for (var i = 0; i < 16; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -45));
      await run('gizi', const Duration(milliseconds: 100));
    }
    await run('gizi', const Duration(milliseconds: 1500));

    // 5. buku resep dan tur singkat
    await show(const RecipeBookScreen(filter: 1));
    await run('resep', const Duration(milliseconds: 1800));
    await show(const TourScreen());
    await run('tur', const Duration(milliseconds: 1500));

    if (out != null) File('$out/manifest.json').writeAsStringSync(jsonEncode(manifest));
  }, skip: out == null);
}
