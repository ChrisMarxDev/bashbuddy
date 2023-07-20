import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:process_run/shell.dart';
import 'package:term_buddy/util/extensions.dart';

import '../models.dart';

final rawEnvironmentVariablesProvider =
StateProvider<Map<String, String>>((ref) {
  platformEnvironment.printEntries();
  // shellEnvironment.printEntries();
  // userEnvironment.printEntries();

  return platformEnvironment;
});

final environmentVariablesProvider =
StateProvider<List<EnvVariableEntry>>((ref) {
  final vars = ref.watch(rawEnvironmentVariablesProvider);
  return vars.entries
      .map((e) => EnvVariableEntry.fromValue(name: e.key, value: e.value))
      .toList();
});

final pathProgramsProvider = FutureProvider<List<PathEntry>>((ref) async {
  final vars = ref.watch(environmentVariablesProvider);
  final path = vars.firstWhereOrNull((e) => e.name == 'PATH');
  if (path == null) {
    return [];
  }
  final pathEntries = <PathEntry>[];
  final paths = path.values.toSet().toList()..sort();
  for (final pathLine in paths) {
    var programs = <String>[];
    try {
      programs = await ref.read(programSearchFutureProvider(pathLine).future);
    } on Exception catch (e) {
      print(e.toString());
    }
    pathEntries.add(PathEntry(path: pathLine, programs: programs));
  }

  return pathEntries;
});

String? getEnvVar(String varName) {
  Map<String, String> env = Platform.environment;
  return env[varName];
}

final envVariableSearchProvider =
StateProvider.autoDispose<String>((ref) => '');

final filteredPathProgramsProvider =
FutureProvider.autoDispose<List<PathEntry>>((ref) async {
  final search = ref.watch(envVariableSearchProvider);
  final pathPrograms = await ref.watch(pathProgramsProvider.future);
  if (search.isEmpty) {
    return pathPrograms;
  }
  return pathPrograms.where((e) => e.matchesSearch(search)).toList();
});

final programSearchFutureProvider =
FutureProvider.autoDispose.family<List<String>, String>((ref, path) async {
  final dir = Directory(path);
  final files = dir.listSync(recursive: false);
  final fileNames = files.map((e) => e.path).toList();
  return fileNames;
});
