import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/splash_screen.dart';
import 'route_name.dart';


 class Routes {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final arguments = settings.arguments;
    switch (settings.name) {
      case RouteName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

       case RouteName.loginScreen:
         return MaterialPageRoute(builder: (_) => const LoginScreen());

       case RouteName.signUpScreen:
         return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case RouteName.dashBoardScreen:
         return MaterialPageRoute(builder: (_) => const DashBoardScreen());
      case RouteName.forgotPasswordScreen:
         return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}