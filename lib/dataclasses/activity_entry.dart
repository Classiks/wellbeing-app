import 'dart:convert';
import 'package:wellbeing/providers_and_settings/keys_for_save_and_load.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/providers_and_settings/firebase_helpers.dart';

class ActivityEntry {
  ActivityEntry({
    required this.activityTypeId,
    required this.durationInMinutes,
    required this.date,
    required this.wellbeingScore
  });

  ActivityEntry.fromMap(Map<String, dynamic> map) :
    activityTypeId = map['activityTypeId'],
    durationInMinutes = map['durationInMinutes'],
    date = DateTime.fromMillisecondsSinceEpoch(map['date']),
    wellbeingScore = map['wellbeingScore'] is int
      ? map['wellbeingScore'].toDouble()
      : map['wellbeingScore'];

  String activityTypeId;
  int durationInMinutes;
  DateTime date;
  double wellbeingScore;

  Map<String, dynamic> toMap() {
    return {
      'activityTypeId': activityTypeId,
      'durationInMinutes': durationInMinutes,
      'date': date.millisecondsSinceEpoch,
      'wellbeingScore': wellbeingScore
    };
  }

  String toJSONString() {
    return jsonEncode(toMap());
  }

  @override
  String toString() {
    return 'ActivityEntry{activityTypeId: $activityTypeId, durationInMinutes: $durationInMinutes, date: $date, wellbeingScore: $wellbeingScore}';
  }

  @override
  bool operator ==(Object other) {
    ActivityEntry otherEntry = other as ActivityEntry;
    return activityTypeId == otherEntry.activityTypeId &&
      durationInMinutes == otherEntry.durationInMinutes &&
      date == otherEntry.date &&
      wellbeingScore == otherEntry.wellbeingScore;
  }

  @override
  int get hashCode => activityTypeId.hashCode ^
    durationInMinutes.hashCode ^
    date.hashCode ^
    wellbeingScore.hashCode;
}

Future<void> saveEntriesToSharedPreferences(List<ActivityEntry> entries) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final List<String> entriesAsJSON = entries.map((e) => e.toJSONString()).toList();
  prefs.setStringList(activityEntriesKey, entriesAsJSON);
}

void saveEntriesToFirebaseWithId(List<ActivityEntry> entries, Reader stateReader) async {
  final String? userId = stateReader(userIdFirebaseProvider);
    if (userId != null) {
      final List<String> entriesAsStringList = entries.map((e) => e.toJSONString()).toList();
      setValueToFirebase('$usersKey/$userId/$activityEntriesKey', entriesAsStringList);
  }
}

Future<void> saveEntriesToSharedPreferencesAndFirebaseWithId(List<ActivityEntry> entries, Reader stateReader) async {
  await saveEntriesToSharedPreferences(entries);
  saveEntriesToFirebaseWithId(entries, stateReader);
}


List<ActivityEntry> joinEntryLists(List<ActivityEntry> list1, List<ActivityEntry> list2) {
  final List<ActivityEntry> joinedList = [...list1];
  for (final ActivityEntry entry in list2) {
    if (!joinedList.contains(entry)) {
      joinedList.add(entry);
    }
  }

  return joinedList;
}