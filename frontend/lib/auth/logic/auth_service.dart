import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:template/auth/logic/api_service.dart';
import 'package:template/models/user.dart';

class AuthService {
  final ApiService _apiService = GetIt.instance<ApiService>();
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  
  // Stream controllers for auth state
  final _authStateController = StreamController<User?>.broadcast();
  Stream<User?> get authState => _authStateController.stream;
  
  User? _currentUser;
  
  AuthService() {
    _loadUser();
  }
  
  Future<void> _loadUser() async {
    final token = _prefs.getString('auth_token');
    final userId = _prefs.getString('user_id');
    final userEmail = _prefs.getString('user_email');
    
    if (token != null && userId != null && userEmail != null) {
      _currentUser = User(
        id: userId,
        email: userEmail,
        username: _prefs.getString('user_username'),
      );
      _authStateController.add(_currentUser);
    }
  }
  
  Future<User> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      
      // Save to shared preferences
      await _prefs.setString('auth_token', response.token);
      await _prefs.setString('user_id', response.user.id);
      await _prefs.setString('user_email', response.user.email);
      if (response.user.username != null) {
        await _prefs.setString('user_username', response.user.username!);
      }
      
      _currentUser = response.user;
      _authStateController.add(_currentUser);
      
      return response.user;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<User> register(String email, String password, String username) async {
    try {
      final response = await _apiService.register(email, password, username);
      
      // Save to shared preferences
      await _prefs.setString('auth_token', response.token);
      await _prefs.setString('user_id', response.user.id);
      await _prefs.setString('user_email', response.user.email);
      await _prefs.setString('user_username', response.user.username!);
      
      _currentUser = response.user;
      _authStateController.add(_currentUser);
      
      return response.user;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> forgotPassword(String email) async {
    await _apiService.forgotPassword(email);
  }
  
  Future<void> logout() async {
    await _prefs.clear();
    _currentUser = null;
    _authStateController.add(null);
  }
  
  void dispose() {
    _authStateController.close();
  }
}