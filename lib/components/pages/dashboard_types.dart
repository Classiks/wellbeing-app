import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/dashboard_elements/date_filter_input.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/components/charts/no_data_for_chart_info.dart';
import 'package:wellbeing/components/charts/axis_bounds.dart';
import 'package:wellbeing/components/dashboard_elements/activity_type_selector.dart';
import 'package:wellbeing/dataclasses/activity_entry.dart';
import 'package:wellbeing/components/charts/type_duration_wellbeing_scatter_chart.dart';
import 'dart:math';


class DashboardTime extends ConsumerWidget {
  const DashboardTime({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        DateFilterInput(),
        const ActivityTypeSelector(),
        const ChartDisplay(),
      ],
    );
  }
}

class ChartDisplay extends ConsumerWidget {
  const ChartDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ActivityEntry> entries = ref.watch(activityEntriesProvider);
    final DateTimeRange? dateFilter = ref.watch(dateRangeFilterProvider);
    final String? activityTypeSelectedId = ref.watch(activityTypeSelectedIdProvider);
    final Set<String> hiddenTypes = ref.watch(hiddenActivityTypesProvider);


    if (activityTypeSelectedId == null || hiddenTypes.contains(activityTypeSelectedId)) {
      return const NoDataForChartInfo();
    }

    final Iterable<ActivityEntry> entriesFilteredByDate = dateFilter == null
      ? entries
      : entries
        .where((e) => !(
          e.date.isBefore(dateFilter.start) ||
          e.date.isAfter(dateFilter.end))    
    );
    
    final List<ActivityEntry> entriesFiltered = entriesFilteredByDate
      .where((e) => e.activityTypeId == activityTypeSelectedId)
      .toList();

    if (entriesFiltered.isEmpty) {
      return const NoDataForChartInfo();
    }

    final double minDurationInMin = getDurationInMinMinimumFromEntryList(entriesFiltered);
    final double maxDurationInMin = getDurationInMinMaximumFromEntryList(entriesFiltered);

    final AxisBounds durationBounds = AxisBounds(minDurationInMin, maxDurationInMin);
    final AxisBounds wellbeingBounds = AxisBounds(minWellbeingScore, maxWellbeingScore);

    return Flexible(
      child: AspectRatio(
        aspectRatio: 1,
        child: TypeDurationWellbeingScatterChart(
          entryList: entriesFiltered,
          xAxisBounds: durationBounds,
          yAxisBounds: wellbeingBounds
        )
      ),
    );
  }
}



double getDurationInMinMinimumFromEntryList(List<ActivityEntry> entryList) {
  return entryList
    .map(((e) => e.durationInMinutes))
    .reduce(min)
    .toDouble();
}

double getDurationInMinMaximumFromEntryList(List<ActivityEntry> summaryList) {
  return summaryList
    .map(((e) => e.durationInMinutes))
    .reduce(max)
    .toDouble();
}