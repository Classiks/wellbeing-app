class ActivityTypePickerOption {
  ActivityTypePickerOption(this.activityTypeId, this.isFavorite);
  
  String activityTypeId;
  bool isFavorite;
}

class ActivityTypePickerOptionWithHighlight extends ActivityTypePickerOption {
  ActivityTypePickerOptionWithHighlight(super.activityTypeId, super.isFavorite, this.doHighlight);

  ActivityTypePickerOptionWithHighlight.fromBaseOption(ActivityTypePickerOption baseEntry, this.doHighlight) : super(
    baseEntry.activityTypeId,
    baseEntry.isFavorite
  );

  final bool doHighlight;
}