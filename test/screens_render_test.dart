// ignore_for_file: avoid_print
// Render layar beranda dan program sehat ke PNG untuk diperiksa (tidak dijalankan di CI). Jalankan:
//   MEIRA_SHOTS=/tmp/meira-shots flutter test test/screens_render_test.dart --update-goldens
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meira/app_state.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/theme.dart';
import 'package:meira/ui/health.dart';
import 'package:meira/ui/kitchen.dart';
import 'package:meira/ui/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // ikon Material
  final icons = FontLoader('MaterialIcons');
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '${Platform.environment['HOME']}/flutter';
  final iconFile = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (iconFile.existsSync()) {
    icons.addFont(Future.value(ByteData.sublistView(iconFile.readAsBytesSync())));
    await icons.load();
  }
}

void main() {
  final out = Platform.environment['MEIRA_SHOTS'];
  testWidgets('beranda dan program sehat', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(_fonts);
    final s = AppState()
      ..recipes = parseRecipes(File('assets/resep.md').readAsStringSync())
      ..userName = 'Khai'
      ..healthGoal = 'turun';
    final now = DateTime.now();
    for (final d in [0, 1, 2, 4, 5, 9, 10, 11, 12, 20, 21, 30, 31, 32]) {
      s.cooks.add((now.subtract(Duration(days: d)), s.recipes[d % s.recipes.length].id));
    }
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    for (final (name, screen, scroll) in [
      ('beranda', KitchenScreen(onCorrect: (_) {}) as Widget, 0.0),
      ('beranda-bawah', KitchenScreen(onCorrect: (_) {}) as Widget, 900.0),
      ('sehat', const HealthScreen() as Widget, 0.0),
    ]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        Scope(
          state: s,
          child: MaterialApp(
            theme: buildTheme(),
            home: RepaintBoundary(
              key: key,
              child: Scaffold(body: SafeArea(child: screen)),
            ),
          ),
        ),
      );
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      if (scroll > 0) {
        await tester.drag(find.byType(Scrollable).first, Offset(0, -scroll));
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
      }
      if (out != null) {
        await tester.runAsync(() async {
          final img = await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage(pixelRatio: 1);
          final png = await img.toByteData(format: ui.ImageByteFormat.png);
          File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
        });
      }
    }
  }, skip: out == null);
}
