import 'package:chat_app_flutter/utilities/toast_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../constants/route_name.dart';

class SignUpModel with ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;
  FirebaseAuth auth = FirebaseAuth.instance;
  final firestore = fs.FirebaseFirestore.instance.collection('Users');

  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void signUp(BuildContext context, String userName, String email,
      String password) async {
    setLoading(true);
    auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      firestore.doc(auth.currentUser!.uid).set({
        'username': userName,
        'email': email,
        'imageUrl': null,
      }).then((value) {
        setLoading(false);
        Utils.toastMessage('User has been created!');
        Navigator.pushNamed(context, RouteName.dashBoardScreen);
      }).onError((error, stackTrace) {
        Utils.toastMessage(error.toString());
      });
    }).onError((error, stackTrace) {
      setLoading(false);
      Utils.toastMessage(error.toString());
    });
    notifyListeners();
  }
}
