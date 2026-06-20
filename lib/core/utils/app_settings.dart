class AppSettings {
  AppSettings._();

  static const String appName = 'Plant Tree';
  static const String appVersion = '1.0.0';

  static const String baseUrl = 'http://10.0.2.2:5000';
  static const String detectEndpoint = '/api/detect';
  static const String healthEndpoint = '/api/health';

  static const String apiBaseUrl = '$baseUrl$detectEndpoint';

  static const Duration mockApiDelay = Duration(seconds: 2);
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxImageWidth = 1024;
  static const int imageQuality = 85;

  static const int maxScanHistory = 50;

  static const String placeholderPlantImage =
      'assets/images/placeholder_plant.png';
}
