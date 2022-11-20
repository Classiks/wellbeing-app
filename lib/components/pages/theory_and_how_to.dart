import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/components/reusable/rich_text_adaptive.dart';


class TheoryAndHowTo extends ConsumerWidget {
  const TheoryAndHowTo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeadingLevelOne('How to use this app'),
              const HeadingLevelTwo('Adding new Entries'),
              TextAddEntry(),
              const SizedBox(height: 20,),
              const HeadingLevelTwo('Adding new Activity Types'),
              TextAddType(),
              const SizedBox(height: 50,),
              const HeadingLevelOne('Theory'),
              const HeadingLevelTwo('Why to use this app'),
              ReasonToUseText(),
              const SizedBox(height: 20,),
              const HeadingLevelTwo('Availability and Prioritization'),
              AvailabilityVsPrioritizationText(),
              const SizedBox(height: 50,),
            ]
          ),
        ),
      ),
    );
  }
}




class TextAddType extends RichTextAdaptive {
  TextAddType({super.key}) : super(
    children: [
      const TextSpan(text: 'To add a new activity type, tap on the Activity Types List Tab (',),
      const WidgetSpan(child: Icon(iconTypeList), alignment: PlaceholderAlignment.middle),
      const TextSpan(text: ') and press the Add Activity Type or enter a new type into the textfield when logging a new entry via the floating action button (',),
      const WidgetSpan(child: Icon(Icons.add_circle), alignment: PlaceholderAlignment.middle),
      const TextSpan(text: ') and press the plus button (',),
      const WidgetSpan(child: Icon(Icons.add), alignment: PlaceholderAlignment.middle),
      const TextSpan(text: ') on the right site of the textfield. Color and Icon can be set afterwards.',),
    ]
  );
}

class TextAddEntry extends RichTextAdaptive {
  TextAddEntry({super.key}) : super(
    children: [
      const TextSpan(text: 'To add a new entry, tap on the floating action button (',),
      const WidgetSpan(child: Icon(Icons.add_circle), alignment: PlaceholderAlignment.middle),
      const TextSpan(text: ')',)
    ]
  );
}

class ReasonToUseText extends Column {
  ReasonToUseText({super.key}) : super(
    children: const [
      Text(
        "In todays fast pace times, it is sometimes hard to keep track of how you spend your time. Too often this leads to us spending our time mainly on things, that we don't enjoy or that result in discontentment later on (even if we are free to do whatever we want)."
      ),
      Text(
        "Even further, things that are supposed to be fun, like watching a movie or playing a game, can become a taxing if we do them too often. This is the case for many people with video games, for example."
      )
    ]
  );
}

class AvailabilityVsPrioritizationText extends Column {
  AvailabilityVsPrioritizationText({super.key}) : super(
    children: const [
      Text(
        "In the past, we had times during which we suffered from boredom. Things that where fun and useful were hard to come by. Today, we have access to endless amounts of entertainment, education, news, food delivery, amazon deliveries, ... The challenge no longer consists of getting access to enticing things but to decide where to put ones attention."
      ),
      Text(
        "In our age of information and consumption, it is an important skill to set ones priorities and act accordingly. We hope this app helps you develop a feeling for what you truely want to focus on"
      )
    ],
  );
}


class WellbeingVsPleasureText extends Column {
  WellbeingVsPleasureText({super.key}) : super(
    children: const [
      Text(
        ""
      )
    ],
  );
}


class HeadingLevelOne extends StatelessWidget {
  const HeadingLevelOne(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20) ,
      child: Center(
        child: Text(
          text,
          style: const HeadingStyleLevelOne()
        )
      ),
    );
  }
}

class HeadingLevelTwo extends StatelessWidget {
  const HeadingLevelTwo(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10) ,
      child: Text(
        text,
        style: const HeadingStyleLevelTwo()
      )
    );
  }
}

class HeadingStyleLevelOne extends TextStyle {
  const HeadingStyleLevelOne() : super(
    fontSize: 30,
    fontWeight: FontWeight.bold
  );
}

class HeadingStyleLevelTwo extends TextStyle {
  const HeadingStyleLevelTwo() : super(
    fontSize: 20,
    fontStyle: FontStyle.italic
  );
}