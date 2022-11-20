import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/dataclasses/color_gradient.dart';
import 'package:wellbeing/components/charts/axis_bounds.dart';
import 'package:wellbeing/components/charts/duration_axis_ticks.dart';
import 'package:wellbeing/components/charts/wellbeing_axis_ticks.dart';
import 'package:wellbeing/dataclasses/activity_entry.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';
import 'package:wellbeing/components/reusable/color_gradient_from_settings.dart';


class TypeDurationWellbeingScatterChart extends ConsumerWidget {
  const TypeDurationWellbeingScatterChart({
    super.key,
    required this.entryList,
    required this.xAxisBounds,
    required this.yAxisBounds
  });
  
  final List<ActivityEntry> entryList;
  final AxisBounds xAxisBounds;
  final AxisBounds yAxisBounds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);
    final ColorGradient colorGradient = colorGradientFromAppSettings(appSettings);

    final List<ScatterSpot> points = entryList.map(((e) => ScatterSpot(
      e.durationInMinutes.toDouble(),
      e.wellbeingScore,
      color: colorGradient.getColorAtPercentOpaque(e.wellbeingScore)
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



