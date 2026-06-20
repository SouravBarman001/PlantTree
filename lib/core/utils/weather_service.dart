import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final String cityName;
  final double temperature;
  final String condition;
  final double windSpeed; // in m/s (OpenWeather default)
  final String sprayingCondition;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.sprayingCondition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>?;
    final weatherList = json['weather'] as List<dynamic>?;
    final wind = json['wind'] as Map<String, dynamic>?;

    final temp = (main?['temp'] as num?)?.toDouble() ?? 24.0;
    final city = json['name'] as String? ?? 'Your location';
    final cond = (weatherList != null && weatherList.isNotEmpty)
        ? (weatherList[0]['main'] as String? ?? 'Clear')
        : 'Clear';
    
    // Wind speed is in m/s, convert to km/h: speed * 3.6
    final speedMs = (wind?['speed'] as num?)?.toDouble() ?? 2.0;
    final speedKmh = speedMs * 3.6;

    // Dynamically calculate spraying conditions
    String sprayCond = "Excellent";
    if (cond.toLowerCase().contains("rain") || cond.toLowerCase().contains("drizzle") || cond.toLowerCase().contains("thunderstorm")) {
      sprayCond = "Poor (Rain)";
    } else if (speedKmh > 15.0) {
      sprayCond = "Poor (Windy)";
    } else if (speedKmh > 8.0) {
      sprayCond = "Moderate";
    }

    return WeatherData(
      cityName: city,
      temperature: temp,
      condition: cond,
      windSpeed: speedKmh,
      sprayingCondition: sprayCond,
    );
  }
}

class WeatherService {
  static const String _apiKey = 'a33e9ca69869689066f9a776a3622a24';

  Future<WeatherData?> getLocalWeather() async {
    try {
      // 1. Check/Request location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Location services are disabled.");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("Location permissions are denied.");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("Location permissions are permanently denied.");
        return null;
      }

      // 2. Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );

      // 3. Query OpenWeather API
      final url = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(decoded);
      } else {
        debugPrint("Failed to fetch weather: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error in WeatherService: $e");
    }
    return null;
  }
}
