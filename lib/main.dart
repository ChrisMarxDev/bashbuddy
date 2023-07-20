import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:term_buddy/util/extensions.dart';
import 'package:term_buddy/util/log.dart';

import 'app/macos_app.dart';
import 'logic.dart';
import 'logic/settings.dart';

const appName = 'Bash Buddy';

class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    logger.i('didUpdateProvider $provider $previousValue $newValue'.take(500));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final result = await Shell().run('''
zsh --version
  echo \$TERM
  
  ''');
  // \$HISTFILE
  // \$TERM
  result.outLines.forEach(logger.i);

  var proc = await Process.run('echo', ['\$TERM']);
  print(proc.stdout);
  // Map<String, String> env = Platform.environment;
  // env.forEach((k, v) => print("Key=$k Value=$v"));

  logger.i('Init persistance');

  var appDir = await getApplicationDocumentsDirectory();
  logger.i('App dir: ${appDir.path}');

  await Hive.initFlutter(appName);
  await Hive.openBox(settingsBox);

  await addSourceFile();

  runZonedGuarded(
    () => runApp(
      // Adding ProviderScope enables Riverpod for the entire project
      // Adding our Logger to the list of observers
      ProviderScope(
          overrides: const [],
          observers: [RiverpodLogger()],
          child: const MyApp()),
    ),
    (error, stack) {
      logger.e('$error', error, stack);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // if(Platform.isMacOS)
    return const MacApp();
  }
}
