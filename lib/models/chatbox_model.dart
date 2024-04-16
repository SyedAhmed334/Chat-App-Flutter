import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';

class ChatBoxModel {
  final fireStoreChats = FirebaseFirestore.instance.collection('ChatMessages');
  final auth = FirebaseAuth.instance;
  // DocumentReference<Map<String, dynamic>>? _chatBox;
  // DocumentReference<Map<String, dynamic>>? get chatBox => _chatBox;

  static String lastMesage = "";
  // String? docId;
  static String lastMessageTime = "";

  Future<DocumentReference<Map<String, dynamic>>?> getChatBox(
      QueryDocumentSnapshot<Map<String, dynamic>> targetUser) async {
    DocumentReference<Map<String, dynamic>>? chatBox;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatMessages")
        .where('participants.${auth.currentUser!.uid.toString()}',
            isEqualTo: true)
        .where("participants.${targetUser.id}", isEqualTo: true)
        .get();

    log(snapshot.docs.length.toString());
    if (snapshot.docs.isNotEmpty) {
      log('user exists');
      chatBox = snapshot.docs[0].reference
          as DocumentReference<Map<String, dynamic>>?;
    } else {
      var uid = uuid.v1();
      await FirebaseFirestore.instance.collection('ChatMessages').doc(uid).set({
        "chatBoxId": uid,
        "lastMessage": "",
        "lastMessageTime": "",
        "participants": {
          auth.currentUser!.uid.toString(): true,
          targetUser.id.toString(): true,
        },
      });
      chatBox = FirebaseFirestore.instance.collection('ChatMessages').doc(uid);
      log('ChatBox created');
    }
    DocumentSnapshot<Map<String, dynamic>> snapData = await chatBox!.get();
    final data = snapData.data();
    lastMesage = data!['lastMessage'] as String;
    lastMessageTime = data['lastMessageTime'] as String;
    // _chatBox = chatBox;

    return chatBox;
  }

  // Future<void> getData() async {
  //   DocumentSnapshot<Map<String, dynamic>> snapshot = await _chatBox!.get();
  //   final data = snapshot.data();
  //   lastMesage = data!['lastMessage'] as String;
  //   lastMessageTime = data!['lastMessageTime'] as String;
  // }
}
