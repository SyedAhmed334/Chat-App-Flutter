import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_flutter/constants/colors.dart';
import 'package:chat_app_flutter/constants/route_name.dart';
import 'package:chat_app_flutter/controllers/chatbox_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> targetUser;
  final User? currentUser;
  final String imageUrl;
  final String? username;
  late DocumentReference<Map<String, dynamic>>? chatBox;
  ChatScreen({
    super.key,
    required this.targetUser,
    required this.imageUrl,
    required this.username,
    required this.currentUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    getChatBox();
    super.initState();
  }

  void getChatBox() async {
    isLoading = true;
    widget.chatBox = await ChatBoxModel().getChatBox(widget.targetUser);
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: Text(
                widget.username!,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
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
                    child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                        height: 45,
                        width: 45,
                        errorWidget: (context, error, stackTrace) => const Icon(
                              Icons.account_circle,
                              size: 47,
                              color: Colors.grey,
                            ),
                        placeholder: (context, child) {
                          return const SizedBox(
                            width: 45,
                            height: 45,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.grey,
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
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot dataSnapshot =
                                snapshot.data as QuerySnapshot;
                            return dataSnapshot.docs.isEmpty
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child:
                                            Text('Say hi to your new friend!'),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    reverse: true,
                                    itemCount: dataSnapshot.docs.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final currentMessage =
                                          dataSnapshot.docs[index].data()
                                              as Map<String, dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              (currentMessage['sender']
                                                          .toString() ==
                                                      widget.currentUser!.uid
                                                          .toString())
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              // constraints: BoxConstraints(
                                              //     maxWidth:
                                              //         MediaQuery.of(context).size.width *
                                              //             .65),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 4),
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
                                                    currentMessage['text']
                                                        .toString(),
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
                                                              widget
                                                                  .currentUser!
                                                                  .uid
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

              ChatBoxModel().sendMessage(messageController.text.trim(),
                  widget.currentUser, widget.chatBox);
              messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}
