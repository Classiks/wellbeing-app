import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/components/user_button/login_or_sign_up_dialog.dart';
import 'package:wellbeing/components/user_button/logout_dialog.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:wellbeing/providers_and_settings/showcase_texts.dart';


class UserButtonRow extends StatelessWidget {
  const UserButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Showcase(
            key: globalKeySettingsPage,
            description: userbuttonShowcaseText,
            child: const UserButton()
          )
        ]
      ),
    );
  }
}


class UserButton extends ConsumerWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final LoginOrSingUpWrapper loginOrSingUpWrapper = LoginOrSingUpWrapper(
      context: context,
      stateReader: ref.read
    );

    final LogoutWrapper logoutWrapper = LogoutWrapper(
      context: context,
      stateReader: ref.read
    );

    final userIsLoggedIn = ref.watch(userIsLoggedInProvider);

    return IconButton(
      icon: Icon(
        Icons.person,
        color: userIsLoggedIn
          ? Theme.of(context).colorScheme.primary
          : null
      ),
      onPressed: userIsLoggedIn
        ? logoutWrapper.openLogout
        : loginOrSingUpWrapper.openLoginOrSignUp
    );
  }
}
