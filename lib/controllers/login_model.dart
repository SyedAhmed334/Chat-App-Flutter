import 'package:chat_app_flutter/utilities/toast_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../constants/route_name.dart';

class LoginModel with ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;
  FirebaseAuth auth = FirebaseAuth.instance;
  final firestore = fs.FirebaseFirestore.instance.collection('Users');

  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void login(BuildContext context, String email,
      String password) async {
    setLoading(true);
    auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
          Utils.toastMessage('Welcome ${value.user!.email.toString()}');
          setLoading(false);
          Navigator.pushNamed(context, RouteName.dashBoardScreen);
    }).onError((error, stackTrace) {
      setLoading(false);
      Utils.toastMessage(error.toString());
    });
    notifyListeners();
  }

}
