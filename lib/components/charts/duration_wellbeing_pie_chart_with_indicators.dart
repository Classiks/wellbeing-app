import 'package:flutter/material.dart';
import 'package:wellbeing/components/charts/duration_wellbeing_pie_chart.dart';
import 'package:wellbeing/components/reusable/rich_text_adaptive.dart';
import 'package:wellbeing/components/reusable/shorten_name.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/dataclasses/activity_type_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/dataclasses/color_gradient.dart';
import 'package:wellbeing/components/reusable/color_gradient_from_settings.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';

class DurationWellbeingPieChartWithIndicators extends ConsumerWidget {
  const DurationWellbeingPieChartWithIndicators({
    super.key,
    required this.summaryList,
    required this.types
  });

  final List<ActivityTypeSummary> summaryList;
  final ActivityTypeCollection types;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.read(appSettingsProvider);
    final ColorGradient colorGradient = colorGradientFromAppSettings(appSettings); 
    final double totalDuration = summaryList.fold(
      0, 
      (double sum, ActivityTypeSummary summary) => sum + summary.durationSum
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: LayoutBuilder(
              builder: (_, constraints) => DurationWellbeingPieChart(
                summaryList: summaryList,
                types: types,
                showLabels: false,
                constraints: constraints,
              ),
            ),
          ),
          Column(
            children: [
              ...summaryList
                .map((e) {
                  final ActivityType type = types.getByIdOrReturnDefault(e.id);              
                  return Indicator(
                    typeColor: type.color,
                    wellbeingColor: colorGradient.getColorAtPercentOpaque(e.wellbeingAverage),
                    name: type.name,
                    wellbeingAverage: e.wellbeingAverage,
                    timeShare: e.durationSum/totalDuration,
                  );
                })
                .toList(),
                const SizedBox(height: 50,)
            ]
          )
        ],
      ),
    );
  }
}


class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.typeColor,
    required this.wellbeingColor,
    required this.name,
    required this.wellbeingAverage,
    required this.timeShare
  });

  final String name;
  final Color typeColor;
  final Color wellbeingColor;
  final double wellbeingAverage;
  final double timeShare;

  @override
  Widget build(BuildContext context) {
    final String timeSharePercentString = (timeShare*100).toStringAsFixed(2);
    final String wellbeingAverangeString = wellbeingAverage.toStringAsFixed(2);
    final String shortName = shortenName(name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Spacer(),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: wellbeingColor,
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          RichTextAdaptive(
            children: [
              TextSpan(
                text: shortName,
                style: TextStyle(
                  color: typeColor,
                ),
              ),
              const TextSpan(text: ' (WB '),
              TextSpan(
                text: wellbeingAverangeString,
                style: TextStyle(
                  color: wellbeingColor,
                ),
              ),
              TextSpan(text: '; % Time: $timeSharePercentString%)'),
            ]
          ),
          const Spacer(),
        ],
      ),
    );
  }
}