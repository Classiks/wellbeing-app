import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';
import 'package:wellbeing/components/reusable/custom_color_picker.dart';
import 'package:wellbeing/components/reusable/set_input.dart';
import 'package:wellbeing/components/user_button/user_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/dataclasses/show_case_history.dart';


class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      ShowcaseHistory showcaseHistory = showcaseHistoryFromSharedPreferences(prefs);

      if (showcaseHistory.firstTimeSettings) return;

      // ignore: use_build_context_synchronously
      ShowCaseWidget.of(context).startShowCase([
        globalKeySettingsPage
      ]);

      showcaseHistory.firstTimeSettings = true;
      showcaseHistory.saveToSharedPreferences();
    });

    return Column(
      children: const [
        UserButtonRow(),
        Spacer(),
        Settings(),
        Spacer(),
      ],
    );
  }
}

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SetDarkModeInput(),
        SizedBox(height: 15,),
        SetShowFavoritesInput(),
        SizedBox(height: 15,),
        SetShowSmileyEyeBrowsInput(),
        SizedBox(height: 15,),
        SetSmileyGradientColorNegativeInput(),
        SizedBox(height: 15,),
        SetSmileyGradientColorPositiveInput()
      ],
    );
  }
}


class SetDarkModeInput extends ConsumerWidget {
  const SetDarkModeInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);

    return SetInput(
        label: "Dark Mode",
        input: Switch(
          value: appSettings.darkMode,
          onChanged: ((value) {
            appSettings.updateSetDarkMode(value, ref.read);
            appSettings.saveToSharedPreferencesAndFirebaseWithId(ref.read);
          }),
        )
      );
  }
}


class SetShowFavoritesInput extends ConsumerWidget {
  const SetShowFavoritesInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);

    return SetInput(
      label: "Show Favorite Activities",
      input: Switch(
        value: appSettings.showFavoriteActivities,
        onChanged: ((value) {
          appSettings.updateShowFavoriteActivities(value, ref.read);
          appSettings.saveToSharedPreferencesAndFirebaseWithId(ref.read);
        }),
      )
    );
  }
}


class SetShowSmileyEyeBrowsInput extends ConsumerWidget {
  const SetShowSmileyEyeBrowsInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);

    return SetInput(
      label: "Show Smiley Eye Brows",
      input: Switch(
        value: appSettings.showSmileyEyeBrows,
        onChanged: ((value) {
          appSettings.updateShowSmileyEyeBrows(value, ref.read);
          appSettings.saveToSharedPreferencesAndFirebaseWithId(ref.read);
        }),
      )
    );
  }
}


class SetSmileyGradientColorNegativeInput extends ConsumerWidget {
  const SetSmileyGradientColorNegativeInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);

    return SetInput(
      label: "Negative Smiley Color",
      input: ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => CustomColorPicker(
            context: context,
            startColor: appSettings.smileyGradientColorNegative,
            setColor: (Color color) {
              appSettings.updateSmileyGradientColorNegative(color, ref.read);
              appSettings.saveToSharedPreferencesAndFirebaseWithId(ref.read);
            }
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: appSettings.smileyGradientColorNegative,
        ),
        child: const Text("Set"),
      )
    );
  }
}

class SetSmileyGradientColorPositiveInput extends ConsumerWidget {
  const SetSmileyGradientColorPositiveInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);

    return SetInput(
      label: "Positive Smiley Color",
      input: ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => CustomColorPicker(
            context: context,
            startColor: appSettings.smileyGradientColorPositive,
            setColor: (Color color) {
              appSettings.updateSmileyGradientColorPositive(color, ref.read);
              appSettings.saveToSharedPreferencesAndFirebaseWithId(ref.read);
            }
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: appSettings.smileyGradientColorPositive,
        ),
        child: const Text("Set"),
      )
    );
  }
}

