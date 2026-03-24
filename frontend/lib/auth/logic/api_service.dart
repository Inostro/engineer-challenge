import 'package:dio/dio.dart';
import 'package:template/models/auth_response.dart';
import 'package:template/models/user.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api', // Change to your backend URL
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        // Parse response based on your backend
        return AuthResponse(
          user: User(
            id: response.data['user']['id'],
            email: response.data['user']['email'],
            username: response.data['user']['username'],
          ),
          token: response.data['token'],
        );
      }
      throw Exception('Login failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
  
  Future<AuthResponse> register(String email, String password, String username) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'username': username,
      });
      
      if (response.statusCode == 201) {
        return AuthResponse(
          user: User(
            id: response.data['user']['id'],
            email: response.data['user']['email'],
            username: response.data['user']['username'],
          ),
          token: response.data['token'],
        );
      }
      throw Exception('Registration failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
  
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send reset email');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
  
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
      
      if (response.statusCode != 200) {
        throw Exception('Failed to reset password');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
}