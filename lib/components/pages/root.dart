import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/components/pages/dashboard_types.dart';
import 'package:wellbeing/components/pages/theory_and_how_to.dart';
import 'package:wellbeing/components/pages/logger.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:wellbeing/components/pages/settings_page.dart';
import 'package:wellbeing/components/pages/activity_entry_history.dart';
import 'package:wellbeing/components/pages/dashboard_activity_time.dart';
import 'package:wellbeing/components/pages/activity_types_list.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:wellbeing/providers_and_settings/showcase_texts.dart';

enum ScreenType {
  phoneLike,
  quadratic,
  tabletLike,
}

class Root extends ConsumerWidget {
  const Root({super.key});

  final List<Widget> pages = const [
    DashboardActivityTime(),
    DashboardTime(),
    ActivityEntryHistory(),
    ActivityTypesList(),
    TheoryAndHowTo(),
    SettingPage()
  ];

  @override 
  Widget build(BuildContext context, WidgetRef ref) {

    final int pageIndex = ref.watch(pageIndexProvider);

    final size = MediaQuery.of(context).size;
    final double aspectRatio = size.width / size.height;
    ScreenType? screenType;

    if (aspectRatio < 0.7) {
      screenType = ScreenType.phoneLike;
    } else if (aspectRatio < 1.1) {
      screenType = ScreenType.quadratic;
    } else {
      screenType = ScreenType.tabletLike;
    }

    Widget bodyWidget;
    Widget? floatingActionButton;

    switch (screenType) {
      case ScreenType.tabletLike:
        bodyWidget = Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 100.0),
                child: pages.elementAt(pageIndex),
              ),
            ),
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(right: 30.0),
                child: LoggerContent(padding: true, autofocus: false, cancelButton: false,),
              ),
            ),
          ],
        );
        break;
      case ScreenType.phoneLike:
      case ScreenType.quadratic:
        bodyWidget = pages.elementAt(pageIndex);
        floatingActionButton = FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Logger()),
          ),
        );
        break;
    }

    Widget? navigation;
    Widget? drawer;
    PreferredSizeWidget? appBar;

    switch(screenType) {
      case ScreenType.phoneLike:
        navigation = const CustomBottomNavigationBar();
        break;
      case ScreenType.quadratic:
      case ScreenType.tabletLike:
        appBar = AppBar(title: const Text('Wellbeing App'),);
        drawer = const CustomSideDrawer();
        break;
    } 


    ShowCaseWidget scaffoldWithShowCase = ShowCaseWidget(
      builder: Builder(
        builder: (context) => Scaffold(
          appBar: appBar,
          body: bodyWidget,
          floatingActionButton: Showcase(
            key: globalKeyFloatingActionButton,
            description: floatingActionButtonShowcaseText,
            child: floatingActionButton!
          ),
          bottomNavigationBar: navigation,
          drawer: drawer,
          resizeToAvoidBottomInset: false,
        ),
      )
    );


    return SafeArea(
      child: scaffoldWithShowCase,
    );
  }
}

class PageInformation {
  const PageInformation({
    required this.name,
    required this.icon,
    required this.pageNumber,
  });

  final IconData icon;
  final String name;
  final int pageNumber;
}

List<PageInformation> pageInformation = const [
  PageInformation(pageNumber: 0, name: 'Summaries', icon: iconDashboardSummaries),
  PageInformation(pageNumber: 1, name: 'Type Analysis', icon: iconDashboardTypes),
  PageInformation(pageNumber: 2, name: 'Entry History', icon: iconEntryHistory),
  PageInformation(pageNumber: 3, name: 'Type List', icon: iconTypeList),
  PageInformation(pageNumber: 4, name: 'Theory and How To', icon: iconTheoryHowTo),
  PageInformation(pageNumber: 5, name: 'Settings', icon: iconSettings),
];

class CustomSideDrawer extends ConsumerWidget {
  const CustomSideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: pageInformation
          .map((page) => ListTile(
            leading: Icon(page.icon),
            title: Text(page.name),
            onTap: () {
              ref.read(pageIndexProvider.state).state = page.pageNumber;
              Navigator.of(context).pop();
            },
          ))
          .toList()
      ),
    );
  }
}

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int pageIndex = ref.watch(pageIndexProvider);

    return CurvedNavigationBar(
      index: pageIndex,
      color: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).canvasColor,
      animationDuration: const Duration(milliseconds: 150),
      items: const [
        BottomNavigationBarIcon(iconDashboardSummaries),  // dashboard: time spent
        BottomNavigationBarIcon(iconDashboardTypes),  // dashboard: activity inspection
        BottomNavigationBarIcon(iconEntryHistory),  // activity history
        BottomNavigationBarIcon(iconTypeList),  // activity type list
        BottomNavigationBarIcon(iconTheoryHowTo),  // Info Page
        BottomNavigationBarIcon(iconSettings),  // settings
      ],
      onTap: (index) {
        ref.read(pageIndexProvider.state).state = index;
      },
    );
  }

}


class BottomNavigationBarIcon extends StatelessWidget {
  const BottomNavigationBarIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 30,
      color: Theme.of(context).colorScheme.onSecondary,
    );
  }
}

final StateProvider<int> pageIndexProvider = StateProvider((ref) => 0);


