// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_flutter/constants/route_name.dart';
import 'package:chat_app_flutter/controllers/chatbox_model.dart';
import 'package:chat_app_flutter/controllers/user_controller.dart';
import 'package:chat_app_flutter/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../utilities/toast_message.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final searchController = TextEditingController();
  final fireStore = FirebaseFirestore.instance.collection('Users');

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          elevation: 5,
          automaticallyImplyLeading: false,
          title: const Text(
            'Home Screen',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteName.profileScreen);
              },
              icon: const Icon(CupertinoIcons.profile_circled,
                  color: Colors.purpleAccent, size: 30),
            ),
            IconButton(
              onPressed: () async {
                User? user = auth.currentUser;
                try {
                  if (user?.providerData[0].providerId == 'google.com') {
                    await FirebaseAuth.instance.signOut();
                    await _googleSignIn.signOut().then((value) {
                      Navigator.pushReplacementNamed(
                          context, RouteName.loginScreen);
                      // Utils.toastMessage('Google user signed out!');
                    });
                  } else {
                    FirebaseAuth.instance.signOut().then((value) {
                      Navigator.pushReplacementNamed(
                          context, RouteName.loginScreen);
                      // Utils.toastMessage('Firebase user signed out!');
                    });
                  }
                } catch (e) {
                  // Utils.toastMessage(e.toString());
                }
              },
              icon: const Icon(
                Icons.logout_outlined,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: ChangeNotifierProvider<UserController>(
            create: (context) => UserController(),
            child: Consumer<UserController>(
              builder: (context, provider, child) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SearchBarWidget(
                    searchController: searchController,
                    provider: provider,
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Consumer<UserController>(
                          builder: (context, provider, child) {
                            return StreamBuilder(
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Text('No users found');
                                } else {
                                  final users = snapshot.data!.docs.map((e) {
                                    final email = e.data()['email'] as String;
                                    final userName =
                                        e.data()['username'] as String;
                                    final imageUrl =
                                        e.data()['imageUrl'] as String;
                                    return {
                                      'username': userName,
                                      'email': email,
                                      'imageUrl': imageUrl
                                    };
                                  }).toList();
                                  if (provider.users.isEmpty) {
                                    provider.getUsers(users);
                                  }
                                  provider.filteredUsers;
                                  return ListView.builder(
                                    itemCount: provider.filteredUsers.length,
                                    itemBuilder: (context, index) {
                                      final userDocument =
                                          snapshot.data!.docs[index];

                                      final username = provider
                                          .filteredUsers[index]['username'];
                                      final imageUrl =
                                          provider.filteredUsers[index]
                                              ['imageUrl'] as String;

                                      return FutureBuilder<
                                              DocumentReference<
                                                  Map<String, dynamic>>?>(
                                          future: ChatBoxModel()
                                              .getChatBox(userDocument),
                                          builder: (context, chatBoxSnapshot) {
                                            if (chatBoxSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              // Show loading indicator while fetching chat box
                                              return const Center(
                                                child: SizedBox(),
                                              );
                                            } else if (chatBoxSnapshot
                                                .hasError) {
                                              // Handle error
                                              return Text(
                                                  'Error: ${chatBoxSnapshot.error}');
                                            } else {
                                              final chatBoxRef =
                                                  chatBoxSnapshot.data;
                                              if (chatBoxRef != null) {
                                                return StreamBuilder<
                                                    DocumentSnapshot<
                                                        Map<String, dynamic>>>(
                                                  stream:
                                                      chatBoxRef.snapshots(),
                                                  builder: (context,
                                                      chatBoxDataSnapshot) {
                                                    if (chatBoxDataSnapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      // Show loading indicator while fetching chat box data
                                                      // return const Center(
                                                      //     child:
                                                      //         CircularProgressIndicator());
                                                      return Container();
                                                    } else if (chatBoxDataSnapshot
                                                        .hasError) {
                                                      // Handle error
                                                      return Text(
                                                          'Error: ${chatBoxDataSnapshot.error}');
                                                    } else {
                                                      // Get the data from the chat box document
                                                      final chatBoxData =
                                                          chatBoxDataSnapshot
                                                              .data!
                                                              .data();
                                                      if (chatBoxData != null) {
                                                        final lastMessage =
                                                            chatBoxData[
                                                                    'lastMessage']
                                                                as String;
                                                        final lastMessageTime =
                                                            chatBoxData[
                                                                    'lastMessageTime']
                                                                as String;
                                                        final lastMessageSenderId =
                                                            chatBoxData[
                                                                    'lastMessageSenderId'] ??
                                                                '';

                                                        return ListTile(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ChatScreen(
                                                                    targetUser:
                                                                        userDocument,
                                                                    imageUrl:
                                                                        imageUrl,
                                                                    username:
                                                                        username,
                                                                    currentUser:
                                                                        auth.currentUser,
                                                                  ),
                                                                ));
                                                          },
                                                          leading: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            child:
                                                                CachedNetworkImage(
                                                                    key:
                                                                        UniqueKey(),
                                                                    imageUrl:
                                                                        imageUrl,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height: 50,
                                                                    width: 50,
                                                                    errorWidget: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        const Icon(
                                                                          Icons
                                                                              .account_circle,
                                                                          size:
                                                                              52,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                    placeholder:
                                                                        (context,
                                                                            child) {
                                                                      return const SizedBox(
                                                                        width:
                                                                            50,
                                                                        height:
                                                                            50,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }),
                                                          ),
                                                          title: Text(
                                                            username.toString(),
                                                          ),
                                                          subtitle: Text(lastMessage ==
                                                                  ""
                                                              ? 'Say hi to your new friend!'
                                                              : (lastMessageSenderId !=
                                                                      auth.currentUser!
                                                                          .uid)
                                                                  ? lastMessage
                                                                  : 'you: $lastMessage'),
                                                          trailing: Text(
                                                              lastMessageTime),
                                                        );
                                                      } else {
                                                        return const Text(
                                                            'Chat box data not found');
                                                      }
                                                    }
                                                  },
                                                );
                                              } else {
                                                return const Text(
                                                    'Chat box not found');
                                              }
                                            }
                                          });
                                    },
                                  );
                                }
                              },
                              stream: FirebaseFirestore.instance
                                  .collection('Users')
                                  .where(
                                    "email",
                                    isNotEqualTo: auth.currentUser!.email,
                                  )
                                  .snapshots(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.searchController,
    required this.provider,
  });

  final TextEditingController searchController;
  final provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: TextFormField(
        controller: searchController,
        onChanged: (value) {
          if (searchController.text.isEmpty) {
            provider.users;
          }
          provider.filterUsers(searchController.text);
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          labelText: 'Search',
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35),
            borderSide: const BorderSide(
              color: AppColors.textFieldDefaultFocus,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35),
            borderSide: const BorderSide(color: Colors.white24),
          ),
        ),
      ),
    );
  }
}
