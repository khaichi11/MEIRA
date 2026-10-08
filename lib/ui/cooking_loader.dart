import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Animasi memasak untuk layar pembuka dan saat MEIRA membaca foto: wajan bergoyang, bahan dilempar ke atas
/// bergantian, dan uap naik perlahan. Semua digambar dengan kode, tanpa gambar dari luar.
class CookingLoader extends StatefulWidget {
  const CookingLoader({super.key, this.size = 160});
  final double size;

  @override
  State<CookingLoader> createState() => _CookingLoaderState();
}

class _CookingLoaderState extends State<CookingLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Sedang menyiapkan',
    child: SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(painter: _PanPainter(_c.value)),
      ),
    ),
  );
}

class _PanPainter extends CustomPainter {
  _PanPainter(this.t);
  final double t; // 0..1, satu putaran

  // warna bahan dibuat redup agar tidak ramai
  static const _items = [
    (Color(0xFFE06C75), 0.00, -0.13, 0), // tomat
    (Color(0xFF6BAF8A), 0.25, 0.05, 1), // daun
    (Color(0xFFE9C46A), 0.50, 0.15, 2), // jagung
    (Color(0xFFE06C75), 0.75, -0.02, 0), // tomat kedua
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final toss = math.sin(t * 2 * math.pi); // goyangan wajan
    final cx = w * .46, cy = h * .66 + toss * h * .015;
    final rw = w * .60, rh = h * .19; // elips bibir wajan (tampak serong dari atas)
    final rim = Rect.fromCenter(center: Offset(cx, cy), width: rw, height: rh);

    // bayangan di lantai
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * .92), width: rw * .8, height: h * .045), Paint()..color = C.label.withValues(alpha: .07));

    // gagang di belakang kanan
    canvas.save();
    canvas.translate(cx + rw * .46, cy - rh * .05);
    canvas.rotate(-.18 + toss * .03);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, -h * .022, w * .30, h * .044), Radius.circular(h * .022)),
      Paint()..color = C.label.withValues(alpha: .75),
    );
    canvas.restore();

    // badan wajan (bagian bawah) lalu bagian dalam
    canvas.drawPath(
      Path()
        ..moveTo(rim.left, cy)
        ..quadraticBezierTo(cx, cy + rh * 1.55, rim.right, cy)
        ..close(),
      Paint()..color = C.label.withValues(alpha: .85),
    );
    canvas.drawOval(rim, Paint()..color = C.label.withValues(alpha: .85));
    canvas.drawOval(rim.deflate(w * .018), Paint()..color = const Color(0xFF3A4660));

    // uap naik dari dalam wajan
    final steam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * .02;
    for (var i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1;
      steam.color = C.tertiary.withValues(alpha: (1 - phase) * .55);
      final x0 = cx + (i - 1) * w * .11;
      final y0 = cy - rh * .3 - phase * h * .30;
      final path = Path()..moveTo(x0, y0);
      for (var k = 1; k <= 3; k++) {
        path.quadraticBezierTo(x0 + (k.isOdd ? 1 : -1) * w * .03, y0 - k * h * .04 + h * .02, x0, y0 - k * h * .04);
      }
      canvas.drawPath(path, steam);
    }

    // bahan: diam di dalam wajan, lalu dilempar bergantian dan jatuh kembali ke dalam
    final inside = Path()..addOval(rim.deflate(w * .02));
    for (final (color, phase, dx, kind) in _items) {
      final p = (t + phase) % 1;
      final jump = p < .45 ? math.sin(p / .45 * math.pi) : 0.0;
      final x = cx + rw * dx;
      final restY = cy + rh * .05;
      final y = restY - jump * h * .40;
      final r = w * .05;
      canvas.save();
      if (jump == 0) canvas.clipPath(inside); // saat di dalam, tidak menembus bibir wajan
      canvas.translate(x, y);
      canvas.rotate(jump * math.pi * (dx >= 0 ? 1 : -1));
      final paint = Paint()..color = color;
      switch (kind) {
        case 1:
          canvas.drawPath(
            Path()
              ..moveTo(-r * 1.2, 0)
              ..quadraticBezierTo(0, -r * 1.1, r * 1.2, 0)
              ..quadraticBezierTo(0, r * 1.1, -r * 1.2, 0),
            paint,
          );
        case 2:
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: r * 1.5, height: r * 1.5), Radius.circular(r * .35)),
            paint,
          );
        default:
          canvas.drawCircle(Offset.zero, r, paint);
          canvas.drawCircle(Offset(-r * .3, -r * .3), r * .26, Paint()..color = Colors.white.withValues(alpha: .35));
      }
      canvas.restore();
    }

    // bibir depan wajan digambar terakhir agar bahan tampak berada di dalam
    canvas.drawArc(
      rim,
      0,
      math.pi,
      false,
      Paint()
        ..color = C.label.withValues(alpha: .9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .022,
    );
    canvas.drawArc(
      rim.deflate(w * .011),
      .15,
      math.pi - .3,
      false,
      Paint()
        ..color = C.accent.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .008,
    );
  }

  @override
  bool shouldRepaint(_PanPainter old) => old.t != t;
}
