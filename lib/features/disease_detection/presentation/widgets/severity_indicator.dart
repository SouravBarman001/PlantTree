import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/locale_provider.dart';

class SeverityIndicator extends ConsumerWidget {
  final String severity;

  const SeverityIndicator({super.key, required this.severity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getColor(severity);
    final translatedSeverity = ref.tr(severity.toLowerCase());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '${ref.tr('severity')}: $translatedSeverity',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFFF5252);
      case 'moderate':
        return const Color(0xFFFFD740);
      case 'none':
        return const Color(0xFF69F0AE);
      default:
        return Colors.white;
    }
  }
}
