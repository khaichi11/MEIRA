import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Ilustrasi vektor datar yang digambar dengan kode (tanpa berkas gambar dari luar), memakai palet MEIRA.

const _tomato = Color(0xFFE57B84);
const _leaf = Color(0xFF5FA97A);
const _leafDark = Color(0xFF3F8A62);
const _lemon = Color(0xFFEFD27A);
const _grape = Color(0xFFB9E6DC); // anggur hijau muda, menyatu dengan tosca
const _berry = Color(0xFFDDF2EC);
const _cream = Color(0xFFFFFFFF);

/// Mangkuk berisi buah dan sayur untuk kartu utama Dapur. Buahnya bergoyang pelan.
class ProduceBowl extends StatefulWidget {
  const ProduceBowl({super.key, this.size = 220});
  final double size;

  @override
  State<ProduceBowl> createState() => _ProduceBowlState();
}

class _ProduceBowlState extends State<ProduceBowl> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(painter: _BowlPainter(_c.value)),
      ),
    ),
  );
}

class _BowlPainter extends CustomPainter {
  _BowlPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final s = w / 220;
    double bob(double phase) => math.sin((t + phase) * 2 * math.pi) * 3 * s;
    canvas.save();
    canvas.scale(s);

    // lingkar latar lembut
    canvas.drawCircle(const Offset(110, 112), 96, Paint()..color = Colors.white.withValues(alpha: .18));
    canvas.drawCircle(const Offset(110, 112), 72, Paint()..color = Colors.white.withValues(alpha: .14));

    // daun di belakang
    _leafShape(canvas, const Offset(70, 92), 36, -0.9, _leaf);
    _leafShape(canvas, const Offset(150, 86), 34, 0.8, _leafDark);
    _leafShape(canvas, const Offset(112, 70), 30, -0.1, _leaf);

    // isi mangkuk
    canvas.drawCircle(Offset(84, 118 + bob(0)), 24, Paint()..color = _tomato);
    canvas.drawCircle(Offset(78, 110 + bob(0)), 7, Paint()..color = Colors.white.withValues(alpha: .35));
    _leafShape(canvas, Offset(86, 95 + bob(0)), 10, 0.4, _leafDark);

    canvas.save();
    canvas.translate(136, 114 + bob(.3));
    canvas.rotate(-.35);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 50, height: 34), Paint()..color = _lemon);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-9, -6), width: 14, height: 8), Paint()..color = Colors.white.withValues(alpha: .4));
    canvas.restore();

    for (final (dx, dy) in const [(108.0, 104.0), (118.0, 98.0), (114.0, 110.0), (124.0, 108.0), (104.0, 114.0)]) {
      canvas.drawCircle(Offset(dx, dy + bob(.6)), 7.5, Paint()..color = _grape);
    }
    for (final (dx, dy) in const [(62.0, 130.0), (70.0, 136.0), (58.0, 140.0)]) {
      canvas.drawCircle(Offset(dx, dy + bob(.8)), 6, Paint()..color = _berry);
    }

    // mangkuk
    final bowl = Path()
      ..moveTo(36, 128)
      ..quadraticBezierTo(110, 214, 184, 128)
      ..close();
    canvas.drawPath(bowl, Paint()..color = _cream);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30, 122, 160, 12), const Radius.circular(6)), Paint()..color = _cream);
    canvas.drawPath(
      Path()
        ..moveTo(58, 150)
        ..quadraticBezierTo(110, 190, 162, 150),
      Paint()
        ..color = C.accent.withValues(alpha: .25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(88, 176, 44, 8), const Radius.circular(4)), Paint()..color = _cream);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BowlPainter old) => old.t != t;
}

void _leafShape(Canvas canvas, Offset at, double len, double angle, Color color) {
  canvas.save();
  canvas.translate(at.dx, at.dy);
  canvas.rotate(angle);
  final p = Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(len * .5, -len * .45, 0, -len)
    ..quadraticBezierTo(-len * .5, -len * .45, 0, 0);
  canvas.drawPath(p, Paint()..color = color);
  canvas.drawLine(
    Offset.zero,
    Offset(0, -len * .85),
    Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..strokeWidth = 1.4,
  );
  canvas.restore();
}
