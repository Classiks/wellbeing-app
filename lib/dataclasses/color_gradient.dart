import 'package:flutter/material.dart';

class RedToGreenColorGradient extends ColorGradient {
  RedToGreenColorGradient() : super.fromTwoColors(
    Colors.red.shade400,
    Colors.green.shade400
  );
}

class ColorGradient {
  ColorGradient({
    required this.redBounds,
    required this.greenBounds,
    required this.blueBounds
  });
  
  ColorGradient.fromTwoColors(Color startColor, Color endColor) {
    redBounds = ColorBounds(lowestRGB: startColor.red, highestRGB: endColor.red);
    greenBounds = ColorBounds(lowestRGB: startColor.green, highestRGB: endColor.green);
    blueBounds = ColorBounds(lowestRGB: startColor.blue, highestRGB: endColor.blue);
  }

  late final ColorBounds redBounds;
  late final ColorBounds greenBounds;
  late final ColorBounds blueBounds;

  Color getColorAtPercentWithAlpha(double percent, int alpha) {
    return Color.fromARGB(
      alpha,
      redBounds.getValueAtPercent(percent),
      greenBounds.getValueAtPercent(percent),
      blueBounds.getValueAtPercent(percent)
    );
  }

  Color getColorAtPercentOpaque(double percent) {
    return getColorAtPercentWithAlpha(percent, 255);
  }
}

class ColorBounds {
  const ColorBounds({this.lowestRGB = 0, this.highestRGB = 255});

  final int lowestRGB;
  final int highestRGB;

  int getValueAtPercent(double percent) {
    final double percentAsDecimal = percent/100;

    final int range = highestRGB-lowestRGB;
    final double valueDouble = lowestRGB + range*percentAsDecimal;
    return valueDouble.toInt();
  }
}
