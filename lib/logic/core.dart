import 'dart:io';

import '../app/config.dart';

Future<void> addLineToBashBuddyFile(String line) async {
  final file = File(bashBuddyFilePath);

  await file.writeAsString('\n', mode: FileMode.append);
  await file.writeAsString(line, mode: FileMode.append);
}
