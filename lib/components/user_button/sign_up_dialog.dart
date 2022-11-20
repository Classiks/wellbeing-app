import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/user_button/user_button_adaptive_error_widgets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeing/components/user_button/user_button_providers.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';


class SignUpWrapper {
  SignUpWrapper({
    required this.context,
    required this.stateReader,
  }) {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    passwordConfirmController = TextEditingController();
  }

  final BuildContext context;
  final Reader stateReader;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController passwordConfirmController;

  void openSignUp() {
    obscureSignUpPasswords(stateReader);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        actions: [
          SignUpButtonRow(
            okayButtonPress: okayButtonPress,
            cancelButtonPress: cancelButtonPress,
          )
        ],
        content: SignUpInput(
          emailController: emailController,
          passwordController: passwordController,
          passwordCheckController: passwordConfirmController,
        ),
      ),
    );
  }

  void okayButtonPress() {
    final String email = emailController.text;
    final bool emailValid = EmailValidator.validate(email);
    final String password = passwordController.text;
    final String passwordCheck = passwordConfirmController.text;
    final bool passwordValid = stateReader(passwordValidProvider);
    final bool passwordsMatching = (
      password.isNotEmpty &&
      password == passwordCheck
    );

    stateReader(emailValidProvider.state).state = emailValid;
    stateReader(passwordValidProvider.state).state = passwordValid;
    stateReader(passwordsMatchingProvider.state).state = passwordsMatching;

    if (!emailValid || !passwordValid || !passwordsMatching) {
      return;
    }
    
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );

    const SnackBar snackBar = SnackBar(
      content: Text("Sign Up Successful."),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    obscureSignUpPasswords(stateReader);
    Navigator.of(context).pop();
  }

  void cancelButtonPress() {
    stateReader(emailValidProvider.state).state = true;
    stateReader(passwordValidProvider.state).state = true;

    obscureSignUpPasswords(stateReader);
    Navigator.of(context).pop();
  }

}


class SignUpButtonRow extends StatelessWidget {
  const SignUpButtonRow({
    super.key,
    required this.okayButtonPress,
    required this.cancelButtonPress,
  });

  final VoidCallback okayButtonPress;
  final VoidCallback cancelButtonPress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween ,
      children: [
        ElevatedButton(
          onPressed: cancelButtonPress,
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: okayButtonPress,
          child: const Text("Ok"),
        ),
      ]
    );
  }

}


class SignUpInput extends ConsumerWidget {
  const SignUpInput({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.passwordCheckController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordCheckController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool emailValid = ref.watch(emailValidProvider);
    final bool passwordsMatching = ref.watch(passwordsMatchingProvider);
    final bool showSignUpPassword = ref.watch(showSignUpPasswordProvier);
    final bool showSignUpPasswordCheck = ref.watch(showSignUpPasswordCheckProvier);

    return Column(
      mainAxisSize: MainAxisSize.min,
          children: [
            ErrorsafeTextField(
              controller: emailController,
              showError: !emailValid,
              labelText: "Email",
              autofocus: true,
            ),
            OptionalErrorFeedback(
              showError: !emailValid,
              errorText: "Invalid email",
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    showSignUpPassword
                      ? Icons.visibility_off
                      : Icons.visibility
                    ),
                    onPressed: () => ref.read(showSignUpPasswordProvier.state).state = !showSignUpPassword,
                ),
              ),
              obscureText: !showSignUpPassword,
            ),
            FlutterPwValidator(
              controller: passwordController,
              minLength: PasswordRequirements.minLength,
              normalCharCount: PasswordRequirements.normalCharCount,
              uppercaseCharCount: PasswordRequirements.uppercaseCharCount,
              numericCharCount: PasswordRequirements.numericCharCount,
              specialCharCount: PasswordRequirements.specialCharCount,
              width: 400,
              height: 150,
              onSuccess: () => ref.read(passwordValidProvider.state).state = true,
              onFail: () => ref.read(passwordValidProvider.state).state = false,
            ),
            TextField(
              controller: passwordCheckController,
              decoration: InputDecoration(
                labelText: 'Password Confirmation',
                focusedBorder: conditionalErrorBorder(!passwordsMatching),
                enabledBorder: conditionalErrorBorder(!passwordsMatching),
                suffixIcon: IconButton(
                  icon: Icon(
                    showSignUpPasswordCheck
                      ? Icons.visibility_off
                      : Icons.visibility
                    ),
                    onPressed: () => ref.read(showSignUpPasswordCheckProvier.state).state = !showSignUpPasswordCheck,
                ),
              ),
              obscureText: !showSignUpPasswordCheck,              
            ),
            OptionalErrorFeedback(
              showError: !passwordsMatching,
              errorText: "Passwords do not match",
            ),
          ],
        );
  }
}


final StateProvider<bool> showSignUpPasswordProvier = StateProvider((ref) => false);
final StateProvider<bool> showSignUpPasswordCheckProvier = StateProvider((ref) => false);

void obscureSignUpPasswords(Reader stateReader) {
  stateReader(showSignUpPasswordProvier.state).state = false;
  stateReader(showSignUpPasswordCheckProvier.state).state = false;
}


class PasswordRequirements {
  static int minLength = 8;
  static int normalCharCount = 1;
  static int uppercaseCharCount = 1;
  static int numberCount = 1;
  static int specialCharCount = 1;
  static int numericCharCount = 1;
}
