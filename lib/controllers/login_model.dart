import 'dart:developer';

import 'package:chat_app_flutter/utilities/toast_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  void login(BuildContext context, String email, String password) async {
    setLoading(true);
    auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      Utils.toastMessage('Welcome ${value.user!.email.toString()}');
      setLoading(false);
      Navigator.pushReplacementNamed(context, RouteName.dashBoardScreen);
    }).onError((error, stackTrace) {
      setLoading(false);
      Utils.toastMessage(error.toString());
    });
    notifyListeners();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) async {
        setLoading(true);
        if (value.user != null) {
          // Fetch user data
          String? displayName = value.user!.displayName;
          String? email = value.user!.email;
          var documentSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(value.user!.uid)
              .get();

          // Upload user data to Firestore
          if (!documentSnapshot.exists) {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(value.user!.uid)
                .set({
              'username': displayName,
              'email': email,
              'imageUrl': "",
            });
          }
        }

        // ignore: use_build_context_synchronously
        setLoading(false);
        Navigator.pushReplacementNamed(context, RouteName.dashBoardScreen);
        Utils.toastMessage('Sign In Successful!');
        log('except');
      });
    } catch (e) {
      setLoading(false);
      return Future.error(e.toString());
    }
    notifyListeners();
    // Once signed in, return the UserCredential
  }
}
