import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/tflite_disease_datasource.dart';
import '../../data/repositories/disease_repository_impl.dart';
import '../../domain/entities/disease_entity.dart';

enum DiseaseDetectionStatus { initial, loading, success, failure }

class DiseaseDetectionState {
  final DiseaseDetectionStatus status;
  final DiseaseEntity? disease;
  final String? errorMessage;
  final File? selectedImage;

  const DiseaseDetectionState({
    this.status = DiseaseDetectionStatus.initial,
    this.disease,
    this.errorMessage,
    this.selectedImage,
  });

  DiseaseDetectionState copyWith({
    DiseaseDetectionStatus? status,
    DiseaseEntity? disease,
    String? errorMessage,
    File? selectedImage,
  }) {
    return DiseaseDetectionState(
      status: status ?? this.status,
      disease: disease ?? this.disease,
      errorMessage: errorMessage,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

class DiseaseDetectionNotifier extends StateNotifier<DiseaseDetectionState> {
  final DiseaseRepositoryImpl _repository;

  DiseaseDetectionNotifier(this._repository)
    : super(const DiseaseDetectionState());

  Future<void> detectDisease(File imageFile, String selectedCrop) async {
    state = state.copyWith(
      status: DiseaseDetectionStatus.loading,
      selectedImage: imageFile,
      errorMessage: null,
    );

    try {
      final disease = await _repository.detectDisease(imageFile);
      
      final detectedName = disease.name.toLowerCase();
      final targetCrop = selectedCrop.toLowerCase();
      
      bool isMatch = false;
      if (detectedName.contains(targetCrop)) {
        isMatch = true;
      } else if (targetCrop == 'pepper' && detectedName.contains('pepper bell')) {
        isMatch = true;
      }
      
      if (isMatch) {
        state = state.copyWith(
          status: DiseaseDetectionStatus.success,
          disease: disease,
        );
      } else {
        state = state.copyWith(
          status: DiseaseDetectionStatus.failure,
          errorMessage: 'Plant mismatch! You selected $selectedCrop, but the AI detected "$detectedName". Please verify your crop selection and try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: DiseaseDetectionStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const DiseaseDetectionState();
  }

  void setSelectedImage(File image) {
    state = state.copyWith(selectedImage: image);
  }
}

final diseaseRepositoryProvider = Provider<DiseaseRepositoryImpl>((ref) {
  return DiseaseRepositoryImpl(datasource: TFLiteDiseaseDatasource());
});

final diseaseDetectionProvider =
    StateNotifierProvider<DiseaseDetectionNotifier, DiseaseDetectionState>((
      ref,
    ) {
      final repository = ref.watch(diseaseRepositoryProvider);
      return DiseaseDetectionNotifier(repository);
    });
