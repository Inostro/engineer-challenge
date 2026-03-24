import 'package:go_router/go_router.dart';
import 'package:template/auth/screen/auth_screen.dart';
import 'package:template/re_password/screen/forgot_password_screen.dart';
import 'package:template/registration/screen/register_screen.dart';
import 'package:template/router/routes.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: Routes.auth,
    routes: [
      GoRoute(
        path: Routes.auth,
        name: Routes.authName,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: Routes.register,
        name: Routes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        name: Routes.forgotPasswordName,
        builder: (context, state) => const RePasswordScreen(),
      ),
    ],
    redirect: (context, state) {
      return null;
    },
  );
}
