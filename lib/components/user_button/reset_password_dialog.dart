import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/user_button/user_button_providers.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

final StateProvider<bool> emailSentProvider = StateProvider((ref) => false);

class PasswordResetButton extends ConsumerWidget {
  const PasswordResetButton({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
    });

    final String? email = ref.watch(emailProvider);

    return TextButton(
      onPressed: () => checkMailAndOpenDialog(context, email),
      child: const Text("Forgot password?"),
    );
  }

  void checkMailAndOpenDialog(BuildContext context, String? email) {
    if (email == null || !EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Not a valid Email"),
        ),
      );
      return;
    } 
    openPasswordResetDialog(context, email);
  }

  void openPasswordResetDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text("Do you want to reset your password for $email?"),
        actions: [
          PasswordResetButtonRow(email)
        ],
      ),
    );
  }
}

class PasswordResetButtonRow extends ConsumerWidget {
  const PasswordResetButtonRow(this.email, {super.key});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool showYesButton = !ref.watch(emailSentProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            ref.read(emailSentProvider.state).state = false;
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
        showYesButton
          ? ElevatedButton(
            onPressed: () => resetFirebasePassword(context, ref.read),
            child: const Text("Yes"),
          )
          : Container(),
      ],
    );
  }

  Future<void> resetFirebasePassword(BuildContext context, Reader stateReader) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    try {
      await firebaseAuth.sendPasswordResetEmail(email: email); 
      stateReader(emailSentProvider.state).state = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not found"),
          ),
        );
      } 
      return;
    }
  }
}