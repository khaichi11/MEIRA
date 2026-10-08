import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/grounding.dart';
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
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

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
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          final m = w < 360 ? 24.0 : 28.0;
          return Stack(children: [
            Positioned.fill(child: Image.memory(s.photo!, fit: BoxFit.cover, gaplessPlayback: true)),
            if (s.scanning)
              Positioned.fill(child: AnimatedBuilder(animation: _pulse, builder: (_, _) => ColoredBox(color: Colors.white.withValues(alpha: .10 + _pulse.value * .08)))),
            if (widget.showBoxes)
              for (final d in s.detections) _box(d, w, h, s.highlighted.contains(d.number)),
            for (final d in s.partial)
              Positioned(
                left: d.cx * w - 7,
                top: d.cy * h - 7,
                child: ScaleTransition(
                  scale: Tween(begin: .8, end: 1.15).animate(_pulse),
                  child: Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 4)])),
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
          ]);
        }),
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
              border: Border.all(color: hot ? C.sageDeep : Colors.white.withValues(alpha: .9), width: hot ? 2.5 : 1.5),
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
    if (groups.isEmpty) {
      return Text(s.scanning ? 'Melihat foto…' : 'Tidak ada bahan yang terlihat jelas.', style: T.subhead);
    }
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final g in groups)
        GestureDetector(
          onTap: () => s.highlight(g.numbers),
          child: MouseRegion(
            onEnter: (_) => s.highlight(g.numbers),
            onExit: (_) => s.highlight([]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
              decoration: BoxDecoration(
                color: g.numbers.any(s.highlighted.contains) ? C.sageTint : C.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                for (final n in g.numbers.take(6)) Padding(padding: const EdgeInsets.only(right: 3), child: NumberBadge(n)),
                if (g.numbers.length > 6) Text('…', style: T.footnote),
                const SizedBox(width: 4),
                Text(g.label, style: inter(14.5, weight: FontWeight.w500, color: g.key == null ? C.secondary : C.label)),
                if (g.count.isNotEmpty) Text('  ${g.count}', style: T.footnote),
              ]),
            ),
          ),
        ),
    ]);
  }
}
