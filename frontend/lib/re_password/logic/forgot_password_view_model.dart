import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';
import 'package:template/auth/logic/auth_service.dart';
import 'package:template/router/navigation_service.dart';

enum ForgotPasswordStatus { initial, loading, success, error }

class ForgotPasswordState extends Equatable {
  final ForgotPasswordStatus status;
  final String? errorMessage;
  final String? successMessage;

  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}

class ForgotPasswordViewModel {
  final AuthService _authService = GetIt.instance<AuthService>();
  final NavigationService _navigationService =
      GetIt.instance<NavigationService>();

  final _stateController = StreamController<ForgotPasswordState>.broadcast();
  Stream<ForgotPasswordState> get state => _stateController.stream;

  ForgotPasswordState _currentState = const ForgotPasswordState();

  ForgotPasswordViewModel() {
    _stateController.add(_currentState);
  }

  Future<void> sendResetEmail(BuildContext context, String email) async {
    if (email.isEmpty) {
      _emitError('Please enter your email');
      return;
    }

    if (!email.contains('@')) {
      _emitError('Please enter a valid email');
      return;
    }

    _emitLoading();

    try {
      await _authService.forgotPassword(email);
      _emitSuccess();

      // Show success message
      _currentState = _currentState.copyWith(
        status: ForgotPasswordStatus.success,
        successMessage: 'Password reset email sent! Check your inbox.',
      );
      _stateController.add(_currentState);

      // Navigate back after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _navigationService.goBack(context);
      });
    } catch (e) {
      _emitError(e.toString());
    }
  }

  void goBack(BuildContext context) {
    _navigationService.goBack(context);
  }

  void _emitLoading() {
    _currentState = _currentState.copyWith(
      status: ForgotPasswordStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    _stateController.add(_currentState);
  }

  void _emitSuccess() {
    _currentState = _currentState.copyWith(
      status: ForgotPasswordStatus.success,
      errorMessage: null,
    );
    _stateController.add(_currentState);
  }

  void _emitError(String message) {
    _currentState = _currentState.copyWith(
      status: ForgotPasswordStatus.error,
      errorMessage: message,
      successMessage: null,
    );
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
  }
}
