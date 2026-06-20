import 'package:flutter/material.dart';

class LeafLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final glowPaint = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x4066BB6A), Color(0x0066BB6A)],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.48),
          );
    canvas.drawCircle(center, size.width * 0.48, glowPaint);

    final leafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
      ).createShader(Rect.fromCenter(center: center, width: 60, height: 80));

    final leafPath = Path()
      ..moveTo(center.dx, center.dy - 38)
      ..cubicTo(
        center.dx + 30,
        center.dy - 30,
        center.dx + 35,
        center.dy + 5,
        center.dx,
        center.dy + 38,
      )
      ..cubicTo(
        center.dx - 35,
        center.dy + 5,
        center.dx - 30,
        center.dy - 30,
        center.dx,
        center.dy - 38,
      );

    canvas.drawPath(leafPath, leafPaint);

    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy - 30),
      Offset(center.dx, center.dy + 30),
      veinPaint,
    );

    final sideVeinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx + 15, center.dy - 22),
      sideVeinPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx - 15, center.dy - 22),
      sideVeinPaint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + 20, center.dy - 5),
      sideVeinPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx - 20, center.dy - 5),
      sideVeinPaint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy + 15),
      Offset(center.dx + 15, center.dy + 10),
      sideVeinPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 15),
      Offset(center.dx - 15, center.dy + 10),
      sideVeinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
