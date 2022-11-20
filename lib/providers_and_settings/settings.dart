import 'package:flutter/material.dart';
import 'package:wellbeing/providers_and_settings/keys_for_save_and_load.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/providers_and_settings/firebase_helpers.dart';


class AppSettings {
  static const String settingsDarkModeKey = 'darkMode';
  static const String settingsShowEyebrowsKey = 'showEyebrows';
  static const String settingsSmileyColorNegativeKey = 'smileyGradientColorNegative';
  static const String settingsSmileyColorPositiveKey = 'smileyGradientColorPositive';
  static const String settingsShowFavoriteActivitiesKey = 'showFavoriteActivities';

  AppSettings({
    required this.showSmileyEyeBrows,
    required this.darkMode,
    required this.smileyGradientColorNegative,
    required this.smileyGradientColorPositive,
    required this.showFavoriteActivities,
  });

  bool showFavoriteActivities;
  bool showSmileyEyeBrows;
  bool darkMode;
  Color smileyGradientColorNegative;
  Color smileyGradientColorPositive;

  AppSettings.defaultSettings() : this(
      darkMode: true,
      showSmileyEyeBrows: true,
      showFavoriteActivities: true,
      smileyGradientColorNegative: Colors.red,
      smileyGradientColorPositive: Colors.green,
  );

  AppSettings.fromMap(Map<String, dynamic> map) :
    showSmileyEyeBrows = map[settingsShowEyebrowsKey],
    darkMode = map[settingsDarkModeKey],
    smileyGradientColorNegative = Color(map[settingsSmileyColorNegativeKey]),
    smileyGradientColorPositive = Color(map[settingsSmileyColorPositiveKey]),
    showFavoriteActivities = map[settingsShowFavoriteActivitiesKey];

  Map<String, dynamic> toMap() {
    return {
      settingsDarkModeKey: darkMode,
      settingsShowEyebrowsKey: showSmileyEyeBrows,
      settingsSmileyColorNegativeKey: smileyGradientColorNegative.value,
      settingsSmileyColorPositiveKey: smileyGradientColorPositive.value,
      settingsShowFavoriteActivitiesKey: showFavoriteActivities,
    };
  }

  String toJSONString() {
    return jsonEncode(toMap());
  }

  Future<void> saveToSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(settingsKey, toJSONString());
  }

  void saveToFirebaseWithId(Reader stateReader) async {
    final String? userId = stateReader(userIdFirebaseProvider);
      if (userId != null) {
        setValueToFirebase('$usersKey/$userId/$settingsKey', toMap());
    }
  }

  Future<void> saveToSharedPreferencesAndFirebaseWithId(Reader stateReader) async {
    await saveToSharedPreferences();
    saveToFirebaseWithId(stateReader);
  }

  void updateShowSmileyEyeBrows(bool value, Reader stateReader) {
    showSmileyEyeBrows = value;
    updateToTheseSettings(stateReader);
  }

  void updateSetDarkMode(bool value, Reader stateReader) {
    darkMode = value;
    updateToTheseSettings(stateReader);
  }

  void updateShowFavoriteActivities(bool value, Reader stateReader) {
    showFavoriteActivities = value;
    updateToTheseSettings(stateReader);
  }

  void updateSmileyGradientColorNegative(Color value, Reader stateReader) {
    smileyGradientColorNegative = value;
    updateToTheseSettings(stateReader);
  }

  void updateSmileyGradientColorPositive(Color value, Reader stateReader) {
    smileyGradientColorPositive = value;
    updateToTheseSettings(stateReader);
  }

  void updateToTheseSettings(Reader stateReader) {
    final AppSettings newSettings = AppSettings.fromMap(toMap());
    stateReader(appSettingsProvider.state).state = newSettings;
  }
}

final StateProvider<AppSettings> appSettingsProvider = StateProvider((ref) => AppSettings.defaultSettings(),);
