import 'dart:io';

import '../entities/disease_entity.dart';
import '../repositories/disease_repository.dart';

class DetectDiseaseUseCase {
  final DiseaseRepository _repository;

  DetectDiseaseUseCase(this._repository);

  Future<DiseaseEntity> call(File imageFile) {
    return _repository.detectDisease(imageFile);
  }
}
