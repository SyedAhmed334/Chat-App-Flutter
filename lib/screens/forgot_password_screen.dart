import 'package:chat_app_flutter/components/input_textfield.dart';
import 'package:chat_app_flutter/models/forgot_password_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/round_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password Screen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enter your email below to reset password!',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
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
              height: 20,
            ),
            ChangeNotifierProvider(
              create: (context) => ForgetPasswordModel(),
              child: Consumer<ForgetPasswordModel>(
                builder: <ForgetPasswordModel>(context, value, child) {
                  return RoundButton(
                      title: 'Submit',
                      loading: value.loading,
                      onTap: () async {
                        await value.resetPassword(
                            context, emailController.text);
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
