import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/recipes.dart';
import '../theme.dart';
import 'widgets.dart';

/// Mode memasak: satu langkah per layar, huruf besar, timer otomatis bila langkah menyebut waktu,
/// dan bisa dibacakan.
class CookingScreen extends StatefulWidget {
  const CookingScreen({super.key, required this.recipe});
  final Recipe recipe;

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  final _pages = PageController();
  int _step = 0;
  Timer? _timer;
  int _left = 0;

  Recipe get r => widget.recipe;

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  /// Menit yang disebut di langkah, mis. "rebus 10 menit" atau "15-20 menit" (diambil yang terkecil).
  int? _minutes(String step) {
    final m = RegExp(r'(\d+)(?:\s*(?:-|sampai)\s*\d+)?\s*menit').firstMatch(step);
    return m == null ? null : int.parse(m.group(1)!);
  }

  void _go(int i) {
    if (i < 0 || i >= r.steps.length) return;
    HapticFeedback.selectionClick();
    _pages.animateToPage(i, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  void _startTimer(int minutes) {
    _timer?.cancel();
    setState(() => _left = minutes * 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) {
        t.cancel();
        setState(() => _left = 0);
        HapticFeedback.heavyImpact();
        Scope.of(context).speak('Waktu habis untuk langkah ${_step + 1}.');
        return;
      }
      setState(() => _left--);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final step = r.steps[_step];
    final minutes = _minutes(step);
    return Scaffold(
      appBar: AppBar(
        title: Text(r.name),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              for (var i = 0; i < r.steps.length; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(color: i <= _step ? C.herb : C.separator, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
            ]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: r.steps.length,
              onPageChanged: (i) {
                setState(() => _step = i);
                if (s.speakAnswers) s.speak('Langkah ${i + 1}. ${r.steps[i]}');
              },
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Langkah ${i + 1} dari ${r.steps.length}', style: T.subhead),
                  const SizedBox(height: 14),
                  Text(r.steps[i], style: poppins(26, weight: FontWeight.w500, height: 1.35)),
                ]),
              ),
            ),
          ),
          if (minutes != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _left > 0
                  ? Text('${(_left ~/ 60).toString().padLeft(2, '0')}:${(_left % 60).toString().padLeft(2, '0')}',
                      style: poppins(40, weight: FontWeight.w600, color: C.accent))
                  : FilledButton.tonalIcon(
                      onPressed: () => _startTimer(minutes),
                      icon: const Icon(Icons.timer_outlined),
                      label: Text('Timer $minutes menit'),
                      style: FilledButton.styleFrom(backgroundColor: C.accentTint, foregroundColor: C.accent),
                    ),
            ),
          if (_step == r.steps.length - 1 && r.tip.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
              child: Text('Tip: ${r.tip}', style: T.callout, textAlign: TextAlign.center),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(children: [
              IconButton.filledTonal(onPressed: _step > 0 ? () => _go(_step - 1) : null, icon: const Icon(Icons.arrow_back_rounded)),
              const SizedBox(width: 10),
              IconButton.filledTonal(onPressed: () => s.speak('Langkah ${_step + 1}. $step'), icon: const Icon(Icons.volume_up_rounded)),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _step < r.steps.length - 1 ? () => _go(_step + 1) : () => Navigator.pop(context),
                  child: Text(_step < r.steps.length - 1 ? 'Langkah berikutnya' : 'Selesai'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
