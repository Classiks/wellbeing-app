import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wellbeing/dataclasses/color_gradient.dart';


class WellbeingAxis extends AxisTitles {
  WellbeingAxis(ColorGradient gradient) : super(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 35,
      interval: 20,
      getTitlesWidget: (value, meta) => createWellbeingAxisTicks(value, meta, gradient)
    ),
  );
}

Widget createWellbeingAxisTicks(double value, TitleMeta meta, ColorGradient gradient) {
  if (value < 0 || value > 100) {
    return Container();
  }
  
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 10,
    child: Text(
      value.toStringAsFixed(0),
      style: TextStyle(
        color: gradient.getColorAtPercentOpaque(value)
      ),
    ),
  );
}
