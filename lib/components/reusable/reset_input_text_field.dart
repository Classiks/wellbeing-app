import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';

void resetInputTextField(Reader stateReader) {
  final TextEditingController? controller = stateReader(inputTextFieldControllerProvider);
  if (controller == null) {
    return;
  }

  controller.text = "";
}
