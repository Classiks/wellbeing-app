import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';


void resetDate(Reader stateReader) {
  stateReader(selectedDateProvider.state).state = todayStart;
}

void resetDuration(Reader stateReader) {
  stateReader(selectedDurationProvider.state).state = defaultDuration;
}

void resetDateAndDuration(Reader stateReader) {
  resetDate(stateReader);
  resetDuration(stateReader);
}