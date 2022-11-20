import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CustomColorPicker extends AlertDialog {
  CustomColorPicker({
    required this.context,
    required this.startColor,
    required this.setColor,
    super.key
  }): super(
    title: const Text('Pick a color!'),
    content: SingleChildScrollView(
      child: ColorPicker(
        pickerColor: startColor,
        onColorChanged: setColor,
      ),
    ),
    actions: <Widget>[
      ElevatedButton(
        child: const Text('Got it'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ]
  );

  final BuildContext context;
  final Color startColor;
  final void Function(Color) setColor;
}