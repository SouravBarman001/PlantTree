import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;

  const ConfidenceIndicator({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (confidence * 100).toInt();
    final color = _getColor(confidence);

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: confidence,
              strokeWidth: 10,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                'Confidence',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF388E3C);
    if (confidence >= 0.6) return const Color(0xFFFF8F00);
    return const Color(0xFFD32F2F);
  }
}
