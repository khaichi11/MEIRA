import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../app_state.dart';
import '../theme.dart';

/// Akses AppState dari pohon widget.
class Scope extends InheritedNotifier<AppState> {
  const Scope({super.key, required AppState state, required super.child}) : super(notifier: state);
  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Scope>()!.notifier!;
}

/// Penanda angka di foto: lingkaran putih, angka sage tua. Saat dipilih warnanya terbalik.
class Marker extends StatelessWidget {
  const Marker(this.number, {super.key, this.size = 28, this.active = false});
  final int number;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    // penanda baru muncul dengan sedikit memantul
    tween: Tween(begin: .4, end: 1),
    duration: const Duration(milliseconds: 360),
    curve: Curves.easeOutBack,
    builder: (_, v, child) => Transform.scale(
      scale: v,
      child: Opacity(opacity: v.clamp(0, 1), child: child),
    ),
    child: _disc(),
  );

  Widget _disc() => AnimatedContainer(
    duration: const Duration(milliseconds: 160),
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? C.accent : Colors.white,
      shape: BoxShape.circle,
      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 1))],
    ),
    child: Text(
      '$number',
      style: inter(size * .46, weight: FontWeight.w700, color: active ? Colors.white : C.accent, height: 1),
    ),
  );
}

/// Lencana angka kecil untuk legenda, kartu resep, dan teks jawaban.
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.number, {super.key, this.size = 20});
  final int number;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    height: size,
    constraints: BoxConstraints(minWidth: size),
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(size / 2)),
    child: Center(
      widthFactor: 1,
      child: Text(
        '$number',
        style: inter(size * .55, weight: FontWeight.w700, color: C.accent, height: 1),
      ),
    ),
  );
}

/// Mengecil sedikit saat ditekan, lalu kembali; memberi rasa "tertekan" pada kartu dan tombol.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child});
  final Widget child;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) => _down == v ? null : setState(() => _down = v);

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _set(true),
    onPointerUp: (_) => _set(false),
    onPointerCancel: (_) => _set(false),
    child: AnimatedScale(scale: _down ? .97 : 1, duration: const Duration(milliseconds: 140), curve: Curves.easeOut, child: widget.child),
  );
}

/// Melayang perlahan naik turun dengan sedikit miring, untuk ilustrasi.
class Floating extends StatefulWidget {
  const Floating({super.key, required this.child, this.amplitude = 5});
  final Widget child;
  final double amplitude;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (_, child) {
      final a = _c.value * 2 * math.pi;
      return Transform.translate(
        offset: Offset(0, math.sin(a) * widget.amplitude),
        child: Transform.rotate(angle: math.sin(a + 1.2) * .025, child: child),
      );
    },
  );
}

/// Muncul perlahan sambil bergeser sedikit ke atas; [delay] untuk urutan bertahap.
class FadeIn extends StatefulWidget {
  const FadeIn({super.key, required this.child, this.delay = Duration.zero, this.offset = 10, this.dx = 0, this.scale = 1});
  final Widget child;
  final Duration delay;
  final double offset;
  final double dx; // geser mendatar saat masuk, misalnya pesan pengguna dari kanan
  final double scale; // ukuran awal, misalnya .96 untuk efek sedikit membesar

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () => mounted ? _c.forward() : null);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _t,
    builder: (_, child) => Opacity(
      opacity: _t.value,
      child: Transform.translate(
        offset: Offset((1 - _t.value) * widget.dx, (1 - _t.value) * widget.offset),
        child: widget.scale == 1 ? child : Transform.scale(scale: widget.scale + (1 - widget.scale) * _t.value, child: child),
      ),
    ),
    child: widget.child,
  );
}

