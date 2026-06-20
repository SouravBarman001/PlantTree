import 'package:flutter/material.dart';

class PlantIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final blobPaint = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0xFFB2DFDB), Color(0xFFE0F2F1)],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.42),
          );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.85,
        height: size.height * 0.75,
      ),
      blobPaint,
    );

    final potPaint = Paint()..color = const Color(0xFF8D6E63);
    final potPath = Path()
      ..moveTo(center.dx - 35, center.dy + 30)
      ..lineTo(center.dx - 28, center.dy + 70)
      ..lineTo(center.dx + 28, center.dy + 70)
      ..lineTo(center.dx + 35, center.dy + 30)
      ..close();
    canvas.drawPath(potPath, potPaint);

    final rimPaint = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 30),
          width: 78,
          height: 12,
        ),
        const Radius.circular(4),
      ),
      rimPaint,
    );

    _drawLeaf(canvas, center.dx - 5, center.dy - 5, -0.3, size);
    _drawLeaf(canvas, center.dx + 5, center.dy - 10, 0.4, size);
    _drawLeaf(canvas, center.dx - 2, center.dy - 25, -0.1, size);
    _drawLeaf(canvas, center.dx + 8, center.dy - 20, 0.6, size);

    final stemPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy + 25),
      Offset(center.dx, center.dy - 20),
      stemPaint,
    );
  }

  void _drawLeaf(Canvas canvas, double x, double y, double angle, Size size) {
    final leafPaint = Paint()..color = const Color(0xFF66BB6A);
    final leafPath = Path();

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    leafPath.moveTo(0, 0);
    leafPath.cubicTo(-12, -15, -8, -30, 0, -35);
    leafPath.cubicTo(8, -30, 12, -15, 0, 0);

    canvas.drawPath(leafPath, leafPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
