import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import 'cooking_loader.dart';
import 'widgets.dart';

/// Layar pembuka: animasi memasak, satu baris status, dan garis progres tipis.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final failed = s.phase == Phase.failed;
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (failed) const LogoMark(size: 88) else const CookingLoader(size: 180),
              const SizedBox(height: 22),
              Text('MEIRA', style: poppins(30, weight: FontWeight.w600, spacing: 2)),
              const SizedBox(height: 6),
              Text('Multimodal Edge Intelligence for Recipe Assistance', textAlign: TextAlign.center, style: T.subhead),
              const SizedBox(height: 36),
              if (failed) ...[
                Text('MEIRA belum bisa dinyalakan.', style: T.headline),
                const SizedBox(height: 6),
                Text(s.bootError, textAlign: TextAlign.center, style: T.footnote, maxLines: 4, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 20),
                FilledButton(onPressed: s.boot, child: const Text('Coba lagi')),
              ] else ...[
                SizedBox(
                  width: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: s.bootProgress),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (_, v, _) => LinearProgressIndicator(value: v == 0 ? null : v, minHeight: 3),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(s.bootLabel, key: ValueKey(s.bootLabel), style: T.footnote),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
