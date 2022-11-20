class AxisBounds {
  AxisBounds(this.lower, this.higher) {
    final double padding = get15PercentOfRange(lower, higher);
    lowerWithPadding = lower - padding;
    higherWithPadding = higher + padding;
  }

  final double lower;
  final double higher;
  late final double lowerWithPadding;
  late final double higherWithPadding;
}


get15PercentOfRange(double min, double max, [double minReturn = 1]) {
  final double padding = (max - min) * 0.15;
  return padding > minReturn ? padding : minReturn;
}