/// Jawaban yang muncul kata demi kata seperti sedang diketik. Kecepatannya menyesuaikan panjang jawaban: minimal
/// sekitar 45 huruf per detik, dan jawaban panjang tetap selesai dalam kira-kira dua detik.
class TypingText extends StatefulWidget {
  const TypingText({super.key, required this.message, this.onNumber, this.onGrow});
  final Message message;
  final void Function(int? n)? onNumber;
  final VoidCallback? onGrow;

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;
  double _carry = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.message.animate) widget.message.shown = widget.message.text.length;
    _ticker.start();
  }

  void _tick(Duration now) {
    final m = widget.message;
    // selisih waktu dibatasi supaya ketikan tidak melompat bila ponsel sempat tersendat
    final dt = math.min((now - _last).inMicroseconds / 1e6, 1 / 30);
    _last = now;
    if (m.shown >= m.text.length) return;
    final speed = math.max(45.0, m.text.length / 2.0); // huruf per detik
    _carry += speed * dt;
    var next = m.shown + _carry.floor();
    _carry -= _carry.floor();
    if (next <= m.shown) return;
    // berhenti di akhir kata agar kata tidak terpotong di tengah
    final space = m.text.indexOf(RegExp(r'\s'), next);
    next = space == -1 ? m.text.length : math.min(space, m.text.length);
    setState(() => m.shown = next);
    widget.onGrow?.call();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final visible = m.text.substring(0, math.min(m.shown, m.text.length));
    return AnswerText(visible, onNumber: widget.onNumber);
  }
}

/// Teks jawaban: "#3" tampil sebagai lencana angka yang sama dengan penanda foto.
class AnswerText extends StatelessWidget {
  const AnswerText(this.text, {super.key, this.style, this.onNumber});
  final String text;
  final TextStyle? style;
  final void Function(int? n)? onNumber;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in RegExp(r'\*\*(.+?)\*\*|\(?#(\d+)\)?').allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: const TextStyle(fontWeight: FontWeight.w600, fontVariations: [FontVariation('wght', 600)]),
          ),
        );
      } else {
        final n = int.parse(m.group(2)!);
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MouseRegion(
              onEnter: (_) => onNumber?.call(n),
              onExit: (_) => onNumber?.call(null),
              child: GestureDetector(
                onTap: () => onNumber?.call(n),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: NumberBadge(n, size: 19)),
              ),
            ),
          ),
        );
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(TextSpan(style: style ?? T.body, children: spans));
  }
}

/// Bagian berkelompok bergaya Pengaturan iOS.
class Section extends StatelessWidget {
  const Section({super.key, this.header, this.footer, required this.children});
  final String? header;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
            child: Text(header!.toUpperCase(), style: T.sectionHeader),
          ),
        Container(
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const Padding(padding: EdgeInsets.only(left: 16), child: Divider()),
              ],
            ],
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
            child: Text(footer!, style: T.footnote),
          ),
      ],
    ),
  );
}

class Row2 extends StatelessWidget {
  const Row2({super.key, required this.title, this.subtitle, this.trailing, this.onTap, this.leading, this.destructive = false});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: inter(16, color: destructive ? C.clay : C.label)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!, style: T.footnote),
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    ),
  );
}

/// Judul besar di atas halaman, seperti aplikasi bawaan iOS.
class LargeTitle extends StatelessWidget {
  const LargeTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
    child: Row(
      children: [
        Expanded(child: Text(text, style: T.largeTitle)),
        ?trailing,
      ],
    ),
  );
}

void toast(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

/// Tiga titik yang bernapas bergantian: MEIRA sedang berpikir.
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: C.herb.withValues(alpha: .3 + .7 * (0.5 + 0.5 * math.sin((_c.value * 2 * math.pi) - i * 0.9))),
              shape: BoxShape.circle,
            ),
          ),
      ],
    ),
  );
}

/// Denyut halus berulang, misalnya untuk ikon api pada rentetan hari memasak.
class Pulse extends StatefulWidget {
  const Pulse({super.key, required this.child, this.amount = .08});
  final Widget child;
  final double amount;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(begin: 1.0, end: 1 + widget.amount).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
    child: widget.child,
  );
}
