import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/providers_and_settings/keys_for_save_and_load.dart';

class ShowcaseHistory {
  static const firstRunKey = 'firstRun';
  static const firstTimeDashboardActivityKey = 'firstTimeDashboardActivity';
  static const firstTimeDashboardTimesKey = 'firstTimeDashboardTimes';
  static const firstTimeEntryHistoryKey = 'firstTimeEntryHistory';
  static const firstTimeActivityListKey = 'firstTimeActivityList';
  static const firstTimeSettingsKey = 'firstTimeSettings';


  ShowcaseHistory({
    required this.firstRun, 
    required this.firstTimeDashboardActivity, 
    required this.firstTimeDashboardTimes,
    required this.firstTimeEntryHistory,
    required this.firstTimeActivityList,
    required this.firstTimeSettings,
  });

  ShowcaseHistory.fresh() :
    firstRun = false,
    firstTimeDashboardActivity = false,
    firstTimeDashboardTimes = false,
    firstTimeEntryHistory = false,
    firstTimeActivityList = false,
    firstTimeSettings = false;
  
  ShowcaseHistory.fromMap(Map<String, dynamic> map) :
    firstRun = checkIfBoolDefaultFalse(map[firstRunKey]),
    firstTimeDashboardActivity = checkIfBoolDefaultFalse(map[firstTimeDashboardActivityKey]),
    firstTimeDashboardTimes = checkIfBoolDefaultFalse(map[firstTimeDashboardTimesKey]),
    firstTimeEntryHistory = checkIfBoolDefaultFalse(map[firstTimeEntryHistoryKey]),
    firstTimeActivityList = checkIfBoolDefaultFalse(map[firstTimeActivityListKey]),
    firstTimeSettings = checkIfBoolDefaultFalse(map[firstTimeSettingsKey]);
  

  bool firstRun;
  bool firstTimeDashboardActivity;
  bool firstTimeDashboardTimes;
  bool firstTimeEntryHistory;
  bool firstTimeActivityList;
  bool firstTimeSettings;

  Map<String, bool> toMap() {
    return {
      firstRunKey: firstRun,
      firstTimeDashboardActivityKey: firstTimeActivityList,
      firstTimeDashboardTimesKey: firstTimeDashboardTimes,
      firstTimeEntryHistoryKey: firstTimeEntryHistory,
      firstTimeActivityListKey: firstTimeActivityList,
      firstTimeSettingsKey: firstTimeSettings
    };
  }

  String toJSON() {
    return jsonEncode(toMap());
  }

  void saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(firstRunInfoKey, toJSON());
  }

  @override
  String toString() {
    String out = "";
    toMap().forEach((key, value) => out += "$key: $value\n",);
    return "----\n$out----\n";
  }
}

bool checkIfBoolDefaultFalse(dynamic input) {
  if (input is bool) return input;
  return false;
}


ShowcaseHistory showcaseHistoryFromSharedPreferences(SharedPreferences prefs) {
  final String? showcaseHistoryString = prefs.getString(firstRunInfoKey);

  if (showcaseHistoryString == null) {
    return ShowcaseHistory.fresh();
  }

  return ShowcaseHistory.fromMap(jsonDecode(showcaseHistoryString));
}