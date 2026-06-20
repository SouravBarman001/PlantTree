import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlideUp;
  late Animation<double> _textOpacity;
  late Animation<double> _screenFadeOut;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textSlideUp = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _screenFadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _runAnimations();
  }

  Future<void> _runAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    await _fadeController.forward();

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      if (onboardingCompleted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _screenFadeOut,
      builder: (context, child) {
        return Opacity(
          opacity: _screenFadeOut.value,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F5E9),
                    Color(0xFFC8E6C9),
                    Color(0xFFA5D6A7),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlideUp.value),
                          child: Column(
                            children: [
                              Text(
                                'Plant Tree',
                                style: GoogleFonts.poppins(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Detect. Protect. Grow.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.darkGreen.withValues(
                                    alpha: 0.6,
                                  ),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textOpacity.value,
                          child: Text(
                            'Powered by AI',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.darkGreen.withValues(alpha: 0.4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
