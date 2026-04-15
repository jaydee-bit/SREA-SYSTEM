import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────
// WeatherData model
// ─────────────────────────────────────────────────────────────
class WeatherData {
  final String cityName;
  final String province;
  final double tempCelsius;
  final double feelsLike;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final String barangay; // set from user profile

  const WeatherData({
    required this.cityName,
    required this.province,
    required this.tempCelsius,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    this.barangay = '',
  });

  String get tempDisplay => '${tempCelsius.round()}°C';
  String get feelsLikeDisplay => 'Feels like ${feelsLike.round()}°C';

  String get weatherEmoji {
    final id = iconCode;
    if (id.startsWith('01')) return '☀️';
    if (id.startsWith('02')) return '⛅';
    if (id.startsWith('03') || id.startsWith('04')) return '☁️';
    if (id.startsWith('09') || id.startsWith('10')) return '🌧️';
    if (id.startsWith('11')) return '⛈️';
    if (id.startsWith('13')) return '❄️';
    if (id.startsWith('50')) return '🌫️';
    return '🌤️';
  }

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  // Alert level based on weather condition
  String get alertLevel {
    final desc = description.toLowerCase();
    if (desc.contains('thunderstorm') || desc.contains('tornado')) {
      return 'critical';
    }
    if (desc.contains('heavy rain') ||
        desc.contains('extreme') ||
        desc.contains('storm')) {
      return 'high';
    }
    if (desc.contains('rain') || desc.contains('drizzle')) return 'medium';
    return 'none';
  }

  factory WeatherData.fromJson(Map<String, dynamic> json,
      {String barangay = ''}) {
    return WeatherData(
      cityName: json['name'] ?? 'San Rafael',
      province: 'Bulacan, Philippines',
      tempCelsius: (json['main']['temp'] as num).toDouble() - 273.15,
      feelsLike: (json['main']['feels_like'] as num).toDouble() - 273.15,
      description: _capitalize(json['weather'][0]['description'] ?? ''),
      iconCode: json['weather'][0]['icon'] ?? '01d',
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      barangay: barangay,
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

// ─────────────────────────────────────────────────────────────
// WeatherService — fetches from OpenWeatherMap
// ─────────────────────────────────────────────────────────────
class WeatherService {
  // TODO: Replace with your actual OpenWeatherMap API key
  // Get one free at: https://openweathermap.org/api
  static const String _apiKey = '5ed7ee49d11307675107d9f221823446';

  // San Rafael, Bulacan coordinates
  static const double _lat = 15.0153;
  static const double _lon = 120.9996;

  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// Fetches current weather for San Rafael, Bulacan
  static Future<WeatherData> fetchWeather({String barangay = ''}) async {
    final uri = Uri.parse(
      '$_baseUrl?lat=$_lat&lon=$_lon&appid=$_apiKey',
    );

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json, barangay: barangay);
      } else if (response.statusCode == 401) {
        throw WeatherException('Invalid API key. Please check your OpenWeatherMap API key.');
      } else {
        throw WeatherException('Failed to fetch weather (${response.statusCode})');
      }
    } on WeatherException {
      rethrow;
    } catch (e) {
      throw WeatherException('No internet connection or request timed out.');
    }
  }
}

class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => message;
}
