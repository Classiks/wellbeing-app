import 'package:flutter/material.dart';

class RichTextAdaptive extends StatelessWidget {
  const RichTextAdaptive({super.key, required this.children});

  final List<InlineSpan> children;

  @override
  Widget build(BuildContext context) {
    final TextStyle adaptiveFontColor = TextStyle(color: Theme.of(context).colorScheme.onSurface);

    return RichText(
      text: TextSpan(
        children: children.map((el) {
            if (el is TextSpan) {
              return TextSpan(
                text: el.text,
                style: el.style ?? adaptiveFontColor,
                recognizer: el.recognizer,
              );
            } else {
              return el;
            }
          }).toList()
      )
    );
  }
}