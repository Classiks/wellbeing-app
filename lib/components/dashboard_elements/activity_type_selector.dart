import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';


class ActivityTypeSelector extends ConsumerWidget {
  const ActivityTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {    
    final String? activityTypeSelectedId = ref.watch(activityTypeSelectedIdProvider);
    final ActivityTypeCollection activityTypes = ref.watch(activityTypeCollectionProvider);
    final Set<String> hiddenTypes = ref.watch(hiddenActivityTypesProvider);
    final Iterable<ActivityType> activityTypesVisible = activityTypes.values.where((e) => !hiddenTypes.contains(e.id));
    final Set<String> existingIds = activityTypesVisible.map((e) => e.id).toSet();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activityTypeSelectedId == null || !existingIds.contains(activityTypeSelectedId)) {
        if (activityTypes.isEmpty) return;

        ref.read(activityTypeSelectedIdProvider.state).state = activityTypesVisible.first.id;
      }

      if (hiddenTypes.contains(activityTypeSelectedId)) {
        ref.read(activityTypeSelectedIdProvider.state).state = activityTypesVisible.first.id;
      }

    });

    if ( 
      !existingIds.contains(activityTypeSelectedId) ||
      activityTypeSelectedId == null ||
      activityTypesVisible.isEmpty ||
      hiddenTypes.contains(activityTypeSelectedId)
    ) {
      return Container();
    }

    return DropdownButton(
      value: activityTypeSelectedId,
      items: activityTypesVisible
        .map((e) => DropdownMenuItem(
          value: e.id,
          child: Row(
            children: [
              Icon(e.icon, color: e.color,),
              const SizedBox(width: 10,),
              Text(e.name),
            ]
          ),
        ))
        .toList(),
      onChanged: (value) {
        if (value is! String) return;
        ref.read(activityTypeSelectedIdProvider.state).state = value;
      }
    );
  }
}