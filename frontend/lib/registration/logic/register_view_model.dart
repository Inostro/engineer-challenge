import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';
import 'package:template/auth/logic/auth_service.dart';
import 'package:template/router/navigation_service.dart';

enum RegisterStatus { initial, loading, success, error }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    isPasswordVisible,
    isConfirmPasswordVisible,
  ];
}

class RegisterViewModel {
  final AuthService _authService = GetIt.instance<AuthService>();
  final NavigationService _navigationService =
      GetIt.instance<NavigationService>();

  final _stateController = StreamController<RegisterState>.broadcast();
  Stream<RegisterState> get state => _stateController.stream;

  RegisterState _currentState = const RegisterState();

  RegisterViewModel() {
    _stateController.add(_currentState);
  }

  void togglePasswordVisibility() {
    _currentState = _currentState.copyWith(
      isPasswordVisible: !_currentState.isPasswordVisible,
    );
    _stateController.add(_currentState);
  }

  void toggleConfirmPasswordVisibility() {
    _currentState = _currentState.copyWith(
      isConfirmPasswordVisible: !_currentState.isConfirmPasswordVisible,
    );
    _stateController.add(_currentState);
  }

  Future<void> register(
    BuildContext context,
    String email,
    String password,
    String confirmPassword,
    String username,
  ) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      _emitError('Please fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      _emitError('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      _emitError('Password must be at least 6 characters');
      return;
    }

    _emitLoading();

    try {
      // ignore: unused_local_variable
      final user = await _authService.register(email, password, username);
      _emitSuccess();
      _navigationService.navigateToHome(context);
    } catch (e) {
      _emitError(e.toString());
    }
  }

  void goBack(BuildContext context) {
    _navigationService.goBack(context);
  }

  void _emitLoading() {
    _currentState = _currentState.copyWith(
      status: RegisterStatus.loading,
      errorMessage: null,
    );
    _stateController.add(_currentState);
  }

  void _emitSuccess() {
    _currentState = _currentState.copyWith(
      status: RegisterStatus.success,
      errorMessage: null,
    );
    _stateController.add(_currentState);
  }

  void _emitError(String message) {
    _currentState = _currentState.copyWith(
      status: RegisterStatus.error,
      errorMessage: message,
    );
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
