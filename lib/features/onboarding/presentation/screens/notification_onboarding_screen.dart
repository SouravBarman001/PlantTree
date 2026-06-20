import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../painters/notification_painter.dart';

class NotificationOnboardingScreen extends StatelessWidget {
  const NotificationOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          SizedBox(
            width: size.width * 0.65,
            height: size.width * 0.65,
            child: CustomPaint(painter: NotificationIllustrationPainter()),
          ),
          const Spacer(flex: 2),
          Text(
            'Allow notifications',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B5E20),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'To receive important disease trends, weather alerts and helpful farming tips.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF757575),
              height: 1.6,
            ),
          ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Request notification permission
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Allow',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
