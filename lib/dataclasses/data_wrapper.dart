import 'package:firebase_database/firebase_database.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/dataclasses/activity_entry.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:wellbeing/providers_and_settings/keys_for_save_and_load.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class DataWrapper {
    DataWrapper({
        this.activityTypeCollection,
        this.activityEntries,
        this.favoriteActivityTypes,
        this.hiddenActivityTypes,
        this.appSettings,
    });

    ActivityTypeCollection? activityTypeCollection;
    List<ActivityEntry>? activityEntries;
    Set<String>? favoriteActivityTypes;
    Set<String>? hiddenActivityTypes;
    AppSettings? appSettings;

    DataWrapper.fromSharedPreferences(SharedPreferences prefs) {
      final String? settingsString = prefs.getString(settingsKey);
      if (settingsString != null) {
          final Map<String, dynamic> settingsMap = jsonDecode(settingsString) as Map<String, dynamic>;
          appSettings = convertAppSettings(settingsMap);
      }

      final String? activityTypesString = prefs.getString(activityTypesKey);
      if (activityTypesString != null) {
        final Map<String, dynamic> activityTypesMap = jsonDecode(activityTypesString);
        activityTypeCollection = convertActivityTypeCollection(activityTypesMap);
      }

      final List<String>? activityEntriesStringList = prefs.getStringList(activityEntriesKey);
      if (activityEntriesStringList != null) {
        activityEntries = convertActivityEntries(activityEntriesStringList);
      }

      final List<String>? hiddenActivityTypesStringList = prefs.getStringList(hiddenActivityTypesKey);
      if (hiddenActivityTypesStringList != null) {
        hiddenActivityTypes = convertHiddenActivityTypes(hiddenActivityTypesStringList);
      }

      final List<String>? favoriteActivityTypesStringList = prefs.getStringList(favoriteActivityTypesKey);
      if (favoriteActivityTypesStringList != null) {
        favoriteActivityTypes = convertFavoriteActivityTypes(favoriteActivityTypesStringList);
      }
    }

    static Future<DataWrapper> fromFirebase(FirebaseDatabase db, rootPath) async {
      final DataSnapshot settingsSnapshot = await db.ref('$rootPath/$settingsKey').get();
      final DataSnapshot activityTypesSnapshot = await db.ref('$rootPath/$activityTypesKey').get();
      final DataSnapshot activityEntriesSnapshot = await db.ref('$rootPath/$activityEntriesKey').get();
      final DataSnapshot hiddenActivityTypesSnapshot = await db.ref('$rootPath/$hiddenActivityTypesKey').get();
      final DataSnapshot favoriteActivityTypesSnapshot = await db.ref('$rootPath/$favoriteActivityTypesKey').get();

      return DataWrapper._fromFirebase(
        settingsSnapshot: settingsSnapshot,
        activityTypesSnapshot: activityTypesSnapshot,
        activityEntriesSnapshot: activityEntriesSnapshot,
        hiddenActivityTypesSnapshot: hiddenActivityTypesSnapshot,
        favoriteActivityTypesSnapshot: favoriteActivityTypesSnapshot,
      );
    }

    DataWrapper._fromFirebase({
      required DataSnapshot settingsSnapshot,
      required DataSnapshot activityTypesSnapshot,
      required DataSnapshot activityEntriesSnapshot,
      required DataSnapshot hiddenActivityTypesSnapshot,
      required DataSnapshot favoriteActivityTypesSnapshot,
    }) {
      if (settingsSnapshot.exists) {
          if (activityTypesSnapshot.value != null) {
            final Map<String, dynamic> settingsMap = Map<String, dynamic>.from(settingsSnapshot.value as Map);
            appSettings = convertAppSettings(settingsMap);
          }
      }
      
      if (activityTypesSnapshot.exists) {
          if (activityTypesSnapshot.value != null) {
            final Map<String, dynamic> activityTypesMap = Map<String, dynamic>.from(activityTypesSnapshot.value as Map);
            activityTypeCollection = convertActivityTypeCollection(activityTypesMap);
          }
      }
      
      if (activityEntriesSnapshot.exists) {
          final List<dynamic>? activityEntriesStringList = activityEntriesSnapshot.value as List<dynamic>?;
          if (activityEntriesStringList != null) {
            activityEntries = convertActivityEntries(activityEntriesStringList);
          }
      }
      
      if (hiddenActivityTypesSnapshot.exists) {
          final List<dynamic>? hiddenActivityTypesStringList = hiddenActivityTypesSnapshot.value as List<dynamic>?;
          if (hiddenActivityTypesStringList != null) {
            hiddenActivityTypes = convertHiddenActivityTypes(hiddenActivityTypesStringList);
          }

      }
      
      if (favoriteActivityTypesSnapshot.exists) {
          final List<dynamic>? favoriteActivityTypesStringList = favoriteActivityTypesSnapshot.value as List<dynamic>?;
          if (favoriteActivityTypesStringList != null) {
            favoriteActivityTypes = convertFavoriteActivityTypes(favoriteActivityTypesStringList);
          }
      }
    }

    void loadToProviders(Reader stateProvider) {
      if (appSettings != null) {
        stateProvider(appSettingsProvider.state).state = appSettings!;
      } else {
        stateProvider(appSettingsProvider.state).state = AppSettings.defaultSettings();
      }

      if (activityTypeCollection != null) {
        stateProvider(activityTypeCollectionProvider.state).state = activityTypeCollection!;
      } else {
        stateProvider(activityTypeCollectionProvider.state).state = ActivityTypeCollection({});
      }

      if (activityEntries != null) {
        stateProvider(activityEntriesProvider.state).state = activityEntries!;
      } else {
        stateProvider(activityEntriesProvider.state).state = [];
      }

      if (favoriteActivityTypes != null) {
        stateProvider(favoriteActivityTypesProvider.state).state = favoriteActivityTypes!;
      } else {
        stateProvider(favoriteActivityTypesProvider.state).state = {};
      }

      if (hiddenActivityTypes != null) {
        stateProvider(hiddenActivityTypesProvider.state).state = hiddenActivityTypes!;
      } else {
        stateProvider(hiddenActivityTypesProvider.state).state = {};
      }
    }


    AppSettings convertAppSettings(Map<String, dynamic> settingsMap) {
      return AppSettings.fromMap(settingsMap);
    }

    ActivityTypeCollection convertActivityTypeCollection(Map<String, dynamic> activityTypeCollectionMap) {
      final Map<String, ActivityType> activityTypesMapConverted = activityTypeCollectionMap
          .map((key, value) => MapEntry(key, ActivityType.fromMap(Map<String, dynamic>.from(value as Map))));
      return ActivityTypeCollection(activityTypesMapConverted);
    }

    List<ActivityEntry> convertActivityEntries(List<dynamic> activityEntriesList) {
      return activityEntriesList
        .map(((e) => jsonDecode(e) as Map<String, dynamic>))
        .map((e) => ActivityEntry.fromMap(e)).toList();
    }

    Set<String> convertFavoriteActivityTypes(List<dynamic> favoriteActivityTypesList) {
      return favoriteActivityTypesList
        .map((e) => e as String)
        .toSet();
    }

    Set<String> convertHiddenActivityTypes(List<dynamic> hiddenActivityTypesList) {
      return hiddenActivityTypesList
        .map((e) => e as String)
        .toSet();
    }

    Future<void> saveDataToSharedPreferences() async {
      await activityTypeCollection?.saveToSharedPreferences();
      if (activityEntries != null) {
        await saveEntriesToSharedPreferences(activityEntries!);
      }
      if (favoriteActivityTypes != null) {
        await saveFavoriteActivityTypesToSharedPreferences(favoriteActivityTypes!);
      }
      if (hiddenActivityTypes != null) {
        await saveHiddenActivityTypesToSharedPreferences(hiddenActivityTypes!);
      }
      await appSettings?.saveToSharedPreferences();
    }

    void saveDataToFirebaseWithId(stateReader) {
      activityTypeCollection?.saveToFirebaseWithId(stateReader);
      if (activityEntries != null) {
        saveEntriesToFirebaseWithId(activityEntries!, stateReader);
      }
      if (favoriteActivityTypes != null) {
        saveFavoriteActivityTypesToFirebaseWithId(favoriteActivityTypes!, stateReader);
      }
      if (hiddenActivityTypes != null) {
        saveHiddenActivityTypesToFirebaseWithId(hiddenActivityTypes!, stateReader);
      }
      appSettings?.saveToFirebaseWithId(stateReader);
    }
    
    Future<void> saveDataToSharedPreferencesAndFirebaseWithId(Reader stateReader) async {
      await saveDataToSharedPreferences();
      saveDataToFirebaseWithId(stateReader);
    }


}