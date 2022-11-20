import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/charts/duration_wellbeing_pie_chart_with_indicators.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/dataclasses/activity_entry.dart';
import 'package:wellbeing/dataclasses/activity_type_summary.dart';
import 'package:wellbeing/components/dashboard_elements/date_filter_input.dart';
import 'package:wellbeing/components/charts/axis_bounds.dart';
import 'package:wellbeing/components/charts/duration_wellbeing_scatter_chart.dart';
import 'package:wellbeing/components/charts/no_data_for_chart_info.dart';
import 'package:wellbeing/components/charts/duration_wellbeing_bar_chart.dart';
import 'dart:math';
import 'package:showcaseview/showcaseview.dart';
import 'package:wellbeing/providers_and_settings/showcase_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/dataclasses/show_case_history.dart';



class DashboardActivityTime extends StatelessWidget {
  const DashboardActivityTime({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      ShowcaseHistory showcaseHistory = showcaseHistoryFromSharedPreferences(prefs);

      if (showcaseHistory.firstRun) return;

      // ignore: use_build_context_synchronously
      ShowCaseWidget.of(context).startShowCase([
        globalKeyFirstRunInfoButton,
        globalKeyFloatingActionButton
      ]);

      showcaseHistory.firstRun = true;
      showcaseHistory.firstTimeDashboardActivity = true;
      showcaseHistory.saveToSharedPreferences();
    });
    
    return Column(
      children: [
        DateFilterInput(),
        const DropdownAndInfoButton(),
        const ChartDisplay(),
        const SizedBox(height: 40),
      ],
    );
  }
}

class DropdownAndInfoButton extends StatelessWidget {
  const DropdownAndInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 25,),
          const ChartTypeDropdown(),
          Showcase(
            key: globalKeyFirstRunInfoButton,
            description: welcomeShowcaseText,
            child: const InfoButton()
          )
        ],
      ),
    );
  }
}

class InfoButton extends ConsumerWidget {
  const InfoButton({super.key});

  static List<String> infoTexts = [
    'This chart shows the duration in minutes (x-axis) and the average wellbeing scores (y-axis) of each activity in the selected time period.\n'
    'The color of the dots corresponds to the category color. You can display the category name by clicking or pressing on the dot.\n\n'
    'This chart allows you to see how much time you spend to activities that bring you wellbeing and how much on activities that don\'t.',

    'The upper chart displays the average wellbeing score for each activity in the selected time period.\n'
    'The lower chart displays the duration of each activity (in minutes) in the selected time period.\n'
    'The color of the bars corresponds to the category color. You can display the values by clicking or pressing on the bar.Bars are sorted by average wellbeing score.\n\n'
    'This chart allows you to see how much time you spend to activities that bring you wellbeing and how much on activities that don\'t.',

    'The slice size represents the time share an activity had in the selected time period. The color of the slices corresponds to the average wellbeing score in that time period\n'
    'Slices are sorted by the average wellbeing score in the selected time period. The indicators at the botton show the numerical information\n\n'
    'This chart allows you to see how much time you spend to activities that bring you wellbeing and how much on activities that don\'t.\n\n'
    'This chart does not work on mobile web due to issues with Flutter',
  ];
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int chartType = ref.watch(chartTypeIndexActivityProvider);

    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chart Info'),
          content: Text(infoTexts[chartType]),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}


class ChartDisplay extends ConsumerWidget {
  const ChartDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int chartTypeIndex = ref.watch(chartTypeIndexActivityProvider);
    final ActivityTypeCollection activityTypes = ref.watch(activityTypeCollectionProvider);
    final List<ActivityEntry> entries = ref.watch(activityEntriesProvider);
    final DateTimeRange? dateFilter = ref.watch(dateRangeFilterProvider);
    final Set<String> hiddenActivityTypes = ref.watch(hiddenActivityTypesProvider);
    final Map<String, ActivityTypeSummary> activityTypeSummaries = summarizedByActivityType(entries, dateFilter, hiddenActivityTypes);
    final List<ActivityTypeSummary> activityTypeSummaryList = activityTypeSummaries.values.toList();

    if (activityTypeSummaryList.isEmpty) {
      return const NoDataForChartInfo();
    }


    activityTypeSummaryList.sort((a, b) => (a.wellbeingAverage > b.wellbeingAverage) ? -1 : 1);


    final double minDurationInMin = getDurationInMinMinimumFromTypeSummaryList(activityTypeSummaryList);
    final double maxDurationInMin = getDurationInMinMaximumFromTypeSummaryList(activityTypeSummaryList);

    final AxisBounds durationBounds = AxisBounds(minDurationInMin, maxDurationInMin);
    final AxisBounds wellbeingBounds = AxisBounds(minWellbeingScore, maxWellbeingScore);

    
    List<Widget> charts = [
      DurationWellbeingScatterChart(
        summaryList: activityTypeSummaryList,
        types: activityTypes,
        xAxisBounds: durationBounds,
        yAxisBounds: wellbeingBounds
      ),
      BarChartColumn(
        summaryList: activityTypeSummaryList,
        types: activityTypes,
        durationBounds: durationBounds,
        wellbeingBounds: wellbeingBounds,
      ),
      DurationWellbeingPieChartWithIndicators(
        summaryList: activityTypeSummaryList,
        types: activityTypes
      ),
    ];


    return Flexible(
      fit: FlexFit.tight,
      child: charts[chartTypeIndex],
    );
  }
}





class ChartTypeDropdown extends ConsumerWidget {
  const ChartTypeDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int chartTypeIndex = ref.watch(chartTypeIndexActivityProvider);

    return DropdownButton(
      value: chartTypeIndex,
      items: const [
        DropdownMenuItem(
          value: 0,
          child: Icon(Icons.scatter_plot),
        ),
        DropdownMenuItem(
          value: 1,
          child: Icon(Icons.bar_chart),
        ),
        DropdownMenuItem(
          value: 2,
          child: Icon(Icons.pie_chart),
        ),
      ],
      onChanged: (value) {
        if (value is! int) return;
        ref.read(chartTypeIndexActivityProvider.state).state = value;
      }
    );
  }
}


double getDurationInMinMinimumFromTypeSummaryList(List<ActivityTypeSummary> summaryList) {
  return summaryList
    .map(((e) => e.durationSum))
    .reduce(min)
    .toDouble();
}

double getDurationInMinMaximumFromTypeSummaryList(List<ActivityTypeSummary> summaryList) {
  return summaryList
    .map(((e) => e.durationSum))
    .reduce(max)
    .toDouble();
}
