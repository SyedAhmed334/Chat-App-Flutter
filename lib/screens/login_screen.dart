import 'dart:developer';

import 'package:chat_app_flutter/components/input_textfield.dart';
import 'package:chat_app_flutter/components/round_button.dart';
import 'package:chat_app_flutter/constants/route_name.dart';
import 'package:chat_app_flutter/controllers/login_model.dart';
import 'package:chat_app_flutter/utilities/toast_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              Text(
                'Login',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(
                height: 100,
              ),
              InputTextField(
                  controller: emailController,
                  enable: true,
                  onFieldSubmittedValue: (value) {},
                  onValidate: (value) {
                    return value.isEmpty ? 'Enter your email' : null;
                  },
                  keyBoardType: TextInputType.emailAddress,
                  iconData: Icons.email_outlined,
                  hint: 'Email',
                  obscureText: false),
              const SizedBox(
                height: 10,
              ),
              InputTextField(
                  controller: passwordController,
                  iconData: Icons.key,
                  onFieldSubmittedValue: (value) {},
                  enable: true,
                  onValidate: (value) {
                    return value.isEmpty ? 'Enter your password' : null;
                  },
                  keyBoardType: TextInputType.text,
                  hint: 'Password',
                  obscureText: true),
              Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                          context, RouteName.forgotPasswordScreen);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          decoration: TextDecoration.underline, fontSize: 16),
                    ),
                  )),
              const SizedBox(
                height: 40,
              ),
              ChangeNotifierProvider(
                create: (context) => LoginModel(),
                child: Consumer<LoginModel>(
                  builder: <LoginModel>(context, value, child) {
                    return RoundButton(
                        title: 'Login',
                        loading: value.loading,
                        onTap: () async {
                          await value.login(context, emailController.text,
                              passwordController.text);
                        });
                  },
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have a account? ',
                    style: TextStyle(fontSize: 16),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, RouteName.signUpScreen);
                    },
                    child: Text(
                      'Signup',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          decoration: TextDecoration.underline, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              ChangeNotifierProvider(
                create: (context) => LoginModel(),
                child: Consumer<LoginModel>(
                  builder: <LoginModel>(context, provider, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: InkWell(
                        onTap: () async {
                          await provider.signInWithGoogle(context);
                        },
                        child: provider.loading
                            ? const Center(child: CircularProgressIndicator())
                            : const Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                      child: Image(
                                    image:
                                        AssetImage('assets/images/google.png'),
                                  )),
                                  title: Text('Sign in with Google'),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: InkWell(
                  onTap: () async {
                    await signInWithFacebook().then((value) {
                      Navigator.pushNamed(context, RouteName.dashBoardScreen);
                      Utils.toastMessage('Sign in successful!');
                    });
                  },
                  child: const Card(
                    color: Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                          child: Image(
                        image: AssetImage('assets/images/facebook.png'),
                      )),
                      title: Text('Sign in with Facebook'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
