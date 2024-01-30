import 'package:chat_app_flutter/utilities/toast_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../constants/route_name.dart';

class ForgetPasswordModel with ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;
  FirebaseAuth auth = FirebaseAuth.instance;

  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void resetPassword(BuildContext context, String email) async {
    setLoading(true);
    auth.sendPasswordResetEmail(email: email)
        .then((value) {
      Utils.toastMessage('Check your email box for password reset');
      setLoading(false);
      Navigator.pushNamed(context, RouteName.loginScreen);
    }).onError((error, stackTrace) {
      setLoading(false);
      Utils.toastMessage(error.toString());
    });
    notifyListeners();
  }

}
