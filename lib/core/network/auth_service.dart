import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../../shared/models/all_models.dart';

class AuthService {
  final _dio = ApiClient.instance.dio;
  final _storage = const FlutterSecureStorage();

  // POST /api/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    final response = AuthResponse.fromJson(res.data);
    await _storage.write(key: 'sanctum_token', value: response.token);
    return response;
  }

  // POST /api/register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    final response = AuthResponse.fromJson(res.data);
    await _storage.write(key: 'sanctum_token', value: response.token);
    return response;
  }

  // POST /api/logout
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } finally {
      await _storage.delete(key: 'sanctum_token');
    }
  }

  // GET /api/me
  Future<UserModel> me() async {
    final res = await _dio.get('/me');
    return UserModel.fromJson(res.data['user'] ?? res.data);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'sanctum_token');
    return token != null && token.isNotEmpty;
  }
}
