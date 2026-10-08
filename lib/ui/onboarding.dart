import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import 'widgets.dart';

/// Perkenalan singkat saat pertama dibuka: tiga hal yang perlu diketahui, bisa dilewati.
class Onboarding extends StatefulWidget {
  const Onboarding({super.key, required this.onDone});
  final VoidCallback onDone;

  static Future<bool> needed() async => !((await SharedPreferences.getInstance()).getBool('onboarded') ?? false);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final _pages = PageController();
  int _i = 0;

  static const _items = [
    (Icons.photo_camera_outlined, 'Foto isi dapur Anda', 'Bahan mentah atau makanan jadi. Semuanya diproses di ponsel ini, tanpa internet.'),
    (Icons.looks_one_outlined, 'Setiap bahan diberi nomor', 'Satu buah satu nomor. Ketuk nomornya bila salah, MEIRA langsung memperbarui resepnya.'),
    (Icons.mic_none_rounded, 'Bertanya dengan leluasa', 'Ketik atau ucapkan, misalnya "resep lain", "tanpa kompor", atau "apakah ada telur?". Langkah memasak juga dapat dibacakan.'),
  ];

  Future<void> _finish() async {
    (await SharedPreferences.getInstance()).setBool('onboarded', true);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final last = _i == _items.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _finish, child: const Text('Lewati'))),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: _items.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (_, i) {
                final (icon, title, body) = _items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (i == 0) const LogoMark(size: 88) else Icon(icon, size: 72, color: C.sage),
                    const SizedBox(height: 32),
                    Text(title, textAlign: TextAlign.center, style: T.largeTitle),
                    const SizedBox(height: 12),
                    Text(body, textAlign: TextAlign.center, style: inter(16, color: C.secondary, height: 1.5)),
                  ]),
                );
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _i ? 22 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(color: i == _i ? C.sageDeep : C.separator, borderRadius: BorderRadius.circular(4)),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: last ? _finish : () => _pages.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut),
                child: Text(last ? 'Mulai' : 'Lanjut'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
