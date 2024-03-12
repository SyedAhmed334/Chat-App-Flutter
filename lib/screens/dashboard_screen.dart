import 'package:chat_app_flutter/constants/route_name.dart';
import 'package:chat_app_flutter/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../models/user_data_model.dart';
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
    return Scaffold(
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
            icon: Icon(CupertinoIcons.profile_circled,
                color: Colors.purpleAccent, size: 30),
          ),
          IconButton(
            onPressed: () async {
              User? user = auth.currentUser;
              try {
                if (user?.providerData[0].providerId == 'google.com') {
                  // Sign out from Google
                  await FirebaseAuth.instance.signOut();
                  await _googleSignIn.signOut().then((value) {
                    Navigator.pushNamed(context, RouteName.loginScreen);
                    Utils.toastMessage('Google user signed out!');
                  });
                } else {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.pushNamed(context, RouteName.loginScreen);
                    Utils.toastMessage('Firebase user signed out!');
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
        child: ChangeNotifierProvider<UserModel>(
          create: (context) => UserModel(),
          child: Consumer<UserModel>(
            builder: (context, provider, child) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      if (searchController.text.isEmpty) {
                        provider.users;
                      }
                      provider.filterUsers(searchController.text);
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
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
                      child: Consumer<UserModel>(
                        builder: (context, provider, child) {
                          return StreamBuilder(
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Utils.toastMessage(
                                    snapshot.error.toString());
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
                                    final email =
                                        provider.filteredUsers[index]['email'];
                                    final username = provider
                                        .filteredUsers[index]['username'];
                                    dynamic imageUrl =
                                        provider.filteredUsers[index]
                                            ['imageUrl'] as String;
                                    return ListTile(
                                      leading: imageUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child:  Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                height: 50,
                                                width: 50,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                                    Icons.account_circle,
                                                    size: 60,
                                                    color: Colors.grey,
                                                  ),
                                                  loadingBuilder:
                                                      (context, child, loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child;
                                                    }
                                                    return SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: Center(
                                                        child: CircularProgressIndicator(
                                                          color: Colors.grey,
                                                          value: loadingProgress
                                                              .expectedTotalBytes !=
                                                              null
                                                              ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                              ),
                                            ) : Icon(Icons.account_circle, size: 50, color: Colors.grey),
                                      title: Text(username.toString(),),
                                      subtitle: Text(email.toString(),),
                                    );
                                  },
                                );
                              }
                            },
                            stream: fireStore.snapshots(),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
