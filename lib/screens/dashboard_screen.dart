import 'package:chat_app_flutter/constants/route_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utilities/toast_message.dart';
class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Home Screen',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(onPressed: () async{
            User? user = auth.currentUser;
            try {

               if (user?.providerData[0].providerId == 'google.com') {
                 // Sign out from Google
                 await _googleSignIn.signOut();
                 Navigator.pushNamed(context, RouteName.loginScreen);
                 Utils.toastMessage('Google user signed out!');
               } else{
                 FirebaseAuth.instance.signOut().then((value) {
                   Navigator.pushNamed(context, RouteName.loginScreen);
                   Utils.toastMessage('Firebase user signed out!');
                 });
               }
              // else {
              //   await _googleSignIn.signOut().then((value) {
              //     Navigator.pushNamed(context, RouteName.loginScreen);
              //     Utils.toastMessage('Google user signed out!');
              //   });
              // }

            }
            catch(e){
              Utils.toastMessage(e.toString());
            }
          }, icon: Icon(Icons.logout_outlined,color: Colors.white,),),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

        ],
      ),
    );
  }
}
