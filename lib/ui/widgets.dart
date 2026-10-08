import 'dart:math' as math;

import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? C.sageDeep : Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 1))],
        ),
        child: Text('$number', style: inter(size * .46, weight: FontWeight.w700, color: active ? Colors.white : C.sageDeep, height: 1)),
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
        decoration: BoxDecoration(color: C.sageTint, borderRadius: BorderRadius.circular(size / 2)),
        child: Center(widthFactor: 1, child: Text('$number', style: inter(size * .55, weight: FontWeight.w700, color: C.sageDeep, height: 1))),
      );
}

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) =>
      ClipRRect(borderRadius: BorderRadius.circular(size * .23), child: Image.asset('assets/icon.png', width: size, height: size, filterQuality: FilterQuality.medium));
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
        spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w600, fontVariations: [FontVariation('wght', 600)])));
      } else {
        final n = int.parse(m.group(2)!);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: MouseRegion(
            onEnter: (_) => onNumber?.call(n),
            onExit: (_) => onNumber?.call(null),
            child: GestureDetector(onTap: () => onNumber?.call(n), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: NumberBadge(n, size: 19))),
          ),
        ));
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (header != null) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 7), child: Text(header!.toUpperCase(), style: T.sectionHeader)),
          Container(
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const Padding(padding: EdgeInsets.only(left: 16), child: Divider()),
              ],
            ]),
          ),
          if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(16, 7, 16, 0), child: Text(footer!, style: T.footnote)),
        ]),
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
            child: Row(children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: inter(16, color: destructive ? C.clay : C.label)),
                  if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(subtitle!, style: T.footnote)),
                ]),
              ),
              ?trailing,
            ]),
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
        child: Row(children: [Expanded(child: Text(text, style: T.largeTitle)), ?trailing]),
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
        builder: (_, _) => Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < 3; i++)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: C.sage.withValues(alpha: .3 + .7 * (0.5 + 0.5 * math.sin((_c.value * 2 * math.pi) - i * 0.9))),
                shape: BoxShape.circle,
              ),
            ),
        ]),
      );
}
