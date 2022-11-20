import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/reusable/reset_date_and_duration.dart';
import 'package:wellbeing/components/reusable/reset_input_text_field.dart';
import 'package:wellbeing/dataclasses/icon_list.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/components/reusable/custom_color_picker.dart';
import 'package:wellbeing/components/reusable/set_input.dart';
import 'package:wellbeing/components/reusable/reset_id_and_score.dart';


class ActivityCreationOrChange extends StatelessWidget {
  const ActivityCreationOrChange({
    super.key,
    required this.startingActivityTypeName,
    required this.doAddEntry
  });

  final String startingActivityTypeName;
  final bool doAddEntry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: NewActivitySettingsContent(
        startText: startingActivityTypeName,
        doAddEntry: doAddEntry,
      )),
    );
  }
}

class NewActivitySettingsContent extends ConsumerWidget {
  NewActivitySettingsContent({
    super.key,
    required this.startText,
    required this.doAddEntry
  }) {
    nameTextController = TextEditingController(
      text: startText
    );
  }

  final String startText;
  final bool doAddEntry;

  late final TextEditingController nameTextController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IconData selectedIcon = ref.watch(iconProvider);
    final Color selectedColor = ref.watch(colorProvider);

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      TextField(
        controller: nameTextController,
        onChanged: (value) => ref.read(activityTypeNameInputProvider.state).state = value,
      ),
      SetInput(
        label: 'Icon',
        input: IconButton(
          icon: Icon(selectedIcon, color: selectedColor,),
          onPressed: () => showDialog(
              context: context,
              builder: (context) => IconPicker(context),
          )
        )
      ),
      SetInput(
        label: 'Color',
        input: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: selectedColor),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => CustomColorPicker(
              context: context,
              startColor: selectedColor,
              setColor: (Color color) => ref.read(colorProvider.state).state = color
            )
          ),
          child: const SizedBox(),
        )
      ),
      ButtonRow(doAddEntry: doAddEntry,)
    ],);
  }
}



class ButtonRow extends StatelessWidget {
  const ButtonRow({required this.doAddEntry, super.key});

  final bool doAddEntry;

  @override
  Widget build(BuildContext context) {
    return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
        const PopButton(),
        OkayButton(doAddEntry: doAddEntry,)
      ]
    );
  }
}

class OkayButton extends ConsumerWidget {
  const OkayButton({required this.doAddEntry, super.key});

  final bool doAddEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        final ActivityTypeCollection activityTypeCollection = ref.read(activityTypeCollectionProvider);

        final String? activityTypeId = ref.read(activityTypeIdProvider);

        if (activityTypeId == null) return;

        final String activityTypeName = ref.read(activityTypeNameInputProvider);
        final Set<String> existingNamesLower = activityTypeCollection
          .getExistingNames()
          .map((e) => e.toLowerCase())
          .toSet();
        final bool nameExists = existingNamesLower.contains(activityTypeName.toLowerCase());
        final bool currentNameExistisDueToEditing = activityTypeName.toLowerCase() == activityTypeCollection.getNameByIdOrReturnDefault(activityTypeId).toLowerCase();
        final bool nameExistsAndNotEditing = nameExists && !currentNameExistisDueToEditing;

        if (nameExistsAndNotEditing || activityTypeName.isEmpty) {
          const SnackBar snackBar = SnackBar(
            content: Text("Activity Type Name already exists or is empty. Please choose new Name."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          return;
        }

        activityTypeCollection[activityTypeId] = ActivityType(
          id: activityTypeId,
          name: activityTypeName,
          color: ref.read(colorProvider),
          icon: ref.read(iconProvider),
        );

        final newActivityTypeCollection = ActivityTypeCollection({...activityTypeCollection.delegate});
        newActivityTypeCollection.saveToSharedPreferencesAndFirebaseWithId(ref.read);
        ref.read(activityTypeCollectionProvider.state).state = newActivityTypeCollection;
        
        if (doAddEntry) {
          addActivityEntry(ref.read);
        }
        resetIDandScore(ref.read);
        resetDateAndDuration(ref.read);
        resetInputTextField(ref.read);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: const Text("Okay")
    );
  }
}

class PopButton extends ConsumerWidget {
  const PopButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("Back")
    );
  }
}




class IconPicker extends AlertDialog {
  IconPicker(BuildContext context, {super.key}) : super(
    title: const Text('Pick an Icon'),
    content: Container(
      width: 320,
      height: 400,
      alignment: Alignment.center,
      child: IconGridView.builder()
    ),
    actions: [
      ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'))
    ],
  );
}


class IconGridView extends GridView {
  IconGridView.builder({super.key}) : super.builder(
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 60,
      childAspectRatio: 1 / 1,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10
    ),
    itemCount: iconList.length,
    itemBuilder: (_, index) => IconItem(index: index)
  );
}


class IconItem extends ConsumerWidget {
  
  const IconItem({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color selectedColor = ref.watch(colorProvider);

    return Container(
      key: ValueKey(iconList[index].codePoint),
      padding: const EdgeInsets.all(10),
      child: Center(
        child: IconButton(
          color: selectedColor,
          iconSize: 30,
          icon: Icon(
            iconList[index],
          ),
          onPressed: () {
            ref.read(iconProvider.state).state = iconList[index];
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
