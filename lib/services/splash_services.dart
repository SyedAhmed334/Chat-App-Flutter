import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/route_name.dart';

class SplashServices {
  void isLogin(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      Future.delayed(
        const Duration(seconds: 3),
        () => Navigator.pushReplacementNamed(context, RouteName.loginScreen),
      );
    } else {
      // SessionController().userId = auth.currentUser!.uid;
      Future.delayed(
        const Duration(seconds: 3),
        () =>
            Navigator.pushReplacementNamed(context, RouteName.dashBoardScreen),
      );
    }
  }
}
