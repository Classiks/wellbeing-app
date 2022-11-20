import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing/components/reusable/reset_date_and_duration.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/dataclasses/activity_entry.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:wellbeing/components/activity_logging/activity_date_and_duration.dart';
import 'package:wellbeing/components/reusable/rich_text_adaptive.dart';
import 'package:wellbeing/components/reusable/wellbeing_selection.dart';


class ActivityEntryHistory extends ConsumerWidget {
  const ActivityEntryHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ActivityEntry> activityEntries = ref.watch(activityEntriesProvider);
    final ActivityTypeCollection activityTypes = ref.watch(activityTypeCollectionProvider);

    if (activityEntries.isEmpty) {
      return const Center(
        child: Text("No activity entries yet"),
      );
    }

    final List<Widget> activityEntryWidgets  = [];
    for (int i = activityEntries.length-1; i >= 0; i--) {
      activityEntryWidgets.add(
        LayoutBuilder(
          builder: (context, constraints) => ActivityEntryProfile(
            entries: activityEntries,
            types: activityTypes,
            index: i,
            parentWidth: constraints.maxWidth,
          ),
        )
      );
      activityEntryWidgets.add(const Divider());
    }


    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...activityEntryWidgets,
          const SizedBox(height: 50,),
        ]
      ),
    );
  }
}



class ActivityEntryProfile extends ConsumerWidget {
  ActivityEntryProfile({
    super.key,
    required this.entries,
    required this.types,
    required this.index,
    required this.parentWidth,
  });

  final List<ActivityEntry> entries;
  final ActivityTypeCollection types;
  final int index;
  final double parentWidth;

  late BuildContext buildContext;
  late Reader stateReader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    buildContext = context;
    stateReader = ref.read;

    final ActivityEntry entry = entries[index];
    final ActivityType type = types.getByIdOrReturnDefault(entry.activityTypeId);

    final double entryDescriptionWidth = parentWidth * 0.6;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: entryDescriptionWidth,
            child: Row(
              children: [
                Icon(type.icon, color: type.color,),
                const SizedBox(width: 10,),
                EntryDescriptionWithClickable(
                  entry: entry,
                  type: type,
                  typeFunction: openActivityTypeChangeDigalog,
                  dateFunction: openDateChangeDialog,
                  durationFunction: openDurationChangeDialog,
                  wellbeingFunction: openWellbeingChangeDialog,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10,),
          DeleteActivityTypeButton(
            entry: entry,
            type: type,
            removeEntryFunction: () {
              entries.removeAt(index);
              saveEntriesToSharedPreferencesAndFirebaseWithId(entries, stateReader);
              ref.read(activityEntriesProvider.state).state = [...entries];
              updateFavorites(ref.read);
            }
          ),
        ]
      ),
    );
  }

  
  void openActivityTypeChangeDigalog() {
    List<ActivityType> activityTypesAsList = types.values.toList();

    showDialog(
      context: buildContext,
      builder: (context) => AlertDialog(
        actions: [
          ElevatedButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Cancel"),
          ),
        ],
        content: SizedBox(
          height: 400,
          width: 400,
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: activityTypesAsList.length,
            itemBuilder: (context, itemIndex) {
              return GestureDetector(
                onTap: () {
                  final String newTypeId = activityTypesAsList[itemIndex].id;
                  entries[index].activityTypeId = newTypeId;
                  saveEntriesToSharedPreferencesAndFirebaseWithId(entries, stateReader);
                  stateReader(activityEntriesProvider.state).state = [...entries];
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 50,
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Text(activityTypesAsList[itemIndex].name)
                  )
                )
              );
            },
            separatorBuilder: (context, index) => const Divider()
          ),
      ))
    );
  }

  void openDateChangeDialog() {
    showDialog(
      context: buildContext,
      builder: (context) => AlertDialog(
        actions: [Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween ,
          children: [
            ElevatedButton(
              onPressed: () {
                resetDate(stateReader);
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final DateTime newDateTime = stateReader(selectedDateProvider);
                entries[index].date = newDateTime;
                saveEntriesToSharedPreferencesAndFirebaseWithId(entries, stateReader);
                stateReader(activityEntriesProvider.state).state = [...entries];
                resetDate(stateReader);
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          ]
      )],
        content: const SizedBox(
          height: 100,
          width: 200,
          child: DateButton(),
        ),
      ),
    );
  }

  void openDurationChangeDialog() {
    stateReader(selectedDurationProvider.state).state = entries[index].durationInMinutes;

    showDialog(
      context: buildContext,
      builder: (context) => AlertDialog(
        actions: [Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween ,
          children: [
            ElevatedButton(
              onPressed: () {
                resetDuration(stateReader);
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final int newDuration = stateReader(selectedDurationProvider);
                entries[index].durationInMinutes = newDuration;
                saveEntriesToSharedPreferencesAndFirebaseWithId(entries, stateReader);
                stateReader(activityEntriesProvider.state).state = [...entries];
                resetDuration(stateReader);
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          ]
      )],
        content: const SizedBox(
          height: 100,
          width: 200,
          child: DurationButton(),
        ),
      ),
    );
  }
  
  void openWellbeingChangeDialog() {
    stateReader(wellbeingScoreProvider.state).state = const WellbeingScoreSource(middleWellbeingScore);

    showDialog(
      context: buildContext,
      builder: (context) => AlertDialog(
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween ,
            children: [
              ElevatedButton(
                onPressed: Navigator.of(context).pop,
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final double newWellbeing = stateReader(wellbeingScoreProvider).value;
                  entries[index].wellbeingScore = newWellbeing;
                  saveEntriesToSharedPreferencesAndFirebaseWithId(entries, stateReader);
                  stateReader(activityEntriesProvider.state).state = [...entries];
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              ),
            ]
          )
        ],
        content: SizedBox(
          height: 400,
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => WellbeingSelection(constraints: constraints, id: 'from_entry_history',)
              )
            ]
          ),
        ),
      ),
    );
  }
}

