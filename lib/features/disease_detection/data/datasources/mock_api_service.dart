import 'dart:io';
import 'dart:math';

import '../models/disease_detection_model.dart';

class MockDiseaseDatasource {
  static final List<Map<String, dynamic>> _mockDiseases = [
    {
      'name': 'Healthy Leaf',
      'confidence': 0.96,
      'description':
          'Your plant appears to be in excellent health! The leaves show no signs of disease, discoloration, or pest damage. Continue with your current care routine.',
      'prevention_steps': [
        'Maintain regular watering schedule',
        'Ensure adequate sunlight exposure',
        'Monitor for any changes periodically',
      ],
      'severity': 'None',
      'scientific_name': 'Healthy',
    },
    {
      'name': 'Powdery Mildew',
      'confidence': 0.89,
      'description':
          'Powdery mildew is a common fungal disease that appears as white powdery spots on leaves and stems. It thrives in warm, dry conditions with high humidity.',
      'prevention_steps': [
        'Improve air circulation around plants',
        'Avoid overhead watering',
        'Apply neem oil or fungicide spray',
        'Remove affected leaves promptly',
        'Ensure proper spacing between plants',
      ],
      'severity': 'Moderate',
      'scientific_name': 'Erysiphales',
    },
    {
      'name': 'Leaf Spot Disease',
      'confidence': 0.84,
      'description':
          'Leaf spot is caused by various fungal or bacterial pathogens. It manifests as brown or black spots with yellow halos on the leaf surface.',
      'prevention_steps': [
        'Remove and destroy infected leaves',
        'Avoid wetting foliage when watering',
        'Apply copper-based fungicide',
        'Mulch around the base of plants',
        'Rotate crops if applicable',
      ],
      'severity': 'Moderate',
      'scientific_name': 'Mycosphaerella',
    },
    {
      'name': 'Bacterial Blight',
      'confidence': 0.91,
      'description':
          'Bacterial blight causes water-soaked lesions that turn brown and necrotic. The disease spreads rapidly in warm, wet conditions and can devastate crops.',
      'prevention_steps': [
        'Remove and burn infected plant material',
        'Use disease-free seeds and transplants',
        'Apply copper-based bactericide',
        'Improve drainage in the field',
        'Practice crop rotation with non-host plants',
      ],
      'severity': 'High',
      'scientific_name': 'Xanthomonas campestris',
    },
    {
      'name': 'Rust Disease',
      'confidence': 0.87,
      'description':
          'Rust is a fungal disease characterized by orange, yellow, or brown pustules on leaf undersides. Severe infections can cause leaf drop and reduced vigor.',
      'prevention_steps': [
        'Plant resistant varieties when available',
        'Apply sulfur-based fungicide',
        'Remove infected plant debris',
        'Ensure adequate plant nutrition',
        'Avoid overhead irrigation',
      ],
      'severity': 'Moderate',
      'scientific_name': 'Pucciniales',
    },
  ];

  Future<DiseaseDetectionModel> detect(File imageFile) async {
    await Future.delayed(const Duration(seconds: 2));
    final random = Random();
    final disease = _mockDiseases[random.nextInt(_mockDiseases.length)];
    return DiseaseDetectionModel.fromJson(disease);
  }
}
