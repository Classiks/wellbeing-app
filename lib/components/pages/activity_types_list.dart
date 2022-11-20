import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/components/reusable/shorten_name.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/dataclasses/show_case_history.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/dataclasses/activity_entry.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:wellbeing/components/pages/activity_creation_or_change.dart';
import 'package:wellbeing/providers_and_settings/showcase_texts.dart';
import 'package:showcaseview/showcaseview.dart';


class ActivityTypesList extends ConsumerWidget {
  const ActivityTypesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      ShowcaseHistory showcaseHistory = showcaseHistoryFromSharedPreferences(prefs);

      if (showcaseHistory.firstTimeActivityList) return;

      // ignore: use_build_context_synchronously
      ShowCaseWidget.of(context).startShowCase([
        globalKeyAddTypeButton
      ]);

      showcaseHistory.firstTimeActivityList = true;
      showcaseHistory.saveToSharedPreferences();
    });

    final ActivityTypeCollection activityTypeCollection = ref.watch(activityTypeCollectionProvider);

    if (activityTypeCollection.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No activity types have been created yet."),
            const Text("Create one by pressing the button below."),
            const SizedBox(height: 20,),
            Showcase(
              key: globalKeyAddTypeButton,
              description: addTypeButtonShowcaseText,
              child: AddNewActivityTypeButton(types: activityTypeCollection,)
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HideAllButton(typeIds: activityTypeCollection.keys,),
          ...activityTypeCollection.values.map(
            (e) => ActivityTypeProfile(e)
          ),
          const SizedBox(height: 40,),
          AddNewActivityTypeButton(types: activityTypeCollection,),
          const SizedBox(height: 20,),
        ]
      ),
    );
  }
}


class AddNewActivityTypeButton extends ConsumerWidget {
  const AddNewActivityTypeButton({required this.types, super.key});

  final ActivityTypeCollection types;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
          onPressed: () {
            Set<String> existingIds = types.getExistingIds();
            final String newId = createUniqueId(existingIds);
            ref.read(activityTypeIdProvider.state).state = newId;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ActivityCreationOrChange(
                  startingActivityTypeName: '',
                  doAddEntry: false,
                )
              )
            );
          },
          child: const Text('Add Activity Type'),
        );
  }
}

class HideAllButton extends ConsumerWidget {
  const HideAllButton({super.key, required this.typeIds});

  final Iterable<String> typeIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Set<String> hiddenActivityTypes = ref.watch(hiddenActivityTypesProvider);
    final bool allHidden = !typeIds.any((e) => !hiddenActivityTypes.contains(e));

    return Row(
      children: [
        IconButton(
          icon: Icon(allHidden ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            if (allHidden) {
              hiddenActivityTypes = {};
            } else {
              hiddenActivityTypes.addAll(typeIds);
            }
            saveHiddenActivityTypesToSharedPreferencesAndFirebaseWithId(hiddenActivityTypes, ref.read);
            ref.read(hiddenActivityTypesProvider.state).state = {...hiddenActivityTypes};
          },
        ),
        Expanded(child: Container())
      ],
    );
  }
}


class ActivityTypeProfile extends ConsumerWidget {
  const ActivityTypeProfile(this.activityType, {super.key});

  final ActivityType activityType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Set<String> hiddenActivityTypes = ref.watch(hiddenActivityTypesProvider);
    final bool isHidden = hiddenActivityTypes.contains(activityType.id);
    final String shortendName = shortenName(activityType.name);


    return Row(
      children: [
        IconButton(
          icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            if (isHidden) {
              hiddenActivityTypes.remove(activityType.id);
            } else {
              hiddenActivityTypes.add(activityType.id);
            }
            saveHiddenActivityTypesToSharedPreferencesAndFirebaseWithId(hiddenActivityTypes, ref.read);
            ref.read(hiddenActivityTypesProvider.state).state = {...hiddenActivityTypes};
          },
        ),
        const SizedBox(width: 10,),
        Icon(activityType.icon, color: activityType.color,),
        const SizedBox(width: 10,),
        Text(shortendName),
        Expanded(child: Container(),),
        EditActivityTypeButton(type: activityType),
        const SizedBox(width: 10,),
        DeleteActivityTypeButton(type: activityType),
        const SizedBox(width: 20,)
      ]
    );
  }
}


class DeleteActivityTypeButton extends ConsumerWidget {
  const DeleteActivityTypeButton({required this.type, super.key});

  final ActivityType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => openDeleteDialog(context, ref.read),
      child: const Text("Delete")
    );
  }

  void openDeleteDialog(BuildContext context, Reader stateReader) {
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
            Text("Delete ${type.name}?\nThis will also delete all entries of this type."),
            const SizedBox(height: 10,),
            SlideAction(
              onSubmit: () => onSlideComplete(context, stateReader),
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

  void onSlideComplete(BuildContext context, Reader stateReader) {
    final ActivityTypeCollection activityTypeCollection = stateReader(activityTypeCollectionProvider);
    activityTypeCollection.remove(type.id);
    updateFavorites(stateReader);
    // Todo Update with firebase
    activityTypeCollection.saveToSharedPreferencesAndFirebaseWithId(stateReader);
    stateReader(activityTypeCollectionProvider.state).state = ActivityTypeCollection({...activityTypeCollection});

    final List<ActivityEntry> activityEntries = stateReader(activityEntriesProvider);
    final List<ActivityEntry> activitiesFiltered = activityEntries.where((e) => !(e.activityTypeId == type.id)).toList();
    saveEntriesToSharedPreferencesAndFirebaseWithId(activitiesFiltered, stateReader);
    stateReader(activityEntriesProvider.state).state = activitiesFiltered;

    final Set<String> hiddenActivityTypes = stateReader(hiddenActivityTypesProvider);
    hiddenActivityTypes.remove(type.id);
    saveHiddenActivityTypesToSharedPreferencesAndFirebaseWithId(hiddenActivityTypes, stateReader);
    stateReader(hiddenActivityTypesProvider.state).state = {...hiddenActivityTypes};

    stateReader(activityTypeSelectedIdProvider.state).state = null;

    updateFavorites(stateReader);

    Navigator.of(context).pop();
  }
}


class EditActivityTypeButton extends ConsumerWidget {
  const EditActivityTypeButton({required this.type, super.key});

  final ActivityType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        ref.read(iconProvider.state).state = type.icon;
        ref.read(colorProvider.state).state = type.color;
        ref.read(activityTypeIdProvider.state).state = type.id;
        ref.read(activityTypeNameInputProvider.state).state = type.name;

        Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ActivityCreationOrChange(
          startingActivityTypeName: type.name,
          doAddEntry: false,
        )),
      );
      },
    );
  }
}