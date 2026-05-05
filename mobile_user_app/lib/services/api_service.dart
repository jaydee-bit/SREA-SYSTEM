import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cross_file/cross_file.dart';
import 'package:shared_preferences/shared_preferences.dart'; // optional fallback

class ApiService {
  static const String baseImageUrl = 'http://localhost:8080';
  static const String baseUrl = '$baseImageUrl/api';

  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  // Explicit Android options for better persistence
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          print(
            '📦 Token from secure storage: ${token != null ? 'Exists' : 'NULL'}',
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            print('⚠️ 401 Unauthorized – clearing token');
            await _storage.delete(key: 'auth_token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ==================== AUTHENTICATION ====================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password, 'client_type': 'user'},
      );
      final token = response.data['token'];
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
        print('🔐 Token saved after login');
      }
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
      print('🗑️ Token deleted on logout');
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final response = await _dio.get('/user');
    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/register', data: data);
    final token = response.data['token'];
    if (token != null) {
      await _storage.write(key: 'auth_token', value: token);
      print('🔐 Token saved after registration');
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

  // ==================== USER PROFILE ====================
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/user/profile', data: data);
    return response.data;
  }

  // Dedicated profile picture upload – returns absolute URL
  Future<String> uploadProfileImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });
    final response = await _dio.post(
      '/user/upload-profile-image',
      data: formData,
    );
    return response.data['profile_image'];
  }

  // Generic image upload for incidents (returns relative path)
  Future<String> uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });
    final response = await _dio.post('/user/upload-image', data: formData);
    return response.data['photo_path'];
  }

  // Helper – convert relative path to absolute URL
  String? getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$baseImageUrl$normalizedPath';
  }

  // ==================== INCIDENTS ====================
  Future<List<dynamic>> getMyIncidents() async {
    final response = await _dio.get('/user/incidents');
    return response.data;
  }

  Future<Map<String, dynamic>> createIncident(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/user/incidents', data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('ERROR DATA: ${e.response?.data}');
      print('ERROR STATUS: ${e.response?.statusCode}');
      rethrow;
    }
  }

  // ==================== EMERGENCY CALLS ====================
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

  // ==================== ALERTS, ANNOUNCEMENTS, TRAFFIC ====================
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

  // ==================== IMAGE COMPRESSION ====================
  Future<File> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70,
      );
      if (result == null) return file;
      return File(result.path);
    } catch (e) {
      return file;
    }
  }
}
