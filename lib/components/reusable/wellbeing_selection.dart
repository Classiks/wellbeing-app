import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/dataclasses/color_gradient.dart';
import 'package:wellbeing/components/reusable/adaptive_smiley.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';

class WellbeingSelection extends ConsumerWidget {
  const WellbeingSelection({super.key, this.smileySize, this.constraints, required this.id});

  final double? smileySize;
  final BoxConstraints? constraints;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WellbeingScoreSource currentWellbeingScore = ref.watch(wellbeingScoreProvider);
    final AppSettings appSettings = ref.watch(appSettingsProvider);

    final double wellbeingScoreToDisplay = currentWellbeingScore.source == id
          ? currentWellbeingScore.value
          : middleWellbeingScore;

    double? smallerDimension;
    if (constraints == null) {
      smallerDimension = MediaQuery.of(context).size.width;
    } else {
      smallerDimension = constraints!.maxWidth < constraints!.maxHeight
          ? constraints!.maxWidth
          : constraints!.maxHeight;
    }

    return Column(children: [
      SmileyAdaptive(
        currentValue: wellbeingScoreToDisplay,
        minValue: minWellbeingScore,
        maxValue: maxWellbeingScore,
        size: smileySize != null
          ? smileySize!
          : smallerDimension * 0.5,
        hasEyebrows: appSettings.showSmileyEyeBrows,
        colorGradient: ColorGradient.fromTwoColors(
          appSettings.smileyGradientColorNegative,
          appSettings.smileyGradientColorPositive
        ),
      ),
      const SizedBox(height: 10,),
      Slider(
        value: wellbeingScoreToDisplay,
        min: minWellbeingScore,
        max: maxWellbeingScore,
        divisions: (maxWellbeingScore-minWellbeingScore).toInt(),
        onChanged: (value) {
          ref.read(wellbeingScoreProvider.state).state = WellbeingScoreSource(
            value,
            id
          );
        },
        label: currentWellbeingScore.value.toString(),
      )
    ],);
  }
}