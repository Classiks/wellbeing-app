import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';


class LogoutWrapper {
  const LogoutWrapper({
    required this.context,
    required this.stateReader,
  });

  final BuildContext context;
  final Reader stateReader;

  void openLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween ,
            children: [
              ElevatedButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: logoutButtonPress,
                child: const Text("Logout"),
              ),
            ]
          )
        ],
        content: const Text("Are you sure you want to logout?"),
      ),
    );
  }

  void logoutButtonPress() {
    FirebaseAuth.instance.signOut();
    stateReader(activityEntriesProvider.state).state = [];
    stateReader(activityTypeCollectionProvider.state).state = ActivityTypeCollection({});
    stateReader(appSettingsProvider.state).state = AppSettings.defaultSettings();
    stateReader(hiddenActivityTypesProvider.state).state = {};
    stateReader(favoriteActivityTypesProvider.state).state = {};
    Navigator.of(context).pop();
  }
}

