import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';


class DateFilterInput extends Column {
  DateFilterInput({super.key}) : super(
    children: const [
      SizedBox(height: 20,),
      DateSpanText(),
      SizedBox(height: 10,),
      // DateFilterRow(),
      DateFilterDropdown(),
      SizedBox(height: 20,),
    ]
  );
}


class DateSpanText extends ConsumerWidget {
  const DateSpanText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTimeRange? dateRange = ref.watch(dateRangeFilterProvider);

    final String displayString = dateRangeToString(dateRange);


    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.calendar_month),
        const SizedBox(width: 5),
        Text(displayString),
      ],
    );
  }
}

String dateRangeToString(DateTimeRange? dateRange) {
  if (dateRange == null) {
    return "All Time";
  }

  final DateFormat formatter = DateFormat.yMd();

  if (dateRange.start == dateRange.end) {
    return formatter.format(dateRange.start);
  }

  return '${formatter.format(dateRange.start)} - ${formatter.format(dateRange.end)}';
}

const List<DateRangeButtonFeature> buttonFeatures = [
  DateRangeButtonFeature(text: "All Time", function: setDateRangeNull),
  DateRangeButtonFeature(text: "Today", function: setDateRangeToday),
  DateRangeButtonFeature(text: "Week", function: setDateRangeToWeek),
  DateRangeButtonFeature(text: "Month", function: setDateRangeToMonth),
  DateRangeButtonFeature(text: 'Selected Date Range', function: setDateRangeToRange),
];

class DateFilterDropdown extends ConsumerWidget {
  const DateFilterDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int indexSelected = ref.watch(dateRangeButtonSelectedIndexProvider);

    final List<DropdownMenuItem<int>> dropdownItems = [];

    for (int i = 0; i < buttonFeatures.length; i++) {
      dropdownItems.add(DropdownMenuItem(
        value: i,
        child: Text(buttonFeatures[i].text),
      ));
    }

    return DropdownButton(
      value: indexSelected,
      items: dropdownItems,
      onChanged: (i) {
        if (i is! int) return;
        buttonFeatures[i].function(i, ref.read, context);
        ref.read(dateRangeButtonSelectedIndexProvider.state).state = i;
      }
    );
  }
}


class DateFilterRow extends ConsumerWidget {
  const DateFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const VerticalDivider verticalDivider = VerticalDivider();

    List<Widget> buttonsWithSpace = [];

    for (int i = 0; i < buttonFeatures.length; i++) {
      buttonsWithSpace.add(SetDateRangeButton(
        keyIndex: i,
        onPressed: buttonFeatures[i].function,
        label: buttonFeatures[i].text,
      ));
      buttonsWithSpace.add(verticalDivider);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(children: buttonsWithSpace),
    );
  }
}

class DateRangeButtonFeature {
  const DateRangeButtonFeature({
    required this.function,
    required this.text,
  });

  final void Function(int, Reader, BuildContext) function;
  final String text;
}

class SetDateRangeButton extends ConsumerWidget {
  const SetDateRangeButton({super.key, required this.label, required this.keyIndex, required this.onPressed});

  final String label;
  final int keyIndex;
  final void Function(int, Reader, BuildContext) onPressed;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int indexSelected = ref.watch(dateRangeButtonSelectedIndexProvider);
    final bool isSelected = keyIndex == indexSelected;

    return ElevatedButton(
      onPressed: () {
        onPressed(keyIndex, ref.read, context);
        ref.read(dateRangeButtonSelectedIndexProvider.state).state = keyIndex;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ?
          Theme.of(context).colorScheme.primary :
          Colors.grey,
      ),
      child: Text(label)
    );
  }
}

void setDateRangeToday(int index, Reader stateReader, BuildContext context) {
  final DateTime now = DateTime.now();
  final DateTime todayStart = DateTime(now.year, now.month, now.day);

  stateReader(dateRangeFilterProvider.state).state = DateTimeRange(
    start: todayStart,
    end: todayStart
  );
}

void setDateRangeToWeek(int index, Reader stateReader, BuildContext context) {
  final DateTime now = DateTime.now();
  final DateTime todayStart = DateTime(now.year, now.month, now.day);
  final DateTime oneWeekBack = todayStart.subtract(const Duration(days: 6));

  stateReader(dateRangeFilterProvider.state).state = DateTimeRange(
    start: oneWeekBack,
    end: todayStart
  );
}

void setDateRangeToMonth(int index, Reader stateReader, BuildContext context) {
  final DateTime now = DateTime.now();
  final DateTime todayStart = DateTime(now.year, now.month, now.day);
  final DateTime oneWeekBack = todayStart.subtract(const Duration(days: 30));

  stateReader(dateRangeFilterProvider.state).state = DateTimeRange(
    start: oneWeekBack,
    end: todayStart
  );
}

void setDateRangeNull(int index, Reader stateReader, BuildContext context) {
  stateReader(dateRangeFilterProvider.state).state = null;
}


void setDateRangeToRange(int index, Reader stateReader, BuildContext context) async {
  final DateTimeRange? currentDateRange = stateReader(dateRangeSelectorProvider);
  final DateTimeRange dateRangeForSelection = stateReader(dateRangeForSelectionBounds);


  final DateTimeRange? dateRange = await showDateRangePicker(
    context: context,
    firstDate: dateRangeForSelection.start,
    lastDate: dateRangeForSelection.end,
    initialDateRange: currentDateRange
  );

  if (dateRange == null) return;

  stateReader(dateRangeSelectorProvider.state).state = dateRange;
  stateReader(dateRangeFilterProvider.state).state = dateRange;
}



