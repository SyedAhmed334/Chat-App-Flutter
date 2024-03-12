import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserDataProvider extends ChangeNotifier{
 final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance.collection('Users');
   DocumentSnapshot? _userData;
 bool _isEditable = false;
 bool get isEditable => _isEditable;

  DocumentSnapshot? get userData => _userData;
  Future<void> fetchData() async{
   _userData = await FirebaseFirestore.instance.collection('Users').doc(auth.currentUser!.uid.toString()).get();
   notifyListeners();
  }

  Future<void> setData(String username) async{
   await fireStore.doc(auth.currentUser!.uid.toString()).update(
    {
     'username' : username,
     'email' : auth.currentUser!.email.toString(),
    }
   );
   notifyListeners();
  }

 void isNotEditable() {
  _isEditable = !_isEditable;
  notifyListeners();
 }
}