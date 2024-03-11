import 'dart:io';

import 'package:chat_app_flutter/components/round_button.dart';
import 'package:chat_app_flutter/constants/colors.dart';
import 'package:chat_app_flutter/models/user_data_model.dart';
import 'package:chat_app_flutter/utilities/toast_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  void getUserName() {
    final map = Provider.of<UserDataProvider>(context, listen: false).userData;
    userNameController.text = map['username'];
  }

  Future<void> fetchData() async {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    provider.fetchData().then((value) async {
      getUserName();
    });
  }

  Future getImage() async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
    } else {
      Utils.toastMessage('No image selected');
    }
  }

  Future<void> uploadImage () async{
    Reference storageReference = FirebaseStorage.instance.ref().child('images/profile-picture.png');
    UploadTask uploadTask = storageReference.putFile(_image!);
    await uploadTask.whenComplete(() async {
      String imageUrl = await storageReference.getDownloadURL();
      fireStore.doc(auth.currentUser!.uid).update({
        'imageUrl' : imageUrl,
      });
      Utils.toastMessage('Image uploaded');
    });

  }
  Widget _buildProfileImage() {
    if (_image != null) {
      return CircleAvatar(radius: 50,child: ClipRRect(borderRadius: BorderRadius.circular(100),child: Image.file(_image!),),);
    } else {
      final user = Provider.of<UserDataProvider>(context).userData;
      final imageUrl = user['imageUrl'];
      if (imageUrl != null) {
        return CircleAvatar(radius: 50,child: ClipRRect(borderRadius: BorderRadius.circular(100),child: Image.network(imageUrl,)));
      } else {
        return Icon(
          Icons.account_circle,
          size: 100,
          color: Colors.grey.shade500,
        );
      }
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fetchData();
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
                      InkWell(onTap: (){
                        getImage().then((value) {
                          uploadImage();
                        });
                      },child: Text('Edit', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),),
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
