import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/user_button/user_button_adaptive_error_widgets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeing/components/user_button/user_button_providers.dart';
import 'package:wellbeing/components/user_button/login_result.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/components/user_button/reset_password_dialog.dart';




class LoginWrapper {
  LoginWrapper({
    required this.context,
    required this.stateReader,
  }) {
    stateReader(emailProvider.state).state = null;
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  final BuildContext context;
  final Reader stateReader;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late FirebaseAuth firebaseAuth;

  void openLogin() {
    obscureLoginPasswords(stateReader);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        actions: [
          LoginButtonRow( 
            loginButtonPress: loginButtonPress,
            closeButtonPress: closeButtonPress,
          )
        ],
        content: LoginInput(
          emailController: emailController,
          passwordController: passwordController,
        ),
      ),
    );
  }

  void loginButtonPress() async {
    firebaseAuth = FirebaseAuth.instance;

    final String email = emailController.text;
    final bool emailValid = EmailValidator.validate(email);

    stateReader(emailValidProvider.state).state = emailValid;

    if (!emailValid) {
      return;
    }

    obscureLoginPasswords(stateReader);

    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text
      );
      stateReader(loginResultProvider.state).state = LoginResult.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        stateReader(loginResultProvider.state).state = LoginResult.userNotFound;
      } else if (e.code == 'wrong-password') {
        stateReader(loginResultProvider.state).state = LoginResult.wrongPassword;
      }
    }
  }

  void closeButtonPress() {
    obscureLoginPasswords(stateReader);
    Navigator.of(context).pop();
  }
}


class LoginButtonRow extends ConsumerWidget {
  const LoginButtonRow({
    super.key,
    required this.loginButtonPress,
    required this.closeButtonPress
  });

  final VoidCallback loginButtonPress;
  final VoidCallback closeButtonPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool userIsLoggedIn = ref.watch(userIsLoggedInProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween ,
      children: [
        ElevatedButton(
          onPressed: closeButtonPress,
          child: const Text("Close"),
        ),
        userIsLoggedIn
          ? Container()
          : ElevatedButton(
            onPressed: loginButtonPress,
            child: const Text("Login"),
          ),
      ]
    );
  }
}




class LoginInput extends ConsumerWidget {
  const LoginInput({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LoginResult loginResult = ref.watch(loginResultProvider);
    final bool emailValid = ref.watch(emailValidProvider);
    final bool userIsLoggedIn = ref.watch(userIsLoggedInProvider);
    final bool showLoginPassword = ref.watch(showLoginPasswordProvier);

    if (userIsLoggedIn) {
      return const Text("You are logged in");
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ErrorsafeTextField(
          controller: emailController,
          labelText: "Email",
          autofocus: true,
          showError: !emailValid || loginResult == LoginResult.userNotFound,
          onChanged: (value) => ref.read(emailProvider.state).state = value,
        ),
        OptionalErrorFeedback(
          showError: !emailValid,
          errorText: "Not a valid Email",
        ),
        OptionalErrorFeedback(
          showError: loginResult == LoginResult.userNotFound,
          errorText: "User not found",
        ),
        ErrorsafeTextField(
          controller: passwordController,
          labelText: "Password",
          showError: loginResult == LoginResult.wrongPassword,
          obscureText: !showLoginPassword,
          suffixIcon: IconButton(
            icon: Icon(
              showLoginPassword
                ? Icons.visibility_off
                : Icons.visibility
              ),
              onPressed: () => ref.read(showLoginPasswordProvier.state).state = !showLoginPassword,
          ),
        ),
        OptionalErrorFeedback(
          showError: loginResult == LoginResult.wrongPassword,
          errorText: "Wrong password",
        ),
        const SizedBox(height: 15,),
        const PasswordResetButton()
      ],
    );
  }
}

final StateProvider<bool> showLoginPasswordProvier = StateProvider((ref) => false);

void obscureLoginPasswords(Reader stateReader) {
  stateReader(showLoginPasswordProvier.state).state = false;
}





