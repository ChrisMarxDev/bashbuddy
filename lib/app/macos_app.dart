import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:term_buddy/main.dart';
// import 'package:macos_ui/macos_ui.dart';

import 'main_page.dart';

class MacApp extends StatelessWidget {
  const MacApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MacosApp(
      title: appName,
      themeMode: ThemeMode.light,
      theme: MacosThemeData(),
      // home: const ContentScreen(),
      home: const AppScreen(),
    );

  }
}
