import 'package:flutter/material.dart';

import '../screens/summary_screen.dart';
import '../themes.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext context, Widget child, {Duration duration = const Duration(seconds: 3)}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: child,
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
              onPressed: () {
                clearSnackBar(context);
              },
              icon: const Icon(Icons.close_rounded)),
        )
      ],
    ),
    backgroundColor: primaryDark,
    elevation: 8,
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
    duration: duration,
  ));
}

void clearSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).clearSnackBars();
}