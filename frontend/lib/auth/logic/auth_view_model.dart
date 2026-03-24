import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';
import 'package:template/auth/logic/auth_service.dart';
import 'package:template/router/navigation_service.dart';

class AuthViewModel {
  final AuthService _authService = GetIt.instance<AuthService>();
  final NavigationService _navigationService = GetIt.instance<NavigationService>();
  
  final _stateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get state => _stateController.stream;
  
  AuthState _currentState = const AuthState();
  
  AuthViewModel() {
    _stateController.add(_currentState);
  }
  
  void togglePasswordVisibility() {
    _currentState = _currentState.copyWith(
      isPasswordVisible: !_currentState.isPasswordVisible,
    );
    _stateController.add(_currentState);
  }
  
  Future<void> login(BuildContext context, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _emitError('Please fill in all fields');
      return;
    }
    
    _emitLoading();
    
    try {
      // ignore: unused_local_variable
      final user = await _authService.login(email, password);
      _emitSuccess();
      _navigationService.navigateToHome(context);
    } catch (e) {
      _emitError(e.toString());
    }
  }
  
  void navigateToRegister(BuildContext context) {
    _navigationService.navigateToRegister(context);
  }
  
  void navigateToForgotPassword(BuildContext context) {
    _navigationService.navigateToForgotPassword(context);
  }
  
  void _emitLoading() {
    _currentState = _currentState.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );
    _stateController.add(_currentState);
  }
  
  void _emitSuccess() {
    _currentState = _currentState.copyWith(
      status: AuthStatus.success,
      errorMessage: null,
    );
    _stateController.add(_currentState);
  }
  
  void _emitError(String message) {
    _currentState = _currentState.copyWith(
      status: AuthStatus.error,
      errorMessage: message,
    );
    _stateController.add(_currentState);
  }
  
  void dispose() {
    _stateController.close();
  }
}

enum AuthStatus { initial, loading, success, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final bool isPasswordVisible;
  
  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.isPasswordVisible = false,
  });
  
  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isPasswordVisible,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
  
  @override
  List<Object?> get props => [status, errorMessage, isPasswordVisible];
}