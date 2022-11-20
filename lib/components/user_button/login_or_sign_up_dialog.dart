import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/user_button/login_dialog.dart';
import 'package:wellbeing/components/user_button/sign_up_dialog.dart';

class LoginOrSingUpWrapper {
  const LoginOrSingUpWrapper({
    required this.context,
    required this.stateReader,
  });

  final BuildContext context;
  final Reader stateReader;

  void openLoginOrSignUp() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween ,
            children: [
              ElevatedButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: loginButtonPress,
                child: const Text("Login"),
              ),
              ElevatedButton(
                onPressed: signUpButtonPress,
                child: const Text("Sign up"),
              ),
            ]
          )
        ],
        content: const Text("Login or Sign Up?"),
      ),
    );
  }

  void loginButtonPress() {
    Navigator.of(context).pop();
    LoginWrapper(
      context: context,
      stateReader: stateReader,
    ).openLogin();
  }

  void signUpButtonPress() {
    Navigator.of(context).pop();
    SignUpWrapper(
      context: context,
      stateReader: stateReader,
    ).openSignUp();
  }
}
