import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../painters/plant_painter.dart';

class WelcomeOnboardingScreen extends StatelessWidget {
  const WelcomeOnboardingScreen({super.key});

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
            child: CustomPaint(painter: PlantIllustrationPainter()),
          ),
          const Spacer(flex: 2),
          Text(
            'Welcome to\nPlant Tree',
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
            'Detect plant diseases instantly with AI-powered leaf analysis. Keep your plants healthy and thriving.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF757575),
              height: 1.6,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
