import 'dart:io';

import '../datasources/tflite_disease_datasource.dart';
import '../../domain/entities/disease_entity.dart';
import '../../domain/repositories/disease_repository.dart';

class DiseaseRepositoryImpl implements DiseaseRepository {
  final TFLiteDiseaseDatasource _datasource;

  DiseaseRepositoryImpl({TFLiteDiseaseDatasource? datasource})
      : _datasource = datasource ?? TFLiteDiseaseDatasource();

  bool get isModelLoaded => _datasource.isModelLoaded;

  @override
  Future<DiseaseEntity> detectDisease(File imageFile) async {
    try {
      final result = await _datasource.detect(imageFile);
      return result;
    } catch (e) {
      throw Exception('Failed to detect disease: $e');
    }
  }
}
