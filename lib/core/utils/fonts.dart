import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle displayLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.2,
    );
  }

  static TextStyle displayMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.2,
    );
  }

  static TextStyle headlineLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.3,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.3,
    );
  }

  static TextStyle titleLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.4,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.4,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.5,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.4,
    );
  }

  static TextStyle labelLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.4,
    );
  }

  static TextStyle labelMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.4,
    );
  }

  static TextStyle buttonText(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );
  }
}
