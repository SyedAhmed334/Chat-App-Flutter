import 'package:chat_app_flutter/components/input_textfield.dart';
import 'package:chat_app_flutter/constants/route_name.dart';
import 'package:chat_app_flutter/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Home Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              User? user = auth.currentUser;
              try {
                if (user?.providerData[0].providerId == 'google.com') {
                  // Sign out from Google
                  await _googleSignIn.signOut();
                  Navigator.pushNamed(context, RouteName.loginScreen);
                  Utils.toastMessage('Google user signed out!');
                } else {
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
              } catch (e) {
                Utils.toastMessage(e.toString());
              }
            },
            icon: Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: ChangeNotifierProvider<UserModel>(
          create: (context)=> UserModel(),
          child: Consumer<UserModel>(
            builder: <UserModel>(context, provider, child) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value){
                      provider.filterUsers(searchController.text);
                      print(provider.filteredUsers);
                    },
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        labelText: 'Search',
                        prefixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: AppColors.textFieldDefaultFocus,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade800),
                        )),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),),),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: StreamBuilder(
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Utils.toastMessage(snapshot.error.toString());
                              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Text('No users found');
                              } else {
                                final users = snapshot.data!.docs.map((e) {
                                  final email = e.data()['email'] as String;
                                  final userName = e.data()['username'] as String;
                                  return {'username': userName, 'email': email};
                                }).toList();
                                provider.getUsers(users);
                                return ListView.builder(
                                  itemCount: provider.filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final email =
                                    provider.filteredUsers[index]['email'];
                                    final username =
                                    provider.filteredUsers[index]['username'];
                                      return ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: CircleAvatar(
                                            radius: 25,
                                            child: Image.asset('assets/images/profile.jpg'),
                                          ),
                                        ),
                                        title: Text(username),
                                        subtitle: Text(email),
                                      );
                                  },
                                );
                              }
                            },
                            stream: fireStore.snapshots(),
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
