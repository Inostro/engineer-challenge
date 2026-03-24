import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:template/router/routes.dart';

class NavigationService {
  void navigateToAuth(BuildContext context) {
    context.go(Routes.auth);
  }
  
  void navigateToRegister(BuildContext context) {
    context.push(Routes.register);
  }
  
  void navigateToForgotPassword(BuildContext context) {
    context.push(Routes.forgotPassword);
  }
  
  void goBack(BuildContext context) {
    context.pop();
  }
  
  void navigateToHome(BuildContext context) {
    context.go('/');
  }
}
