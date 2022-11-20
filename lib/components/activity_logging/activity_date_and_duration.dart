import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/components/reusable/set_input.dart';
import 'package:wellbeing/components/reusable/reset_date_and_duration.dart';


class ActivityDateAndDuration extends ConsumerWidget {
  const ActivityDateAndDuration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resetDateAndDuration(ref.read);
    });

    return Column(children: const [
      DatePicker(),
      SizedBox(height: 10,),
      DurationPicker()
    ],);
  }
}






class DatePicker extends SetInput {
  const DatePicker({super.key}) : super(
      label: 'Date',
      input: const DateButton()
  );
}


class DateButton extends ConsumerWidget {
  const DateButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime today = DateTime.now();
    final DateTime todayStart = DateTime(today.year, today.month, today.day);
    final DateTime selectedDate = ref.watch(selectedDateProvider);
    final String selectedDateString = DateFormat.yMd().format(selectedDate);
    final DateTimeRange dateRangeForSelection = ref.read(dateRangeForSelectionBounds);

    return ElevatedButton(
        onPressed: () async {
          final DateTime? date = await showDatePicker(
            context: context,
            initialDate: todayStart,
            firstDate: dateRangeForSelection.start,
            lastDate: dateRangeForSelection.end,
            helpText: 'Select a date'
          );

          if (date == null) return;

          ref.read(selectedDateProvider.state).state = date;
        },
        child: Text(selectedDateString)
      );
  }
}


class DurationPicker extends SetInput {
  const DurationPicker({super.key}): super(
      label: 'Duration',
      input: const DurationButton()
  );
}

class DurationButton extends ConsumerWidget {
  const DurationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int startDuration = ref.watch(selectedDurationProvider);

    return ElevatedButton(
      onPressed: () async {
        final Duration? duration = await showDurationPicker(
          context: context,
          initialTime: Duration(minutes: startDuration),
        );

        if (duration == null) return;

        final int durationInMinutes = duration.inMinutes;

        ref.read(selectedDurationProvider.state).state = durationInMinutes;
      },
      child: Text('${ref.watch(selectedDurationProvider)} Minutes')
    );
  }
}



