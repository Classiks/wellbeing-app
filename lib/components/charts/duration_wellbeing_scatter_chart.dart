import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/dataclasses/activity_type_summary.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/components/charts/axis_bounds.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/dataclasses/color_gradient.dart';
import 'package:wellbeing/components/charts/wellbeing_axis_ticks.dart';
import 'package:wellbeing/components/charts/duration_axis_ticks.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';
import 'package:wellbeing/components/reusable/color_gradient_from_settings.dart';


class DurationWellbeingScatterChart extends ConsumerWidget {
  const DurationWellbeingScatterChart({
    super.key,
    required this.summaryList,
    required this.types,
    required this.xAxisBounds,
    required this.yAxisBounds
  });
  
  final List<ActivityTypeSummary> summaryList;
  final ActivityTypeCollection types;
  final AxisBounds xAxisBounds;
  final AxisBounds yAxisBounds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);
    final ColorGradient colorGradient = colorGradientFromAppSettings(appSettings);

    final List<ScatterSpot> points = summaryList.map(((e) => ScatterSpot(
      e.durationSum,
      e.wellbeingAverage,
      color: types.getColorByIdOrNull(e.id),
          radius: 10,
    ))).toList();

    final Set<int> selectedSpots = ref.watch(timeScatterSelectedSpotsProvider);


    return ScatterChart(
        ScatterChartData(
          scatterSpots: points,
          minX: xAxisBounds.lowerWithPadding,
          maxX: xAxisBounds.higherWithPadding,
          minY: yAxisBounds.lowerWithPadding,
          maxY: yAxisBounds.higherWithPadding,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: const Text("Wellbeing"),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text("Duration (in Minutes)")
            ),
            rightTitles: WellbeingAxis(colorGradient),
            topTitles: DurationAxis(xAxisBounds.lowerWithPadding, xAxisBounds.higherWithPadding)
          ),
          
          showingTooltipIndicators: selectedSpots.toList(),
          scatterTouchData: ScatterTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            mouseCursorResolver:
                (FlTouchEvent touchEvent, ScatterTouchResponse? response) {
              return response == null || response.touchedSpot == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click;
            },
            touchTooltipData: ScatterTouchTooltipData(
              tooltipBgColor: Colors.black,
              getTooltipItems: (ScatterSpot touchedBarSpot) {
                ActivityTypeSummary? summary = getActivityTypeFromDurationAndWellbeing(
                  summaryList,
                  touchedBarSpot.x,
                  touchedBarSpot.y
                );
                final String label = types
                  .getNameByIdOrReturnDefault(summary?.id ?? '');

                return ScatterTooltipItem(
                  label,
                  textStyle: TextStyle(
                    height: 1.2,
                    color: Colors.grey[100],
                    fontStyle: FontStyle.italic,
                  ),
                  bottomMargin: 10
                );
              },
            ),
            touchCallback: (FlTouchEvent event, ScatterTouchResponse? touchResponse) {
              if (touchResponse?.touchedSpot == null) {
                return;
              }
              if (event is FlTapUpEvent) {
                final int spotIndex = touchResponse!.touchedSpot!.spotIndex;
                if (selectedSpots.contains(spotIndex)) {
                  selectedSpots.remove(spotIndex);
                } else {
                  selectedSpots.add(spotIndex);
                }
                ref.read(timeScatterSelectedSpotsProvider.state).state = {...selectedSpots};
              }
            },
          ),
        ),
      );
  }
}

ActivityTypeSummary? getActivityTypeFromDurationAndWellbeing(
  List<ActivityTypeSummary> summaryList,
  double duration,
  double wellbeing
) {
  for (ActivityTypeSummary summary in summaryList) {
    if (summary.durationSum == duration && summary.wellbeingAverage == wellbeing) {
      return summary;
    }
  }

  return null;
}


