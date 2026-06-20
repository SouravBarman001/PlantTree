import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/locale_provider.dart';
import '../providers/disease_provider.dart';
import '../widgets/confidence_indicator.dart';
import '../widgets/prevention_step_card.dart';
import '../widgets/severity_indicator.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diseaseDetectionProvider);

    if (state.status != DiseaseDetectionStatus.success ||
        state.disease == null) {
      return Scaffold(
        appBar: AppBar(title: Text(ref.tr('results'))),
        body: Center(child: Text(ref.tr('no_results'))),
      );
    }

    final disease = state.disease!;

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr('detection_results')),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(diseaseDetectionProvider.notifier).reset();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDiseaseHeader(context, ref, disease),
            const SizedBox(height: 24),
            _buildConfidenceSection(context, ref, disease),
            const SizedBox(height: 24),
            _buildDescriptionSection(context, ref, disease),
            const SizedBox(height: 24),
            _buildPreventionSection(context, ref, disease),
            const SizedBox(height: 32),
            _buildScanAgainButton(context, ref),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseHeader(BuildContext context, WidgetRef ref, dynamic disease) {
    final isHealthy = disease.isHealthy;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHealthy
              ? [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]
              : [const Color(0xFFD32F2F), const Color(0xFFEF5350)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (isHealthy ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F))
                    .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHealthy
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ref.tr(disease.name),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (disease.scientificName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              disease.scientificName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SeverityIndicator(severity: disease.severity),
        ],
      ),
    );
  }

  Widget _buildConfidenceSection(BuildContext context, WidgetRef ref, dynamic disease) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            ref.tr('confidence_score'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ConfidenceIndicator(confidence: disease.confidence),
          const SizedBox(height: 16),
          Text(
            _getConfidenceDescription(ref, disease.confidence),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, WidgetRef ref, dynamic disease) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                ref.tr('description'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ref.tr(disease.description),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionSection(BuildContext context, WidgetRef ref, dynamic disease) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.shield_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              ref.tr('prevention_steps'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...disease.preventionSteps.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PreventionStepCard(
              stepNumber: entry.key + 1,
              stepText: ref.tr(entry.value),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildScanAgainButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ref.read(diseaseDetectionProvider.notifier).reset();
          Navigator.pushNamed(context, '/scan');
        },
        icon: const Icon(Icons.camera_alt_rounded),
        label: Text(ref.tr('scan_another')),
      ),
    );
  }

  String _getConfidenceDescription(WidgetRef ref, double confidence) {
    if (confidence >= 0.9) {
      return ref.tr('very_high_conf');
    } else if (confidence >= 0.75) {
      return ref.tr('high_conf');
    } else if (confidence >= 0.5) {
      return ref.tr('mod_conf');
    } else {
      return ref.tr('low_conf');
    }
  }
}
