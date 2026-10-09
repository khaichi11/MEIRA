import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../core/recipes.dart';
import '../runtime/reminders.dart';
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

  AppState? _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = Scope.of(context);
  }

  @override
  void dispose() {
    _state?.stopSpeaking();
    _timer?.cancel();
    if (_end != null) Reminders.instance.cancelCookTimer();
    _pages.dispose();
    super.dispose();
  }

  /// Menit yang disebut di langkah, mis. "rebus 10 menit", "15-20 menit" (diambil yang terkecil), "2 jam", atau
  /// "setengah jam".
  int? _minutes(String step) {
    final t = step.toLowerCase();
    if (RegExp(r'\bsetengah jam\b').hasMatch(t)) return 30;
    final m = RegExp(r'(\d+)(?:\s*(?:-|sampai)\s*\d+)?\s*(menit|jam)\b(?:\s*(\d+)\s*menit)?').firstMatch(t);
    return m == null ? null : (m[2] == 'jam' ? int.parse(m[1]!) * 60 + int.parse(m[3] ?? '0') : int.parse(m[1]!));
  }

  void _go(int i) {
    if (i < 0 || i >= r.steps.length) return;
    HapticFeedback.selectionClick();
    _pages.animateToPage(i, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  DateTime? _end; // waktu habis pengatur waktu; dihitung dari jam, jadi tetap benar saat aplikasi sempat di latar belakang

  /// Pengatur waktu hanya berjalan setelah pengguna mengetuknya atau mengucapkan "mulai"; saat habis, ponsel bergetar dan
  /// muncul pemberitahuan. Suara "waktu habis" hanya dibacakan bila jawaban suara aktif.
  void _startTimer(int minutes) {
    _timer?.cancel();
    final end = DateTime.now().add(Duration(minutes: minutes));
    final step = _step;
    setState(() {
      _end = end;
      _left = minutes * 60;
    });
    Reminders.instance.cookTimer(end, '${r.name}: langkah ${step + 1} selesai.');
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = _end == null ? 0 : _end!.difference(DateTime.now()).inSeconds;
      if (left <= 0) {
        t.cancel();
        setState(() {
          _left = 0;
          _end = null;
        });
        HapticFeedback.heavyImpact();
        final s = Scope.of(context);
        if (s.speakAnswers) s.speak('Waktu habis untuk langkah ${step + 1}.');
        return;
      }
      setState(() => _left = left);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    Reminders.instance.cancelCookTimer();
    setState(() {
      _left = 0;
      _end = null;
    });
  }

  /// Perintah suara (hanya saat tombol mikrofon ditekan): mulai, berhenti, lanjut, kembali, bacakan, selesai.
  Future<void> _voice(AppState s) async {
    final (text, error) = await s.toggleCommand();
    if (!mounted) return;
    if (error != null) {
      toast(context, error);
      return;
    }
    if (text == null) return; // baru mulai mendengar
    final t = text.toLowerCase();
    final minutes = _minutes(r.steps[_step]);
    if (RegExp(r'\b(berhenti|stop|batal)\b').hasMatch(t)) {
      _stopTimer();
    } else if (RegExp(r'\b(mulai|start|timer|hitung)\b').hasMatch(t) && minutes != null) {
      _startTimer(minutes);
    } else if (RegExp(r'\b(lanjut|berikutnya|selanjutnya|next)\b').hasMatch(t)) {
      _go(_step + 1);
    } else if (RegExp(r'\b(kembali|sebelumnya|mundur)\b').hasMatch(t)) {
      _go(_step - 1);
    } else if (RegExp(r'\b(bacakan|ulangi|baca)\b').hasMatch(t)) {
      s.speak('Langkah ${_step + 1}. ${r.steps[_step]}');
    } else {
      toast(context, 'Coba ucapkan: mulai, berhenti, lanjut, kembali, atau bacakan');
    }
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (var i = 0; i < r.steps.length; i++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(color: i <= _step ? C.herb : C.separator, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                ],
              ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Langkah ${i + 1} dari ${r.steps.length}', style: T.subhead),
                      const SizedBox(height: 14),
                      Text(r.steps[i], style: poppins(26, weight: FontWeight.w500, height: 1.35)),
                    ],
                  ),
                ),
              ),
            ),
            if (minutes != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _left > 0
                    ? GestureDetector(
                        onTap: _stopTimer,
                        child: Column(
                          children: [
                            Text(
                              '${(_left ~/ 60).toString().padLeft(2, '0')}:${(_left % 60).toString().padLeft(2, '0')}',
                              style: poppins(40, weight: FontWeight.w600, color: C.accent),
                            ),
                            Text('Ketuk untuk berhenti', style: T.caption),
                          ],
                        ),
                      )
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
              child: Row(
                children: [
                  IconButton.filledTonal(onPressed: _step > 0 ? () => _go(_step - 1) : null, icon: const Icon(Icons.arrow_back_rounded)),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: s.voice == VoiceState.speaking ? 'Hentikan suara' : 'Bacakan langkah',
                    onPressed: () => s.voice == VoiceState.speaking ? s.stopSpeaking() : s.speak('Langkah ${_step + 1}. $step'),
                    icon: Icon(s.voice == VoiceState.speaking ? Icons.stop_rounded : Icons.volume_up_rounded),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Perintah suara: mulai, berhenti, lanjut, kembali, bacakan',
                    onPressed: s.voice == VoiceState.transcribing ? null : () => _voice(s),
                    icon: Icon(s.voice == VoiceState.listening ? Icons.stop_circle_rounded : Icons.mic_none_rounded),
                    style: s.voice == VoiceState.listening ? IconButton.styleFrom(backgroundColor: C.clay, foregroundColor: Colors.white) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _step < r.steps.length - 1
                          ? () => _go(_step + 1)
                          : () async {
                              // resep yang selesai dimasak masuk ke jejak masak di beranda
                              await s.logCooked(r);
                              if (!context.mounted) return;
                              HapticFeedback.mediumImpact();
                              await showDialog<void>(
                                context: context,
                                builder: (_) => CookedDialog(recipe: r.name, streak: s.streak),
                              );
                              if (context.mounted) Navigator.pop(context);
                            },
                      child: Text(_step < r.steps.length - 1 ? 'Langkah berikutnya' : 'Selesai'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Perayaan kecil setelah resep selesai dimasak: tanda centang memantul dan rentetan hari memasak.
class CookedDialog extends StatelessWidget {
  const CookedDialog({super.key, required this.recipe, required this.streak});
  final String recipe;
  final int streak;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: C.bg,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: C.herbTint, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 52, color: C.herb),
            ),
          ),
          const SizedBox(height: 16),
          Text('Selamat menikmati', style: T.title),
          const SizedBox(height: 6),
          Text(recipe, style: T.callout, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          if (streak > 0)
            FadeIn(
              delay: const Duration(milliseconds: 350),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Pulse(child: Icon(Icons.local_fire_department_rounded, color: C.accentDeep, size: 20)),
                    const SizedBox(width: 6),
                    Text(
                      '$streak hari memasak berturut-turut',
                      style: inter(14, weight: FontWeight.w600, color: C.accentDeep),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    ),
  );
}
