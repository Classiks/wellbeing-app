import 'package:flutter/material.dart';
import 'dart:math';
import 'package:wellbeing/dataclasses/color_gradient.dart';

class SmileyAdaptive extends StatelessWidget {
  const SmileyAdaptive({
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.size,
    required this.colorGradient,
    required this.hasEyebrows,
    super.key
  });

  final double currentValue;
  final double minValue;
  final double maxValue;
  final double size;
  final ColorGradient colorGradient;
  final bool hasEyebrows;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: SmileyAdaptivePainter(
        currentValue: currentValue,
        minValue: minValue,
        maxValue: maxValue,
        paintAreaSize: size,
        colorGradient: colorGradient,
        hasEyebrows: hasEyebrows
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}



class SmileyAdaptivePainter extends CustomPainter {
  SmileyAdaptivePainter({
    required this.paintAreaSize,
    required this.hasEyebrows,
    required double currentValue,
    required double minValue,
    required double maxValue,
    required ColorGradient colorGradient
  }) {
    double valueInPercent = getPercentWithinRange(minValue, maxValue, currentValue);
    valueScaled_0_100 = valueInPercent*100;
    colorCalculated = colorGradient.getColorAtPercentOpaque(valueScaled_0_100);

    final double valueReversedAfter50 = reverseAt50(valueScaled_0_100);

    mouthAndEyebrowGeometry = 50-valueReversedAfter50;
  }

  final double paintAreaSize;
  final bool hasEyebrows;
  late final Color colorCalculated;
  late final double valueScaled_0_100;
  late final double mouthAndEyebrowGeometry;


  @override
  void paint(Canvas canvas, Size size) {
    drawHead(canvas);
    drawEyes(canvas);
    drawMouth(canvas);
    if (hasEyebrows) {
      drawEyebrows(canvas);
    }
  }

  void drawEyebrows(Canvas canvas) {
        final Paint eyebrowPaint = Paint()  
      ..strokeWidth = paintAreaSize/40
      ..color = colorCalculated
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final double eyeBrowYPositionBase = (0.17*paintAreaSize);
    double eyeBrowYPositionTarget = eyeBrowYPositionBase - mouthAndEyebrowGeometry * (paintAreaSize/450);
    final double eyeBrowArcRadius = 100 * (paintAreaSize / 200);

    final leftEyebrowPath = Path()
      ..moveTo(0.21*paintAreaSize, eyeBrowYPositionBase)
      ..arcToPoint(
          Offset(0.44*paintAreaSize, eyeBrowYPositionTarget),
          radius: Radius.circular(eyeBrowArcRadius),
          clockwise: true
      );

    final rightEyebrowPath = Path()
      ..moveTo(0.56*paintAreaSize, eyeBrowYPositionTarget)
      ..arcToPoint(
          Offset(0.79*paintAreaSize, eyeBrowYPositionBase),
          radius: Radius.circular(eyeBrowArcRadius),
          clockwise: true
      );


    canvas.drawPath(leftEyebrowPath, eyebrowPaint); 
    canvas.drawPath(rightEyebrowPath, eyebrowPaint);
  }

  void drawHead(Canvas canvas) {
    final Paint smileyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = paintAreaSize/20
      ..color = colorCalculated;

    Offset center = Offset(paintAreaSize/2, paintAreaSize/2);
    canvas.drawCircle(center, paintAreaSize/2, smileyPaint);
  }

  void drawEyes(Canvas canvas) {
    final Paint eyePaint = Paint()..color = colorCalculated;

    Offset leftEye = Offset(paintAreaSize/3, paintAreaSize/3);
    Offset rightEye = Offset(paintAreaSize-paintAreaSize/3, paintAreaSize/3);

    Rect leftEyeRect = Rect.fromCenter(center: leftEye, height: paintAreaSize/6.5, width: paintAreaSize/10.3);
    Rect rightEyeRect = Rect.fromCenter(center: rightEye, height: paintAreaSize/6.5, width: paintAreaSize/10.3);

    canvas.drawOval(leftEyeRect, eyePaint);
    canvas.drawOval(rightEyeRect, eyePaint);
  }

  void drawMouth(Canvas canvas) {
    final double xStart = 0.25*paintAreaSize;
    final double xEnd = 0.75*paintAreaSize;
    final double mouthWidth = xEnd - xStart;

    double currentRadius = calcCorrectRadius(mouthAndEyebrowGeometry, mouthWidth/2);

    final Paint mouthPaint = Paint()  
      ..strokeWidth = paintAreaSize/25
      ..color = colorCalculated
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double yPosition = (paintAreaSize*0.78) - valueScaled_0_100 * (paintAreaSize/600);
    final bool reverseSmile = valueScaled_0_100 < 50;

    final Path mouthPath = Path()
      ..moveTo(xStart, yPosition)
      ..arcToPoint(
          Offset(xEnd, yPosition),
          radius: Radius.circular(currentRadius),
          clockwise: reverseSmile
      );
    canvas.drawPath(mouthPath, mouthPaint); 
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


double getPercentWithinRange(double minValue, double maxValue, double currentValue) {
  double range = maxValue-minValue;
  double absoluteState = currentValue-minValue;

  return absoluteState/range;
}


double calcCorrectRadius(double x, double l) {
  // Formula R = (1/2x) * (l^2+x^2)
  // where R = Radius
  // l length of half the mouth
  // x = flexion

  double normedX = x*l/50;

  if (normedX == 0) { // Formula does not work with 0
    normedX = 0.00000001;
  } 

  double leadingDivision = 1 / (2*normedX);
  num multiplyBy = pow(l, 2) + pow(normedX, 2);
  double radius = leadingDivision * multiplyBy;

  return radius;
}

double reverseAt50(double value_0to100) {
  final bool isBelow50 = value_0to100 < 50;
  final double translatedValue = !isBelow50
    ? 100 - value_0to100
    : value_0to100;
  return translatedValue;
}