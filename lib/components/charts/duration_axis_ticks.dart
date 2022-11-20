import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class DurationAxis extends AxisTitles {
  DurationAxis(double lower, double higher, {bool showMinValue = false}) : super(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 35,
      interval: (higher-lower)/5, // why more than 6
      getTitlesWidget: (value, meta) => createDurationAxisTicks(value, meta, showMinValue)
    ),
  );
}


Widget createDurationAxisTicks(double value, TitleMeta meta, bool showMinValue) {
  if (value < 0 || value == meta.max) {
    return Container();
  }

  if (!showMinValue && value == meta.min) {
    return Container();
  }

  bool needsDecimal = (meta.max - meta.min) < 10;  // hardcoded 10 => same in Axis Classes
  int decimalPlaces = needsDecimal ? 1 : 0;

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(value.toStringAsFixed(decimalPlaces)),
  );
}