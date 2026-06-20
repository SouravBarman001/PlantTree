import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/locale_provider.dart';
import '../providers/disease_provider.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  File? _pickedImage;
  String _selectedCrop = 'Tomato';

  final List<String> _supportedCrops = const [
    'Apple',
    'Pepper',
    'Corn',
    'Grape',
    'Peach',
    'Strawberry',
    'Tomato',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      ref.read(diseaseDetectionProvider.notifier).setSelectedImage(_pickedImage!);
    }
  }

  Future<void> _runScan() async {
    if (_pickedImage == null) return;

    await ref
        .read(diseaseDetectionProvider.notifier)
        .detectDisease(_pickedImage!, _selectedCrop);

    if (!mounted) return;
    
    final state = ref.read(diseaseDetectionProvider);
    if (state.status == DiseaseDetectionStatus.success) {
      Navigator.pushNamed(context, '/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(diseaseDetectionProvider);
    final isScanning = state.status == DiseaseDetectionStatus.loading;

    return Scaffold(
      appBar: AppBar(title: Text(ref.tr('scan_leaf'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isScanning ? _pulseAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: _buildImagePreview(_pickedImage, isScanning),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isScanning ? ref.tr('analyzing_leaf') : (_pickedImage == null ? ref.tr('position_leaf') : ref.tr('leaf_loaded')),
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isScanning
                    ? ref.tr('ai_examining')
                    : (_pickedImage == null
                        ? ref.tr('take_photo_prompt')
                        : ref.tr('select_crop_prompt')),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              if (isScanning) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 32),
              ] else if (_pickedImage == null) ...[
                _buildButton(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: ref.tr('take_photo'),
                  isPrimary: true,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 16),
                _buildButton(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: ref.tr('upload_gallery'),
                  isPrimary: false,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ] else ...[
                // Image is loaded, show crop dropdown selection & Scan button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('crop_type'),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? theme.cardColor
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCrop,
                          isExpanded: true,
                          items: _supportedCrops.map((String crop) {
                            return DropdownMenuItem<String>(
                              value: crop,
                              child: Text(ref.tr(crop), style: GoogleFonts.inter(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCrop = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildButton(
                  context,
                  icon: Icons.search_rounded,
                  label: ref.tr('scan_leaf'),
                  isPrimary: true,
                  onTap: _runScan,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _pickedImage = null;
                    });
                    ref.read(diseaseDetectionProvider.notifier).reset();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(ref.tr('change_photo')),
                ),
                if (state.status == DiseaseDetectionStatus.failure && state.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.red[800], size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _getErrorMessage(state.errorMessage!),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.red[800],
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(File? image, bool isScanning) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 240,
      height: 300, // Make the container larger from bottom side (taller)
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: isScanning ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: isScanning ? 5 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: image != null
            ? Image.file(image, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ref.tr('leaf_preview'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label),
            ),
    );
  }

  String _getErrorMessage(String original) {
    if (original.startsWith('Plant mismatch!')) {
      final isBn = ref.read(localeProvider) == 'bn';
      if (isBn) {
        final transSelected = ref.tr(_selectedCrop);
        final startIdx = original.indexOf('"');
        final endIdx = original.lastIndexOf('"');
        String transDetected = '';
        if (startIdx != -1 && endIdx != -1) {
          final rawDetected = original.substring(startIdx + 1, endIdx);
          transDetected = ref.tr(rawDetected);
        }
        return 'উদ্ভিদের অমিল! আপনি নির্বাচন করেছেন $transSelected, কিন্তু এআই সনাক্ত করেছে "$transDetected"। অনুগ্রহ করে আপনার ফসল নির্বাচন যাচাই করে আবার চেষ্টা করুন।';
      }
    }
    return original;
  }
}
