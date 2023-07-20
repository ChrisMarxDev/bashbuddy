import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:term_buddy/screens/alias_screen.dart';
import 'package:term_buddy/screens/charts_screen.dart';
import 'package:term_buddy/screens/settings_screen.dart';
import 'package:term_buddy/screens/summary_screen.dart';

import '../logic/settings.dart';
import '../screens/environment_variables_screen.dart';
import '../themes.dart';

class AppScreen extends ConsumerWidget {
  const AppScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(darkModeProvider);
    return MaterialApp(
      // child: Theme(
      theme: themeData(isDark: false),
      debugShowCheckedModeBanner: false,
      darkTheme: themeData(isDark: true),
      themeMode: state ? ThemeMode.dark : ThemeMode.light,
      home: const ContentScreen(),
      // ),
    );
  }
}

class ContentScreen extends ConsumerWidget {
  const ContentScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ContainerPage();
  }
}

final pageIndexStateProvider = StateProvider<int>((ref) => 0);

class ContainerPage extends ConsumerStatefulWidget {
  const ContainerPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends ConsumerState<ContainerPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(keepPage: true);
    _pageController.addListener(() {
      // ref.read(pageIndexStateProvider).state = _pageController.page!.round();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(pageIndexStateProvider, (int? previousIndex, int newIndex) {
      _pageController.jumpToPage(
        newIndex,
      );
      // duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
    final index = ref.watch(pageIndexStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          NavigationRail(
              leading: Padding(
                padding: const EdgeInsets.only(
                  top: 64,
                  left: 8.0,
                  right: 8.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    "assets/icons/logo_no_bg.png",
                    fit: BoxFit.cover,
                    width: 80,
                  ),
                ),
              ),
              groupAlignment: 0,
              labelType: NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.leaderboard),
                  selectedIcon: Icon(Icons.leaderboard),
                  label: Text('Ranking'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: Text('Alias'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.pie_chart),
                  selectedIcon: Icon(Icons.pie_chart),
                  label: Text('Charts'),
                ),
                NavigationRailDestination(
                  icon: Stack(
                    children: [
                      const Icon(Icons.ballot_outlined),
                      Transform.rotate(
                        angle: -pi / 4,
                        child: const Text(
                          'BETA',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accentRed),
                        ),
                      )
                    ],
                  ),
                  selectedIcon: const Icon(Icons.ballot),
                  label: const Text('Path'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              selectedIndex: index,
              onDestinationSelected: (int index) {
                ref.read(pageIndexStateProvider.notifier).state = index;
              }),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int index) {
                // ref.read(pageIndexStateProvider.notifier).state = index;
              },
              children: const [
                SummaryScreen(),
                AliasScreen(),
                ChartsScreen(),
                EnvironmentVariablesScreen(),
                SettingsScreen(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
