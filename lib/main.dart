import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/components/pages/root.dart';
import 'package:flutter/services.dart';
import 'package:wellbeing/dataclasses/custom_themes.dart';
import 'package:wellbeing/providers_and_settings/settings.dart';
import 'package:wellbeing/providers_and_settings/on_load.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  container.read(loadDataProvider);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp()
  )); 
}
  

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    final AppSettings appSettings = ref.watch(appSettingsProvider);
    final bool setDarkMode = appSettings.darkMode;
    final ThemeData themeToUse = setDarkMode
      ? CustomThemes.darkMode
      : CustomThemes.lightMode;

    return MaterialApp(
      title: 'Wellbeing App',
      home: const Root(),
      theme: themeToUse,
      debugShowCheckedModeBanner: false,
    );
  }
}
