import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/components/activity_logging/activity_type_option.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/components/activity_logging/optional_highlight_icon.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';


final StateProvider<bool> showAddNewActivityTypeButtonProvider = StateProvider((ref) => false);


class ActivityTypePickerWithInput extends ConsumerWidget {
  ActivityTypePickerWithInput({super.key, this.autofocus = true});

  final bool autofocus;
  late BuildContext buildContext;
  late Reader stateReader;
  late Reader stateWatcher;
  late ActivityTypeCollection activityTypes;
  late Set<String> favorites;
  late int numberOfFavorites;
  late List<ActivityTypePickerOptionWithHighlight> fullOptions;
  late FocusNode textFieldFocusNode;
  late bool showFavorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    buildContext = context;
    stateReader = ref.read;
    stateWatcher = ref.watch;
    activityTypes = ref.watch(activityTypeCollectionProvider);
    favorites = ref.watch(favoriteActivityTypesProvider);
    numberOfFavorites = favorites.length;

    final AppSettings appSettings = ref.watch(appSettingsProvider);
    showFavorites = appSettings.showFavoriteActivities;

    fullOptions = createPickerOptions();


    return Autocomplete(
      optionsBuilder: returnMatchingOptions, 
      displayStringForOption: (ActivityTypePickerOptionWithHighlight option) {
        return activityTypes.getNameByIdOrReturnDefault(option.activityTypeId);
      },
      onSelected: (ActivityTypePickerOptionWithHighlight option) => onOptionSelectedAndUnfocus(option.activityTypeId),
      fieldViewBuilder: buildTextField,
      optionsViewBuilder: buildOptionsWidgets
    );
  }

  void onOptionSelected(String id) {
    stateReader(activityTypeIdProvider.state).state = id;
    stateReader(showAddNewActivityTypeButtonProvider.state).state = false;
  }

  void onOptionSelectedAndUnfocus(String id) {
    onOptionSelected(id);
    textFieldFocusNode.unfocus();
  }
  
  FutureOr<Iterable<ActivityTypePickerOptionWithHighlight>> returnMatchingOptions(TextEditingValue value) {
    String text = value.text;
    if (text.isEmpty) return fullOptions;
    
    return fullOptions.where(
      (e) {
        final String nameLower = activityTypes
          .getNameByIdOrReturnDefault(e.activityTypeId)
          .toLowerCase();

        return nameLower.contains(text.toLowerCase());
      }
    );
  }

  List<ActivityTypePickerOptionWithHighlight> createPickerOptions() {
    List<ActivityTypePickerOption> options = activityTypes
      .values
      .map((e) => ActivityTypePickerOption(e.id, favorites.contains(e.id)))
      .toList();

    options.sort(
      (a, b) {
        String nameA = activityTypes.getNameByIdOrReturnDefault(a.activityTypeId);
        String nameB = activityTypes.getNameByIdOrReturnDefault(b.activityTypeId);
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      }  
    );

    Iterable<ActivityTypePickerOptionWithHighlight> optionOnTopHighlighted = options
      .where((e) => e.isFavorite)
      .map((e) => ActivityTypePickerOptionWithHighlight.fromBaseOption(e, true));

    Iterable<ActivityTypePickerOptionWithHighlight> optionsFullNotHighlighted = options
      .map((e) => ActivityTypePickerOptionWithHighlight.fromBaseOption(e, false));

    if (showFavorites) {
      return [...optionOnTopHighlighted, ...optionsFullNotHighlighted];
    }

    return optionsFullNotHighlighted.toList();

  }

  Widget buildTextField(
    BuildContext context, TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode, VoidCallback onFieldSubmitted
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stateReader(inputTextFieldControllerProvider.state).state = fieldTextEditingController;
    });
    textFieldFocusNode = fieldFocusNode;
    final bool showAddNewActivityTypeButton = stateWatcher(showAddNewActivityTypeButtonProvider);

    return TextField(
      controller: fieldTextEditingController,
      focusNode: fieldFocusNode,
      autofocus: autofocus,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
          suffixIcon: showAddNewActivityTypeButton
            ? AddNewActivityTypeButton(() {
              addNewActivityType(fieldTextEditingController.text);
            })
            : null
        ),
      onChanged: (value) => typing(value),
    );
  }

  void typing(String text) {
    String? existingName = activityTypes.getNameByNameOrNull(text);
    bool nameExists = existingName != null;
    
    final bool isNewActivityTypeAndNotEmpty = (
      !nameExists &&
      text.isNotEmpty
    );
    stateReader(showAddNewActivityTypeButtonProvider.state).state = isNewActivityTypeAndNotEmpty;

    if (nameExists) {
      ActivityType matchingActivityType = activityTypes.getByNameOrReturnDefault(existingName);
      onOptionSelected(matchingActivityType.id);
    } else {
      stateReader(activityTypeIdProvider.state).state = null;
    }
    
    stateReader(activityTypeNameInputProvider.state).state = existingName ?? text;
  }

  Widget buildOptionsWidgets(
    BuildContext context,
    AutocompleteOnSelected<ActivityTypePickerOptionWithHighlight> onSelected,
    Iterable<ActivityTypePickerOptionWithHighlight> options
  ) {
    ActivityTypeListView optionListView = ActivityTypeListView(
      options: options,
      separatorBuilder: separatorBuilder,
      itemBuilder: (BuildContext context, int index) {
        return itemBuilder(index, options, onSelected);
      }
    );

    return Align(
      alignment: Alignment.topLeft,
      child: Material(child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: OptionList(
          height: 400,
          backgroundColor: Theme.of(context).colorScheme.background,
          child: optionListView,
        ),
      ),),
    );
  }


  void addNewActivityType(String activityTypeName) {
    Set<String> existingIds = activityTypes.getExistingIds();
    String newId = createUniqueId(existingIds);
    onOptionSelectedAndUnfocus(newId);
  }

  Widget separatorBuilder(BuildContext context, int index) {
    if (showFavorites && index == numberOfFavorites-1) {
      return Divider(color: Theme.of(context).colorScheme.primary,);
    }
    return const Divider(color: Colors.grey,);
  }

  Widget itemBuilder(
    int index,
    Iterable<ActivityTypePickerOptionWithHighlight> options,
    AutocompleteOnSelected<ActivityTypePickerOptionWithHighlight> onSelected
  ) {
    final ActivityTypePickerOptionWithHighlight option = options.elementAt(index);
    return Option(
      activityTypes.getByIdOrReturnDefault(option.activityTypeId),
      option.doHighlight,
      onTap: () => onSelected(option)
    );
  }
}

