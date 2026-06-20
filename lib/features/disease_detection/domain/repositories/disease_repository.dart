import 'dart:io';

import '../entities/disease_entity.dart';

abstract class DiseaseRepository {
  Future<DiseaseEntity> detectDisease(File imageFile);
}
