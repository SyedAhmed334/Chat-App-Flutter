import 'dart:io';

import 'package:chat_app_flutter/components/round_button.dart';
import 'package:chat_app_flutter/constants/colors.dart';
import 'package:chat_app_flutter/controllers/user_data_model.dart';
import 'package:chat_app_flutter/utilities/toast_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final fireStore = FirebaseFirestore.instance.collection('Users');
  final auth = FirebaseAuth.instance;
  final userNameController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  void getUserName() async {
    final map = Provider.of<UserDataProvider>(context, listen: false).userData;
    userNameController.text = map!['username'];
  }

  Future<void> fetchData() async {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    provider.fetchData().then((value) async {
      getUserName();
    });
  }

  Future<void> getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        Utils.toastMessage('No image selected');
      }
    } catch (e) {
      Utils.toastMessage('Error selecting image: $e');
    }
  }

  Future<void> uploadImage() async {
    try {
      if (_image == null) {
        Utils.toastMessage('No image selected');
        return;
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$timestamp');
      UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() async {
        String imageUrl = await storageReference.getDownloadURL();
        fireStore.doc(auth.currentUser!.uid).update({
          'imageUrl': imageUrl,
        });
        Utils.toastMessage('Image uploaded');
        fetchData();
      });
    } catch (e) {
      Utils.toastMessage('Error uploading image: $e');
    }
  }

  Widget _buildProfileImage() {
    if (_image != null) {
      return CircleAvatar(
        radius: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.file(_image!),
        ),
      );
    } else {
      final user =
          Provider.of<UserDataProvider>(context, listen: false).userData;
      if (user != null) {
        final imageUrl = user['imageUrl'];
        if (imageUrl != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.network(imageUrl,
                fit: BoxFit.cover,
                height: 150,
                width: 150,
                errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.grey,
                    ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return SizedBox(
                    width: 100,
                    height: 100,
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
          );
        } else {
          return Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.grey.shade500,
          );
        }
      } else {
        return const CircularProgressIndicator();
      }
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0),
        child: SingleChildScrollView(
          child: Consumer<UserDataProvider>(
            builder: (context, provider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      _buildProfileImage(),
                      InkWell(
                        onTap: () {
                          getImage().then((value) {
                            uploadImage();
                          });
                        },
                        child: Text('Edit',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        userNameController.text,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(color: Colors.white, fontSize: 22),
                      ),
                      Text(
                        auth.currentUser!.email.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Card(
                      color: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                enabled: provider.isEditable,
                                controller: userNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: TextStyle(color: Colors.black),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    size: 25,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              provider.isEditable
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black),
                                          ),
                                          onPressed: () {
                                            provider.isNotEditable();
                                            provider.setData(
                                                userNameController.text);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Text(
                                              'Save',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black),
                                          ),
                                          onPressed: () {
                                            provider.isNotEditable();
                                            getUserName();
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : RoundButton(
                                      title: 'Update Info',
                                      onTap: () {
                                        provider.isNotEditable();
                                      }),
                            ],
                          )),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
