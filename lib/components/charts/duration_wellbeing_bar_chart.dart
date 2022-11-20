import 'package:flutter/material.dart';
import 'package:wellbeing/components/reusable/shorten_name.dart';
import 'package:wellbeing/dataclasses/activity_type_summary.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/components/charts/axis_bounds.dart';
import 'package:wellbeing/components/charts/duration_axis_ticks.dart';
import 'package:wellbeing/components/charts/wellbeing_axis_ticks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';
import 'package:wellbeing/dataclasses/color_gradient.dart';
import 'package:wellbeing/components/reusable/color_gradient_from_settings.dart';


class BarChartColumn extends ConsumerWidget {
  const BarChartColumn({
    super.key,
    required this.summaryList,
    required this.types,
    required this.durationBounds,
    required this.wellbeingBounds
  });

  final List<ActivityTypeSummary> summaryList;
  final ActivityTypeCollection types;
  final AxisBounds durationBounds;
  final AxisBounds wellbeingBounds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);
    final ColorGradient colorGradient = colorGradientFromAppSettings(appSettings); 

    final Size screenSize = MediaQuery.of(context).size;
    final double aspectRatio = screenSize.width / (screenSize.height*0.35);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: MetricBarChart(
              summaryList: summaryList,
              types: types,
              yAxisBounds: wellbeingBounds,
              yAxisTicks: WellbeingAxis(colorGradient),
              getMetric: (summary) => summary.getWellbeingAverage(),
              leftAxisText: "Wellbeing",	
            ),
          ),
          AspectRatio(
            aspectRatio: aspectRatio,
            child: MetricBarChart(
              summaryList: summaryList,
              types: types,
              yAxisBounds: durationBounds,
              yAxisTicks: DurationAxis(0, durationBounds.higherWithPadding, showMinValue: true),
              getMetric: (summary) => summary.getDurationSum(),
              leftAxisText: "Duration (in Minutes)",	
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}





class MetricBarChart extends ConsumerWidget {
  const MetricBarChart({
    super.key,
    required this.summaryList,
    required this.types,
    required this.getMetric,
    required this.yAxisBounds,
    required this.yAxisTicks,
    required this.leftAxisText
  });
  
  final List<ActivityTypeSummary> summaryList;
  final ActivityTypeCollection types;
  final AxisBounds yAxisBounds;
  final AxisTitles yAxisTicks;
  final double Function(ActivityTypeSummary) getMetric;
  final String leftAxisText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final int numTypes = summaryList.length;
    final bool rotateLabels = numTypes > 4;

    return BarChart(
        BarChartData(
          minY: 0,
          maxY: yAxisBounds.higherWithPadding,
          barGroups: summaryList.map((summary) {
            final int index = summaryList.indexOf(summary);

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: getMetric(summary),
                  width: 40,
                  color: types.getColorByIdOrReturnDefault(summary.id),
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  final ActivityTypeSummary summary = summaryList.elementAt(index);
                  final String name = types.getNameByIdOrReturnDefault(summary.id);

                  final String shortenedName = shortenName(name);

                  if (!rotateLabels) {
                    return Text(shortenedName);
                  }

                  return RotatedBox(
                    quarterTurns: 1,
                    child: Text(shortenedName),
                  );
                },
                reservedSize: rotateLabels
                  ? 80
                  : 23
              ),
            ),
            rightTitles: yAxisTicks,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(axisNameWidget: Text(leftAxisText),),
          )
        ),
      );
  }
}