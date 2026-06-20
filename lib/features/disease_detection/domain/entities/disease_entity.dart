class DiseaseEntity {
  final String name;
  final double confidence;
  final String description;
  final List<String> preventionSteps;
  final String severity;
  final String scientificName;

  const DiseaseEntity({
    required this.name,
    required this.confidence,
    required this.description,
    required this.preventionSteps,
    required this.severity,
    this.scientificName = '',
  });

  bool get isHealthy => name.toLowerCase() == 'healthy';
}
