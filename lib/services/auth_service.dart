import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class AuthService {
  final _dio = ApiClient.instance.dio;
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    print('[AUTH] REGISTER request → email: $email, name: $name, role: $role');
    try {
      final response = await _dio.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      print('[AUTH] REGISTER response → ${response.statusCode}: ${response.data}');
      await _saveTokens(response.data);
      return response.data['user'] as Map<String, dynamic>;
    } catch (e) {
      print('[AUTH] REGISTER error → $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('[AUTH] LOGIN request → email: $email');
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      print('[AUTH] LOGIN response → ${response.statusCode}: ${response.data}');
      await _saveTokens(response.data);
      return response.data['user'] as Map<String, dynamic>;
    } catch (e) {
      print('[AUTH] LOGIN error → $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'accessToken');
    return token != null;
  }

  Future<String?> getRole() async {
    return _storage.read(key: 'role');
  }

  Future<String?> getUserId() async {
    return _storage.read(key: 'userId');
  }

  Future<String?> getUserName() async {
    return _storage.read(key: 'userName');
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await Future.wait([
      _storage.write(key: 'accessToken', value: data['accessToken'] as String),
      _storage.write(key: 'refreshToken', value: data['refreshToken'] as String),
      _storage.write(key: 'role', value: data['user']['role'] as String),
      _storage.write(key: 'userId', value: data['user']['_id'] as String),
      _storage.write(key: 'userName', value: data['user']['name'] as String),
    ]);
  }
}
