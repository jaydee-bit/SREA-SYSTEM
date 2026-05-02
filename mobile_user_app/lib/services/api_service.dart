import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:8080/api'; // Change to your actual URL
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'auth_token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password, 'client_type': 'user'},
      );
      final token = response.data['token'];
      await _storage.write(key: 'auth_token', value: token);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final response = await _dio.get('/user');
    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/register', data: data);
    // Store token if returned (optional: you may want to auto-login)
    final token = response.data['token'];
    if (token != null) {
      await _storage.write(key: 'auth_token', value: token);
    }
    return response.data;
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword(
    String email,
    String token,
    String password,
  ) async {
    await _dio.post(
      '/auth/reset-password',
      data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': password,
      },
    );
  }

  // User endpoints
  Future<List<dynamic>> getAlerts() async {
    final response = await _dio.get('/user/alerts');
    return response.data;
  }

  Future<List<dynamic>> getAnnouncements() async {
    final response = await _dio.get('/user/announcements');
    return response.data;
  }

  Future<List<dynamic>> getTrafficAdvisories() async {
    final response = await _dio.get('/user/traffic');
    return response.data;
  }

  Future<List<dynamic>> getMyIncidents() async {
    final response = await _dio.get('/user/incidents');
    return response.data;
  }

  Future<Map<String, dynamic>> createIncident(Map<String, dynamic> data) async {
    final response = await _dio.post('/user/incidents', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> createEmergencyCall(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post('/user/emergency-calls', data: data);
    return response.data;
  }

  Future<List<dynamic>> getEmergencyCalls() async {
    final response = await _dio.get('/user/emergency-calls');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/user/profile', data: data);
    return response.data;
  }
}
