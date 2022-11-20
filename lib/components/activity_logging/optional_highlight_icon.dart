import 'package:flutter/material.dart';

class OptionalHighlightIcon extends StatelessWidget {
  const OptionalHighlightIcon(this.doHighlight, {super.key});

  final bool doHighlight;

  @override
  Widget build(BuildContext context) {
    if (doHighlight) {
      return const Icon(
        Icons.favorite,
        color: Colors.red
      );
    }

    return Container();
  }
}