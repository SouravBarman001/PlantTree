import 'package:flutter/material.dart';

class ScanIllustrationPainter extends CustomPainter {
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

    final phonePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 5),
          width: 60,
          height: 100,
        ),
        const Radius.circular(10),
      ),
      phonePaint,
    );

    final screenPaint = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 5),
          width: 50,
          height: 82,
        ),
        const Radius.circular(6),
      ),
      screenPaint,
    );

    _drawLeafOnScreen(canvas, center.dx, center.dy - 5);

    _drawScanLine(canvas, center, size);

    _drawSparkle(canvas, center.dx - 55, center.dy - 45, 6);
    _drawSparkle(canvas, center.dx + 50, center.dy + 50, 4);
    _drawSparkle(canvas, center.dx + 40, center.dy - 40, 5);

    _drawFloatingLeaf(canvas, center.dx - 45, center.dy + 30, -0.4);
    _drawFloatingLeaf(canvas, center.dx + 48, center.dy - 15, 0.5);
  }

  void _drawLeafOnScreen(Canvas canvas, double x, double y) {
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);
    final leafPath = Path();

    leafPath.moveTo(x, y);
    leafPath.cubicTo(x - 8, y - 12, x - 5, y - 22, x, y - 25);
    leafPath.cubicTo(x + 5, y - 22, x + 8, y - 12, x, y);

    canvas.drawPath(leafPath, leafPaint);
  }

  void _drawScanLine(Canvas canvas, Offset center, Size size) {
    final scanPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - 22, center.dy - 10),
      Offset(center.dx + 22, center.dy - 10),
      scanPaint,
    );

    final glowPaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(
      Offset(center.dx - 22, center.dy - 10),
      Offset(center.dx + 22, center.dy - 10),
      glowPaint,
    );
  }

  void _drawSparkle(Canvas canvas, double x, double y, double size) {
    final paint = Paint()..color = const Color(0xFF80CBC4);

    canvas.drawCircle(Offset(x, y), size * 0.3, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF80CBC4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(x, y - size), Offset(x, y + size), linePaint);
    canvas.drawLine(Offset(x - size, y), Offset(x + size, y), linePaint);
  }

  void _drawFloatingLeaf(Canvas canvas, double x, double y, double angle) {
    final leafPaint = Paint()..color = const Color(0xFF81C784);
    final leafPath = Path();

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    leafPath.moveTo(0, 0);
    leafPath.cubicTo(-6, -8, -4, -16, 0, -18);
    leafPath.cubicTo(4, -16, 6, -8, 0, 0);

    canvas.drawPath(leafPath, leafPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
