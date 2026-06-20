import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../painters/scan_painter.dart';
import '../providers/onboarding_provider.dart';

class ScanOnboardingScreen extends ConsumerWidget {
  const ScanOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          SizedBox(
            width: size.width * 0.65,
            height: size.width * 0.65,
            child: CustomPaint(painter: ScanIllustrationPainter()),
          ),
          const Spacer(flex: 2),
          Text(
            'Scan & Identify',
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
            'Simply take a photo or upload an image of any plant leaf. Our AI will identify diseases and provide treatment recommendations.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF757575),
              height: 1.6,
            ),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ref.read(onboardingProvider.notifier).complete();
                Navigator.pushReplacementNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF1B5E20).withValues(alpha: 0.3),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
