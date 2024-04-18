import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class ChatBoxModel {
  final fireStoreChats = FirebaseFirestore.instance.collection('ChatMessages');
  final auth = FirebaseAuth.instance;

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
        "lastMessageSenderId": "",
        "participants": {
          auth.currentUser!.uid.toString(): true,
          targetUser.id.toString(): true,
        },
      });
      chatBox = FirebaseFirestore.instance.collection('ChatMessages').doc(uid);
      log('ChatBox created');
    }
    // DocumentSnapshot<Map<String, dynamic>> snapData = await chatBox!.get();
    // final data = snapData.data();
    // lastMesage = data!['lastMessage'] as String;
    // lastMessageTime = data['lastMessageTime'] as String;

    return chatBox;
  }

  Future<void> sendMessage(String message, User? currentUser,
      DocumentReference<Map<String, dynamic>>? chatBox) async {
    String msg = message;
    // messageController.clear();
    var messageId = uuid.v1();
    String currentTime = DateFormat('h:mm a').format(DateTime.now());
    if (msg != '') {
      FirebaseFirestore.instance
          .collection('ChatMessages')
          .doc(chatBox!.id)
          .collection('messages')
          .doc(messageId)
          .set({
        'messageId': messageId,
        'text': msg,
        'sender': currentUser!.uid,
        'createdOn': DateTime.now(),
        'messageTime': currentTime,
      });
    }
    await chatBox!.update({
      'lastMessage': msg,
      'lastMessageTime': currentTime,
      'lastMessageSenderId': currentUser!.uid.toString(),
    });
    DocumentSnapshot<Map<String, dynamic>> snapshot = await chatBox.get();
    Map<String, dynamic>? chatBoxData = snapshot.data();

    FirebaseFirestore.instance
        .collection('ChatMessages')
        .doc(chatBox.id)
        .set(chatBoxData!);
    log("Message Sent!");
  }
}
