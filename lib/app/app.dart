import 'package:flutter/material.dart';

import '../core/utils/theme.dart';
import '../features/disease_detection/presentation/screens/home_screen.dart';
import '../features/disease_detection/presentation/screens/scan_screen.dart';
import '../features/disease_detection/presentation/screens/results_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_shell.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

class PlantTreeApp extends StatelessWidget {
  const PlantTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Tree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingShell(),
        '/home': (context) => const HomeScreen(),
        '/scan': (context) => const ScanScreen(),
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}
