import 'dart:developer';

import 'package:chat_app_flutter/constants/colors.dart';
import 'package:chat_app_flutter/constants/route_name.dart';
import 'package:chat_app_flutter/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> targetUser;
  final User? currentUser;
  final String imageUrl;
  final String? username;
  final DocumentReference<Map<String, dynamic>>? chatBox;
  const ChatScreen({
    super.key,
    required this.targetUser,
    required this.imageUrl,
    required this.username,
    required this.currentUser,
    required this.chatBox,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    var messageId = uuid.v1();
    if (msg != '') {
      FirebaseFirestore.instance
          .collection('ChatMessages')
          .doc(widget.chatBox!.id)
          .collection('messages')
          .doc(messageId)
          .set({
        'messageId': messageId,
        'text': msg,
        'sender': widget.currentUser!.uid,
        'createdOn': DateTime.now(),
        'messageTime': DateFormat('h:mm a').format(DateTime.now()),
      });
    }
    widget.chatBox!.update({
      'lastMessage': msg,
      'lastMessageTime': DateFormat('h:mm a').format(DateTime.now())
    });
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await widget.chatBox!.get();
    Map<String, dynamic>? chatBoxData = snapshot.data();

    FirebaseFirestore.instance
        .collection('ChatMessages')
        .doc(widget.chatBox!.id)
        .set(chatBoxData!);
    log("Message Sent!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.username!,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leadingWidth: 95,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Navigate back
                Navigator.pushNamed(context, RouteName.dashBoardScreen);
              },
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(widget.imageUrl,
                  fit: BoxFit.cover,
                  height: 45,
                  width: 45,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_circle,
                        size: 47,
                        color: Colors.grey,
                      ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return SizedBox(
                      width: 45,
                      height: 45,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('ChatMessages')
                    .doc(widget.chatBox!.id)
                    .collection('messages')
                    .orderBy('createdOn', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      return dataSnapshot.docs.isEmpty
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text('Say hi to your new friend!'),
                                ),
                              ],
                            )
                          : ListView.builder(
                              reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                final currentMessage = dataSnapshot.docs[index]
                                    .data() as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: (currentMessage['sender']
                                                .toString() ==
                                            widget.currentUser!.uid.toString())
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        // constraints: BoxConstraints(
                                        //     maxWidth:
                                        //         MediaQuery.of(context).size.width *
                                        //             .65),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (currentMessage['sender']
                                                      .toString() ==
                                                  widget.currentUser!.uid
                                                      .toString())
                                              ? const Color(0xFF0A6AFF)
                                              : AppColors.grayColor,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentMessage['text'].toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                      color: (currentMessage[
                                                                      'sender']
                                                                  .toString() ==
                                                              widget
                                                                  .currentUser!
                                                                  .uid
                                                                  .toString())
                                                          ? Colors.white
                                                          : Colors.black),
                                            ),
                                            Row(
                                              children: [
                                                Text(currentMessage[
                                                    'messageTime']),
                                                (currentMessage['sender']
                                                            .toString() ==
                                                        widget.currentUser!.uid
                                                            .toString())
                                                    ? const Icon(
                                                        Icons.done_all,
                                                        size: 18,
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                            'An error occured! Please check your internet'),
                      );
                    } else {
                      log('say hi to new friend');
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text('Say hi to your new friend!'),
                          ),
                        ],
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () {
              // Add functionality to pick an image
            },
          ),
          Expanded(
            child: TextField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                // Store the typed message
              },
              minLines: 1,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Send a message...',
                filled: true,
                fillColor: AppColors.grayColor.withOpacity(0.5),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: AppColors.grayColor.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: AppColors.grayColor.withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: AppColors.grayColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // Add functionality to send the message
              sendMessage();
            },
          ),
        ],
      ),
    );
  }
}
