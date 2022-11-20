import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/reusable/reset_date_and_duration.dart';
import 'package:wellbeing/components/reusable/reset_input_text_field.dart';
import 'package:wellbeing/dataclasses/activity_type.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/components/activity_logging/activity_date_and_duration.dart';
import 'package:wellbeing/components/activity_logging/activity_type_picker_with_input.dart';
import 'package:wellbeing/components/pages/activity_creation_or_change.dart';
import 'package:wellbeing/components/reusable/wellbeing_selection.dart';
import 'package:wellbeing/components/reusable/reset_id_and_score.dart';

class Logger extends ConsumerWidget {
  const Logger({super.key});

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) => resetIDandScore(ref.read));

    return const Scaffold(
      body: Center(child: LoggerContent()),
    );
  }
}


class LoggerContent extends StatelessWidget {
  const LoggerContent({super.key, this.padding = false, this.autofocus = true, this.cancelButton = true});

  final bool padding;
  final bool autofocus;
  final bool cancelButton;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: Container()),
      ActivityTypePickerWithInput(autofocus: autofocus),
      const SizedBox(height: 20,),
      const ActivityDateAndDuration(),
      const SizedBox(height: 20,),
      LayoutBuilder(
        builder: (context, constraints) => WellbeingSelection(constraints: constraints, id: 'from_home_screen',)
      ),
      const SizedBox(height: 20,),
      ButtonRow(cancelButton: cancelButton),
      padding
        ? const SizedBox(height: 50,)
        : Container(),
    ],);
  }
}

class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key, this.cancelButton = true});

  final bool cancelButton;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            cancelButton
              ? const CancelButton()
              : const SizedBox(),
            const Spacer(),
            const OkayButton()
          ],
        ),
      ),
    );
  }
}


class CancelButton extends ConsumerWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
          resetIDandScore(ref.read);
          resetDateAndDuration(ref.read);
          Navigator.of(context).pop();
      },
      child: const Text("Cancel"),
    );
  }
}

class OkayButton extends ConsumerWidget { 
  const OkayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        final String? activityTypeId = ref.read(activityTypeIdProvider);

        if (activityTypeId == null) {
          const SnackBar snackBar = SnackBar(
            content: Text("Select Acitivity Type or add a new one (with the + Button)"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          return;
        }

        final ActivityTypeCollection activityTypes = ref.read(activityTypeCollectionProvider);
        final bool activityExists = activityTypes
          .getExistingIds()
          .contains(activityTypeId);

        if (!activityExists) {
          final String activityTypeName = ref.read(activityTypeNameInputProvider);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ActivityCreationOrChange(
              startingActivityTypeName: activityTypeName,
              doAddEntry: true,
            )),
          );
        } else {
          addActivityEntry(ref.read);
          resetIDandScore(ref.read);
          resetDateAndDuration(ref.read);
          resetInputTextField(ref.read);
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: const Text('Okay')
    );
  }
}





