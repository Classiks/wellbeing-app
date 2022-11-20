import 'package:flutter/material.dart';
import 'package:wellbeing/dataclasses/activity_entry.dart';

Map<String, ActivityTypeSummary> summarizedByActivityType(List<ActivityEntry> entries, DateTimeRange? dateRange, [Set<String>? activityTypesToExclude]) {
  Map<String, ActivityTypeSummary> summarizedMap = {};
  for (ActivityEntry entry in entries) {
    if (dateRange != null) {
      if (entry.date.isBefore(dateRange.start) || entry.date.isAfter(dateRange.end)) {
        continue;
      }
    }

    if (activityTypesToExclude != null) {
      if (activityTypesToExclude.contains(entry.activityTypeId)) {
        continue;
      }
    }

    if (!summarizedMap.keys.contains(entry.activityTypeId)) {
      summarizedMap[entry.activityTypeId] = ActivityTypeSummary.createNew(
        id: entry.activityTypeId,
        wellbeing: entry.wellbeingScore, durationInMinutes: entry.durationInMinutes
      );
    } else {
      summarizedMap[entry.activityTypeId]?.addValues(wellbeing: entry.wellbeingScore, durationInMinutes: entry.durationInMinutes);
    }
  }

  return summarizedMap;
}

class ActivityTypeSummary {
  ActivityTypeSummary({
    required this.id,
    required this.wellbeingValues,
    required this.durationInMinutesValues
  });

  ActivityTypeSummary.createNew({
    required this.id,
    required double wellbeing,
    required int durationInMinutes
  }) :
    wellbeingValues = [wellbeing],
    durationInMinutesValues = [durationInMinutes] {
      wellbeingAverage = wellbeing;
      durationSum = durationInMinutes.toDouble();
    }

  final String id;
  List<double> wellbeingValues;
  List<int> durationInMinutesValues;
  double durationSum = 0;
  double wellbeingAverage = 0;

  void addValues({
    required double wellbeing,
    required int durationInMinutes
  }) {
    wellbeingValues.add(wellbeing);
    durationInMinutesValues.add(durationInMinutes);

    wellbeingAverage = getWellbeingAverage();
    durationSum = getDurationSum();
  }

  int countValues() => wellbeingValues.length;

  double getWellbeingSum() => wellbeingValues.reduce((a, b) => a + b);

  double getWellbeingAverage() {
    final int count = countValues();
    final double sum = getWellbeingSum();
    return sum / count;
  }
  
  double getDurationSum() => durationInMinutesValues.reduce((a, b) => a + b).toDouble();

  double getDurationAverage() {
    final int count = countValues();
    final double sum = getDurationSum();
    return sum / count;
  }
}
