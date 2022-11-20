import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';
import 'package:wellbeing/dataclasses/activity_entry.dart';
import 'package:wellbeing/dataclasses/data_wrapper.dart';
import 'package:wellbeing/providers_and_settings/keys_for_save_and_load.dart';

class DataLoader {
  DataLoader(this.stateReader);
  final Reader stateReader;

  Future<void> loadFromSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DataWrapper dataWrapper = DataWrapper.fromSharedPreferences(prefs);
    dataWrapper.loadToProviders(stateReader);
  }

  Future<void> loadFromFirebaseWithId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseDatabase db = FirebaseDatabase.instance;
    final DataWrapper dataWrapper = await DataWrapper.fromFirebase(db, 'users/$userId');
    dataWrapper.loadToProviders(stateReader);
    dataWrapper.saveDataToSharedPreferencesAndFirebaseWithId(stateReader);
    prefs.setString(firebaseUserIdKey, userId);
  }

  Future<void> loadAndCombineSharedPreferencesAndFirebaseWithId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DataWrapper dataWrapperSharedPreferences = DataWrapper.fromSharedPreferences(prefs);
    final FirebaseDatabase db = FirebaseDatabase.instance;
    final DataWrapper dataWrapperFirebase = await DataWrapper.fromFirebase(db, 'users/$userId');

    final AppSettings appSettingsFromSharedPreferences = dataWrapperSharedPreferences.appSettings ?? AppSettings.defaultSettings();

    final ActivityTypeCollection joinedActivityTypeCollection = ActivityTypeCollection({})
      .createAndReturnJoinedCollection(dataWrapperSharedPreferences.activityTypeCollection)
      .createAndReturnJoinedCollection(dataWrapperFirebase.activityTypeCollection);

    final List<ActivityEntry> joinedActivityEntries = joinEntryLists(
      dataWrapperSharedPreferences.activityEntries ?? [],
      dataWrapperFirebase.activityEntries ?? [],
    );

    final DataWrapper dataWrapperToApply = DataWrapper(
      appSettings: appSettingsFromSharedPreferences,
      activityTypeCollection: joinedActivityTypeCollection,
      activityEntries: joinedActivityEntries,
      favoriteActivityTypes: dataWrapperSharedPreferences.favoriteActivityTypes,
      hiddenActivityTypes: {}
    );

    dataWrapperToApply.loadToProviders(stateReader);
    dataWrapperToApply.saveDataToSharedPreferencesAndFirebaseWithId(stateReader);
    
    prefs.setString(firebaseUserIdKey, userId);
  }
}