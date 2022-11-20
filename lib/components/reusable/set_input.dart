import 'package:flutter/material.dart';

class SetInput extends StatelessWidget {
  const SetInput({required this.label, required this.input, super.key});

  final String label;
  final Widget input;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Padding(
        padding: 
        EdgeInsets.only(
          left: constraints.maxWidth*0.1, 
          right: constraints.maxWidth*0.1
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$label: '),
            input
          ]
        ),
      ),
    );
  }
}