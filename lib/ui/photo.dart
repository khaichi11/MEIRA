import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/grounding.dart';
import '../core/vocab.dart';
import '../theme.dart';
import 'marker_sheet.dart';
import 'widgets.dart';

/// Foto dengan penanda angka di tengah setiap bahan. Selama model menulis, titik kecil muncul
/// satu per satu; begitu selesai, titik berubah menjadi nomor urut kiri ke kanan.
class PhotoView extends StatefulWidget {
  const PhotoView({super.key, required this.state, this.showBoxes = false});
  final AppState state;
  final bool showBoxes;

  @override
  State<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> with SingleTickerProviderStateMixin {
  // dibuat di initState, bukan malas: pengontrol yang baru dibuat di dispose() memicu galat pada elemen yang sudah lepas
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final size = s.photoSize ?? const Size(4, 3);
    return AspectRatio(
      aspectRatio: size.width / size.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth, h = c.maxHeight;
            final m = w < 360 ? 24.0 : 28.0;
            return Stack(
              children: [
                const Positioned.fill(child: ColoredBox(color: C.grouped)),
                Positioned.fill(
                  child: Image.memory(
                    s.photo!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    frameBuilder: (_, child, frame, sync) => sync
                        ? child
                        : AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOut,
                            child: child,
                          ),
                  ),
                ),
                // selama foto dibaca, pita cahaya lembut menyapu dari atas ke bawah
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      child: s.scanning || (s.busy && s.detections.isEmpty)
                          ? const _Sweep(key: ValueKey('sapu'))
                          : const SizedBox.expand(),
                    ),
                  ),
                ),
                if (widget.showBoxes)
                  for (final d in s.detections) _box(d, w, h, s.highlighted.contains(d.number)),
                for (final d in s.partial)
                  Positioned(
                    left: d.cx * w - 7,
                    top: d.cy * h - 7,
                    child: ScaleTransition(
                      scale: Tween(begin: .8, end: 1.15).animate(_pulse),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),
                for (final d in s.detections)
                  Positioned(
                    left: d.cx * w - m / 2,
                    top: d.cy * h - m / 2,
                    child: GestureDetector(
                      onTap: () => showMarkerSheet(context, s, d),
                      child: MouseRegion(
                        onEnter: (_) => s.highlight([d.number]),
                        onExit: (_) => s.highlight([]),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 220 + d.number * 30),
                          curve: Curves.easeOutBack,
                          builder: (_, v, child) => Transform.scale(scale: v, child: child),
                          child: Marker(d.number, size: m, active: s.highlighted.contains(d.number)),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _box(Detection d, double w, double h, bool hot) => Positioned(
    left: d.box[0] * w,
    top: d.box[1] * h,
    width: (d.box[2] - d.box[0]) * w,
    height: (d.box[3] - d.box[1]) * h,
    child: IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: hot ? C.accent : Colors.white.withValues(alpha: .9), width: hot ? 2.5 : 1.5),
        ),
      ),
    ),
  );
}

/// Daftar bahan yang terlihat: nomor, nama, dan jumlah dengan satuan alaminya.
class SeenList extends StatelessWidget {
  const SeenList({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final groups = grouped(s.detections);
    final Widget child;
    if (groups.isEmpty) {
      child = s.busy || s.scanning
          ? const _PillsLoading(key: ValueKey('memuat'))
          : Text('Tidak ada bahan yang terlihat jelas.', key: const ValueKey('kosong'), style: T.subhead);
    } else {
      child = _chips(s, groups);
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        layoutBuilder: (current, previous) => Stack(alignment: Alignment.topLeft, children: [...previous, ?current]),
        child: child,
      ),
    );
  }

  Widget _chips(AppState s, List<IngredientGroup> groups) {
    return Wrap(
      key: const ValueKey('bahan'),
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (i, g) in groups.indexed)
          FadeIn(
            key: ValueKey('${g.label}/${g.numbers.first}'),
            delay: Duration(milliseconds: 60 * math.min(i, 6)),
            child: GestureDetector(
              onTap: () => s.highlight(g.numbers),
              child: MouseRegion(
                onEnter: (_) => s.highlight(g.numbers),
                onExit: (_) => s.highlight([]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
                  decoration: BoxDecoration(
                    color: g.numbers.any(s.highlighted.contains) ? C.accentTint : C.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final n in g.numbers.take(6))
                        Padding(padding: const EdgeInsets.only(right: 3), child: NumberBadge(n)),
                      if (g.numbers.length > 6) Text('…', style: T.footnote),
                      const SizedBox(width: 4),
                      Text(
                        g.label,
                        style: inter(14.5, weight: FontWeight.w500, color: g.key == null ? C.secondary : C.label),
                      ),
                      if (g.count.isNotEmpty) Text('  ${g.count}', style: T.footnote),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // bahan dari foto tambahan atau dari percakapan, tanpa penanda di foto ini
        for (final key in (s.session?.prefs.include ?? const <String>{}).where(
          (k) => !s.detections.any((d) => d.key == k),
        ))
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
            decoration: BoxDecoration(color: C.herbTint, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 16, color: C.herb),
                const SizedBox(width: 4),
                Text(displayName(key), style: inter(14.5, weight: FontWeight.w500)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Pita cahaya yang menyapu foto selama bahan dibaca.
class _Sweep extends StatefulWidget {
  const _Sweep({super.key});

  @override
  State<_Sweep> createState() => _SweepState();
}

class _SweepState extends State<_Sweep> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => CustomPaint(painter: _SweepPainter(Curves.easeInOutSine.transform(_c.value))),
  );
}

class _SweepPainter extends CustomPainter {
  _SweepPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white.withValues(alpha: .08));
    final band = size.height * .45;
    final y = -band + (size.height + band) * t;
    final rect = Rect.fromLTWH(0, y, size.width, band);
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: .30),
        Colors.white.withValues(alpha: 0),
      ],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.t != t;
}

/// Kerangka chip bahan yang berdenyut pelan selama foto dibaca.
class _PillsLoading extends StatefulWidget {
  const _PillsLoading({super.key});

  @override
  State<_PillsLoading> createState() => _PillsLoadingState();
}

class _PillsLoadingState extends State<_PillsLoading> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Membaca bahan',
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Wrap(
        spacing: 8,
        children: [
          for (final (i, w) in const [96.0, 78.0, 64.0].indexed)
            Container(
              width: w,
              height: 30,
              decoration: BoxDecoration(
                // tiap kerangka berdenyut bergantian, seperti gelombang
                color: Color.lerp(C.surface, C.separator, .5 + .5 * math.sin((_c.value - i * .15) * 2 * math.pi)),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
        ],
      ),
    ),
  );
}
