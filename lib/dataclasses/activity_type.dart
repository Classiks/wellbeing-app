import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:quiver/collection.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/providers_and_settings/keys_for_save_and_load.dart';
import 'package:wellbeing/providers_and_settings/firebase_helpers.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';

class ActivityType {
  ActivityType({
    required this.id,
    required this.name,
    required this.color,
    this.icon = Icons.circle
  });

  final String id;
  String name;
  Color color;
  IconData icon;

  ActivityType.fromMap(Map<String, dynamic> map) :
    id = map['id'],
    name = map['name'],
    color = Color(map['color']),
    icon = IconData(map['icon'], fontFamily: 'MaterialIcons');

  @override
  String toString() {
    return 'ActivityType{id: $id, name: $name}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint
    };
  }

  bool equals(ActivityType other) {
    return id == other.id &&
      name == other.name &&
      color == other.color &&
      icon == other.icon;
  }
}


String createUniqueId(Set<String> existingIds) {
  const Uuid uuid = Uuid();

  String newId = uuid.v1();

  while (existingIds.contains(newId)) {
    newId = uuid.v1();
  } 

  return newId;
}


class ActivityTypeCollection extends DelegatingMap<String, ActivityType> {
  ActivityTypeCollection(this.delegate);
  
  @override
  final Map<String, ActivityType> delegate;

  final ActivityType defaultReturn = ActivityType(
    name: "Fallback Type",
    color: Colors.black,
    id: "FallbackID",
    icon: Icons.circle
  );

  ActivityType getByIdOrReturnDefault(String id) {
    return delegate[id] ?? defaultReturn;
  }

  String? getNameByIdOrNull(String id) => delegate[id]?.name;
  String getNameByIdOrReturnDefault(String id) => getByIdOrReturnDefault(id).name;
  
  Color? getColorByIdOrNull(String id) => delegate[id]?.color;
  Color getColorByIdOrReturnDefault(String id) => getByIdOrReturnDefault(id).color;
  
  IconData? getIconByIdOrNull(String id) => delegate[id]?.icon;
  IconData? getIconByIdOrReturnDefault(String id) => getByIdOrReturnDefault(id).icon;

  Set<String> getExistingIds() => delegate.keys.toSet();
  Set<String> getExistingNames() => delegate.values.map((e) => e.name).toSet();


  bool nameDoesExist(String nameCaseInsensitive) {
    Set<String> existingNamesLower = getExistingNames()
      .map((e) => e.toLowerCase(),)
      .toSet();

    bool doesExist = existingNamesLower.contains(nameCaseInsensitive.toLowerCase());
    return doesExist;
  }

  String? getNameByNameOrNull(String nameCaseInsensitive) {
    bool doesExist = nameDoesExist(nameCaseInsensitive);
    if (doesExist) {
      return getByNameOrReturnDefault(nameCaseInsensitive).name;
    }

    return null;
  }

  
  ActivityType getByNameOrReturnDefault(String nameCaseInsensitive) {
    for (ActivityType e in delegate.values) {
      if (e.name.toLowerCase() == nameCaseInsensitive.toLowerCase()) {
        return e;
      }
    }

    return defaultReturn;
  }

  Map<String, dynamic> toMap() {
    return delegate.map((key, value) => MapEntry(key, value.toMap()));
  }

  String toJSONString() {
    return jsonEncode(toMap());
  }
  
  Future<void> saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(activityTypesKey, toJSONString());
  }
  
  void saveToFirebaseWithId(stateReader) {
    final String? userId = stateReader(userIdFirebaseProvider);
      if (userId != null) {
        setValueToFirebase('$usersKey/$userId/$activityTypesKey', toMap());
    }
  }

  Future<void> saveToSharedPreferencesAndFirebaseWithId(stateReader) async {
    await saveToSharedPreferences();
    saveToFirebaseWithId(stateReader);
  }

  ActivityTypeCollection createAndReturnJoinedCollection(ActivityTypeCollection? other) {
    if (other == null) {
      return this;
    }

    Map<String, ActivityType> newMap = Map.from(delegate);
    newMap.addAll(other.delegate);
    return ActivityTypeCollection(newMap);
  }
}