class EntryDescriptionWithClickable extends StatelessWidget {
  const EntryDescriptionWithClickable({
    super.key,
    required this.entry,
    required this.type,
    required this.typeFunction,
    required this.dateFunction,
    required this.durationFunction,
    required this.wellbeingFunction,
  });


  final ActivityType type;
  final ActivityEntry entry;
  final VoidCallback typeFunction;
  final VoidCallback dateFunction;
  final VoidCallback durationFunction;
  final VoidCallback wellbeingFunction;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat.yMd();
    final String dateString = formatter.format(entry.date);

    final String wellbeingString = entry.wellbeingScore.round().toString();

    TextStyle standardColorTextStyle = TextStyle(
      fontSize: 20,
      color: Theme.of(context).colorScheme.onBackground,
    );

    TextStyle openOnTapTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontWeight: FontWeight.bold,
      fontSize: 20
    );

    return Flexible(
      child: RichTextAdaptive(
        children: [
          TextSpan(
            text: type.name,
            style: openOnTapTextStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = typeFunction
          ),
          TextSpan(
            text: "\non ",
            style: standardColorTextStyle
          ),
          TextSpan(
            text: dateString,
            style: openOnTapTextStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = dateFunction
          ),
          TextSpan(
            text: "\nfor ",
            style: standardColorTextStyle
          ),  
          TextSpan(
            text: "${entry.durationInMinutes} minutes.",
            style: openOnTapTextStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = durationFunction
          ),
          TextSpan(
            text: "\nWellbeing Score: ",
            style: standardColorTextStyle
          ),
          TextSpan(
            text: wellbeingString,
            style: openOnTapTextStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = wellbeingFunction
          )
        ]
      ),
    );
  }
}


class DeleteActivityTypeButton extends ConsumerWidget {
  const DeleteActivityTypeButton({
    super.key,
    required this.entry,
    required this.type,
    required this.removeEntryFunction,
  });

  final ActivityEntry entry;
  final ActivityType type;
  final VoidCallback removeEntryFunction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => openDeleteDialog(context, ref.read),
      child: const Text("Delete")
    );
  }

  void openDeleteDialog(BuildContext context, Reader stateReader) {
    final DateFormat formatter = DateFormat.yMd();
    final String dateString = formatter.format(entry.date);

    final String questionText = 
      "Delete the activity entry of Type ${type.name}?\n"
      "On $dateString for ${entry.durationInMinutes} minutes";

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actions: [
          ElevatedButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Cancel"),
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(questionText),
            const SizedBox(height: 10,),
            SlideAction(
              onSubmit: () {
                removeEntryFunction();
                Navigator.of(context).pop();
              },
              animationDuration: const Duration(milliseconds: 500),
              innerColor: Colors.red,
              outerColor: Theme.of(context).splashColor,
              text: "Delete"
            ),
          ],
        ),
      )
    );
  }
}



