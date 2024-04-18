import 'package:chat_app_flutter/controllers/signup_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/input_textfield.dart';
import '../components/round_button.dart';
import '../constants/route_name.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Signup',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(
                height: 100,
              ),
              InputTextField(
                  controller: userNameController,
                  enable: true,
                  onFieldSubmittedValue: (value) {},
                  onValidate: (value) {
                    return value.isEmpty ? 'Enter your username' : null;
                  },
                  keyBoardType: TextInputType.emailAddress,
                  iconData: Icons.person_outline,
                  hint: 'Username',
                  obscureText: false),
              const SizedBox(
                height: 20,
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
                height: 20,
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
              const SizedBox(
                height: 40,
              ),
              ChangeNotifierProvider(
                create: (context) => SignUpModel(),
                child: Consumer<SignUpModel>(
                  builder: <SignUpModel>(context, value, child) {
                    return RoundButton(
                        title: 'Signup',
                        loading: value.loading,
                        onTap: () async {
                          await value.signUp(context, userNameController.text,
                              emailController.text, passwordController.text);
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
                    'Already have an account? ',
                    style: TextStyle(fontSize: 16),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, RouteName.loginScreen);
                    },
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          decoration: TextDecoration.underline, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