class AddNewActivityTypeButton extends IconButton {
  const AddNewActivityTypeButton(VoidCallback addFunction, {super.key}) : super(
      icon: const Icon(Icons.add),
      onPressed: addFunction
  );
}

class Option extends GestureDetector {
  Option(
    ActivityType activityType,
    bool doHighlight,
    {
      super.key,
      super.onTap,
    }
  ) : super(
    behavior: HitTestBehavior.translucent,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(
          activityType.icon, 
          color: activityType.color,
        ),
        const SizedBox(width: 10,),
        Text(
          activityType.name,
        ),
        const SizedBox(width: 10,),
        const Expanded(child: SizedBox()),
        OptionalHighlightIcon(doHighlight)
      ],
    )
  );
}


class OptionList extends Container {
  OptionList({
    super.key,
    super.width,
    super.height,
    super.child,
    Color? backgroundColor
  }): super(
    decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(20))
      ),
  );
}


class ActivityTypeListView extends ListView {
  ActivityTypeListView({
    super.key,
    required this.options,
    required super.separatorBuilder,
    required super.itemBuilder
  }) : super.separated(
    padding: const EdgeInsets.all(10.0),
    itemCount: options.length,
  );

  final Iterable<ActivityTypePickerOptionWithHighlight> options;
}



