import 'package:flutter/material.dart';

class NotificationIllustrationPainter extends CustomPainter {
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

    _drawHand(canvas, center);

    _drawPhone(canvas, center);

    _drawBellNotification(canvas, center.dx + 45, center.dy - 50);

    _drawFloatingLeaf(canvas, center.dx - 55, center.dy + 10, -0.5);
    _drawFloatingLeaf(canvas, center.dx + 55, center.dy + 20, 0.4);
    _drawFloatingLeaf(canvas, center.dx - 40, center.dy - 30, -0.2);
    _drawFloatingLeaf(canvas, center.dx + 35, center.dy + 35, 0.3);

    _drawSparkle(canvas, center.dx - 60, center.dy - 40, 7);
    _drawSparkle(canvas, center.dx + 55, center.dy + 45, 5);
    _drawSparkle(canvas, center.dx + 60, center.dy - 20, 4);
  }

  void _drawHand(Canvas canvas, Offset center) {
    final handPaint = Paint()..color = const Color(0xFF8D6E63);

    final wristPath = Path()
      ..moveTo(center.dx - 15, center.dy + 65)
      ..quadraticBezierTo(
        center.dx - 25,
        center.dy + 40,
        center.dx - 20,
        center.dy + 20,
      )
      ..quadraticBezierTo(
        center.dx - 15,
        center.dy + 5,
        center.dx - 5,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + 5,
        center.dy - 5,
        center.dx + 15,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + 25,
        center.dy + 5,
        center.dx + 20,
        center.dy + 20,
      )
      ..quadraticBezierTo(
        center.dx + 15,
        center.dy + 40,
        center.dx + 10,
        center.dy + 65,
      )
      ..close();

    canvas.drawPath(wristPath, handPaint);

    final fingerPaint = Paint()..color = const Color(0xFF795548);

    final thumbPath = Path()
      ..moveTo(center.dx - 18, center.dy + 15)
      ..quadraticBezierTo(
        center.dx - 30,
        center.dy + 10,
        center.dx - 28,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - 26,
        center.dy - 8,
        center.dx - 15,
        center.dy - 5,
      )
      ..close();
    canvas.drawPath(thumbPath, fingerPaint);

    final finger1 = Path()
      ..moveTo(center.dx - 5, center.dy - 2)
      ..quadraticBezierTo(
        center.dx - 8,
        center.dy - 15,
        center.dx - 3,
        center.dy - 20,
      )
      ..quadraticBezierTo(
        center.dx + 2,
        center.dy - 15,
        center.dx + 3,
        center.dy - 2,
      )
      ..close();
    canvas.drawPath(finger1, fingerPaint);

    final finger2 = Path()
      ..moveTo(center.dx + 5, center.dy - 2)
      ..quadraticBezierTo(
        center.dx + 2,
        center.dy - 18,
        center.dx + 7,
        center.dy - 22,
      )
      ..quadraticBezierTo(
        center.dx + 12,
        center.dy - 18,
        center.dx + 13,
        center.dy - 2,
      )
      ..close();
    canvas.drawPath(finger2, fingerPaint);

    final finger3 = Path()
      ..moveTo(center.dx + 14, center.dy + 2)
      ..quadraticBezierTo(
        center.dx + 12,
        center.dy - 14,
        center.dx + 16,
        center.dy - 17,
      )
      ..quadraticBezierTo(
        center.dx + 21,
        center.dy - 13,
        center.dx + 22,
        center.dy + 2,
      )
      ..close();
    canvas.drawPath(finger3, fingerPaint);
  }

  void _drawPhone(Canvas canvas, Offset center) {
    final phonePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 10),
          width: 55,
          height: 95,
        ),
        const Radius.circular(10),
      ),
      phonePaint,
    );

    final screenPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 10),
          width: 47,
          height: 78,
        ),
        const Radius.circular(6),
      ),
      screenPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final y = center.dy - 35 + (i * 12.0);
      final lineWidth = i == 0 ? 30.0 : (i == 3 ? 20.0 : 28.0);
      canvas.drawLine(
        Offset(center.dx - lineWidth / 2, y),
        Offset(center.dx + lineWidth / 2, y),
        linePaint,
      );
    }
  }

  void _drawBellNotification(Canvas canvas, double x, double y) {
    final bellBgPaint = Paint()..color = const Color(0xFFEF5350);
    canvas.drawCircle(Offset(x, y), 24, bellBgPaint);

    final bellPaint = Paint()..color = Colors.white;

    final bellPath = Path()
      ..moveTo(x - 10, y - 2)
      ..quadraticBezierTo(x - 12, y - 14, x, y - 14)
      ..quadraticBezierTo(x + 12, y - 14, x + 10, y - 2)
      ..lineTo(x + 12, y + 2)
      ..lineTo(x - 12, y + 2)
      ..close();
    canvas.drawPath(bellPath, bellPaint);

    final clapperPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(x, y + 6), 3, clapperPaint);
  }

  void _drawFloatingLeaf(Canvas canvas, double x, double y, double angle) {
    final leafPaint = Paint()..color = const Color(0xFF81C784);
    final leafPath = Path();

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    leafPath.moveTo(0, 0);
    leafPath.cubicTo(-7, -10, -5, -18, 0, -22);
    leafPath.cubicTo(5, -18, 7, -10, 0, 0);

    canvas.drawPath(leafPath, leafPaint);
    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, double x, double y, double size) {
    final paint = Paint()..color = const Color(0xFF80CBC4);

    canvas.drawCircle(Offset(x, y), size * 0.25, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF80CBC4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(x, y - size), Offset(x, y + size), linePaint);
    canvas.drawLine(Offset(x - size, y), Offset(x + size, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
