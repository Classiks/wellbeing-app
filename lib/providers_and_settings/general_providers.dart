import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  
import 'package:wellbeing/dataclasses/activity_entry.dart';
import 'package:wellbeing/dataclasses/show_case_history.dart';
import 'package:wellbeing/providers_and_settings/keys_for_save_and_load.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/providers_and_settings/firebase_helpers.dart';




final DateTime today = DateTime.now();
final DateTime todayStart = DateTime(today.year, today.month, today.day);

// Activity Entries
final StateProvider<List<ActivityEntry>> activityEntriesProvider = StateProvider((ref) => [ ]);

void addActivityEntry(Reader stateReader) {
  String? activityTypeId = stateReader(activityTypeIdProvider);
  if (activityTypeId == null) return;

  final ActivityEntry newActivityType = ActivityEntry(
    activityTypeId: activityTypeId,
    date: stateReader(selectedDateProvider),
    durationInMinutes: stateReader(selectedDurationProvider),
    wellbeingScore: stateReader(wellbeingScoreProvider).value
  );

  
  final List<ActivityEntry> previousState = stateReader(activityEntriesProvider);
  final List<ActivityEntry> newState = [...previousState, newActivityType];
  saveEntriesToSharedPreferencesAndFirebaseWithId(newState, stateReader);
  stateReader(activityEntriesProvider.state).state = newState;
  updateFavorites(stateReader);
}

// Activity Types and Favorites
final StateProvider<ActivityTypeCollection> activityTypeCollectionProvider = StateProvider((ref) => ActivityTypeCollection({}));


final StateProvider<Set<String>> hiddenActivityTypesProvider = StateProvider((ref) => {});

Future<void> saveHiddenActivityTypesToSharedPreferences(Set<String> hiddenActivityTypes) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(hiddenActivityTypesKey, hiddenActivityTypes.toList());
}

void saveHiddenActivityTypesToFirebaseWithId(Set<String> hiddenActivityTypes, Reader stateReader)  {
    final String? userId = stateReader(userIdFirebaseProvider);
      if (userId != null) {
        setValueToFirebase('$usersKey/$userId/$hiddenActivityTypesKey', hiddenActivityTypes.toList());
    }
}

Future<void> saveHiddenActivityTypesToSharedPreferencesAndFirebaseWithId(Set<String> hiddenActivityTypes, Reader stateReader) async {
  await saveHiddenActivityTypesToSharedPreferences(hiddenActivityTypes);
  saveHiddenActivityTypesToFirebaseWithId(hiddenActivityTypes, stateReader);
}


final StateProvider<Set<String>> favoriteActivityTypesProvider = StateProvider((ref) => {});

Future<void> saveFavoriteActivityTypesToSharedPreferences(Set<String> favoriteActivityTypes) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(favoriteActivityTypesKey, favoriteActivityTypes.toList());
}

void saveFavoriteActivityTypesToFirebaseWithId(Set<String> favoriteActivityTypes, Reader stateReader)  {
    final String? userId = stateReader(userIdFirebaseProvider);
      if (userId != null) {
        setValueToFirebase('$usersKey/$userId/$favoriteActivityTypesKey', favoriteActivityTypes.toList());
    }
}

Future setFavoriteActivityTypesToSharedPreferencesAndFirebaseWithId(Set<String> favoriteActivityTypes, Reader stateReader) async {
  await saveFavoriteActivityTypesToSharedPreferences(favoriteActivityTypes);
  saveFavoriteActivityTypesToFirebaseWithId(favoriteActivityTypes, stateReader);
}


void updateFavorites(Reader stateReader) {
  final List<ActivityEntry> activityEntries = stateReader(activityEntriesProvider);

  final Map<String, int> counterMap = activityEntries.fold(
    {},
    (Map<String, int> previousValue, ActivityEntry element) {
      if (!previousValue.keys.contains(element.activityTypeId)) {
        previousValue[element.activityTypeId] = 1;
      } else {
        previousValue[element.activityTypeId] = previousValue[element.activityTypeId]! + 1;
      }

      return previousValue;
    }
  );

  final List<List> counterList = counterMap
    .entries
    .map((e) => [e.key, e.value])
    .toList();
  
  counterList.sort((a, b) => b[1] - a[1]);

  final Set<String> favoriteActivityTypes = counterList
    .take(3)
    .map((e) => e[0] as String)
    .toSet();
  
  setFavoriteActivityTypesToSharedPreferencesAndFirebaseWithId(favoriteActivityTypes, stateReader);
  stateReader(favoriteActivityTypesProvider.state).state = favoriteActivityTypes;
}


// Activity Entry Creation
const int defaultDuration = 30;
final StateProvider<DateTime> selectedDateProvider = StateProvider((ref) => todayStart);
final StateProvider<int> selectedDurationProvider = StateProvider((ref) => defaultDuration);
final StateProvider<String> activityTypeNameInputProvider = StateProvider((ref) => '');
final StateProvider<String?> activityTypeIdProvider = StateProvider((ref) => '');


// Activity Type Creation
final StateProvider<IconData> iconProvider = StateProvider((ref) => Icons.question_mark);
final StateProvider<Color> colorProvider = StateProvider((ref) => Colors.red);


// Wellbeing Score
class WellbeingScoreSource {
  const WellbeingScoreSource(this.value, [this.source]);

  final double value;
  final String? source;
}

const double minWellbeingScore = 0;
const double maxWellbeingScore = 100;
const double middleWellbeingScore = (minWellbeingScore+maxWellbeingScore) / 2;
final StateProvider<WellbeingScoreSource> wellbeingScoreProvider = StateProvider((ref) => const WellbeingScoreSource(middleWellbeingScore));



// Plot Providers
final StateProvider<Set<int>> timeScatterSelectedSpotsProvider = StateProvider((ref) => {});
final StateProvider<int> chartTypeIndexActivityProvider = StateProvider((ref) => 0);
final StateProvider<String?> activityTypeSelectedIdProvider = StateProvider((ref) => null);


// datefilter
final StateProvider<DateTimeRange?> dateRangeFilterProvider = StateProvider((ref) => null);
final StateProvider<DateTimeRange?> dateRangeSelectorProvider = StateProvider((ref) => null);

// Daterange Button Colors
final StateProvider<int> dateRangeButtonSelectedIndexProvider = StateProvider((ref) => 0);


// Daterange Bounds for Selection
final Provider<DateTimeRange> dateRangeForSelectionBounds = Provider(((ref) => DateTimeRange(
  start: DateTime(todayStart.year - 5, 01),
  end: DateTime(todayStart.year + 5, 12)
)));


// Icons for Tabs
const IconData iconDashboardSummaries = Icons.donut_large;
const IconData iconDashboardTypes = Icons.bar_chart;
const IconData iconEntryHistory = Icons.history;
const IconData iconTypeList = Icons.list;
const IconData iconTheoryHowTo = Icons.help;
const IconData iconSettings = Icons.settings;


final StateProvider<bool> userIsLoggedInProvider = StateProvider((ref) => true);
final StateProvider<String?> userIdFirebaseProvider = StateProvider((ref) => null);

final StateProvider<TextEditingController?> inputTextFieldControllerProvider = StateProvider((ref) => null);

final StateProvider<ShowcaseHistory> showcaseHistoryProvider = StateProvider((ref) => ShowcaseHistory.fresh(),);
final GlobalKey globalKeyFirstRunInfoButton = GlobalKey();
final GlobalKey globalKeyFloatingActionButton = GlobalKey();
final GlobalKey globalKeySettingsPage = GlobalKey();
final GlobalKey globalKeyAddTypeButton = GlobalKey();
