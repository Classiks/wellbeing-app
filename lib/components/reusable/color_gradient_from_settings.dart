import 'package:wellbeing/dataclasses/color_gradient.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';

ColorGradient colorGradientFromAppSettings(AppSettings settings) {
  return ColorGradient.fromTwoColors(
    settings.smileyGradientColorNegative,
    settings.smileyGradientColorPositive,
  );
}