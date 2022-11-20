import 'package:flutter/material.dart';
import 'package:wellbeing/dataclasses/activity_type_summary.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/dataclasses/color_gradient.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wellbeing/components/reusable/color_gradient_from_settings.dart';


class DurationWellbeingPieChart extends ConsumerWidget {
  const DurationWellbeingPieChart({
    super.key,
    required this.summaryList,
    required this.types,
    this.showLabels = true,
    required this.constraints,
  });

  final List<ActivityTypeSummary> summaryList;
  final ActivityTypeCollection types;
  final bool showLabels;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);
    final ColorGradient colorGradient = colorGradientFromAppSettings(appSettings); 


    final double circleRadius = constraints.maxWidth > constraints.maxHeight
      ? constraints.maxHeight * 0.3
      : constraints.maxWidth * 0.3;


    return PieChart(
      PieChartData(
        startDegreeOffset: 0,
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: 1,
        centerSpaceRadius: 0,
        sections: summaryList.reversed.map((summary) {
          return PieChartSectionData(
            color: colorGradient.getColorAtPercentOpaque(summary.wellbeingAverage),
            value: summary.durationSum,
            title: types.getNameByIdOrReturnDefault(summary.id),
            showTitle: showLabels,
            radius: circleRadius,
            titleStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          );
        }).toList()
      )
    );
  }
}