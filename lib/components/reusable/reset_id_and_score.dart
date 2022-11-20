import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';

void resetIDandScore(Reader stateReader) {
    stateReader(activityTypeIdProvider.state).state = null;
    stateReader(wellbeingScoreProvider.state).state = const WellbeingScoreSource(middleWellbeingScore);
}