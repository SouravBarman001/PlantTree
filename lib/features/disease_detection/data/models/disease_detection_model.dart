import '../../domain/entities/disease_entity.dart';

class DiseaseDetectionModel extends DiseaseEntity {
  final DateTime detectedAt;

  const DiseaseDetectionModel({
    required super.name,
    required super.confidence,
    required super.description,
    required super.preventionSteps,
    required super.severity,
    super.scientificName,
    required this.detectedAt,
  });

  factory DiseaseDetectionModel.fromJson(Map<String, dynamic> json) {
    return DiseaseDetectionModel(
      name: json['name'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      preventionSteps:
          (json['prevention_steps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      severity: json['severity'] as String? ?? 'Unknown',
      scientificName: json['scientific_name'] as String? ?? '',
      detectedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'description': description,
      'prevention_steps': preventionSteps,
      'severity': severity,
      'scientific_name': scientificName,
      'detected_at': detectedAt.toIso8601String(),
    };
  }
}
