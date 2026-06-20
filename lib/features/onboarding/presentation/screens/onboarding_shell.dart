import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/onboarding_provider.dart';
// import 'notification_onboarding_screen.dart';
import 'scan_onboarding_screen.dart';
import 'welcome_onboarding_screen.dart';

class OnboardingShell extends ConsumerStatefulWidget {
  const OnboardingShell({super.key});

  @override
  ConsumerState<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends ConsumerState<OnboardingShell> {
  late PageController _pageController;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = [
      const WelcomeOnboardingScreen(),
      const ScanOnboardingScreen(),
      // const NotificationOnboardingScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).start();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(onboardingProvider.notifier).goToPage(index);
  }

  void _nextPage() {
    final state = ref.read(onboardingProvider);
    if (state.currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      ref.read(onboardingProvider.notifier).nextPage(_pages.length);
    }
  }

  void _skip() {
    ref.read(onboardingProvider.notifier).complete();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (state.currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 48),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: _pages,
              ),
            ),
            _buildBottomBar(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, OnboardingState state) {
    final theme = Theme.of(context);
    final isLastPage = state.currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isLastPage)
            TextButton(
              onPressed: _skip,
              child: Text(
                'Skip',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            )
          else
            const SizedBox(width: 80),
          _buildPageIndicator(state),
          isLastPage
              ? const SizedBox(width: 80)
              : TextButton(
                  onPressed: _nextPage,
                  child: Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(OnboardingState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_pages.length, (index) {
        final isActive = index == state.currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
