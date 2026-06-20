import 'package:flutter/material.dart';

class OnboardingPage {
  final String title;
  final String description;
  final Widget illustration;
  final bool showSkip;
  final String? actionLabel;
  final VoidCallback? onAction;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.illustration,
    this.showSkip = true,
    this.actionLabel,
    this.onAction,
  });
}
