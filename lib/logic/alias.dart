import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:process_run/shell.dart';
import 'package:term_buddy/logic/path.dart';

import '../app/config.dart';
import '../models.dart';
import '../screens/environment_variables_screen.dart';
import '../util/log.dart';
import 'core.dart';

// letters only regex
RegExp lettersOnly = RegExp(r'[a-zA-Z]+');

final terminalTypeProvider = Provider<TerminalType>((ref) {
  final hasZsh =
      ref.read(rawEnvironmentVariablesProvider)['SHELL']?.contains('zsh') ==
          true;
  return hasZsh ? TerminalType.zsh : TerminalType.bash;
});

final possibleConfigFilePathsFutureProvider =
    FutureProvider<List<String>>((ref) async {
  final futures =
      possibleMacConfigFiles.map((e) => recursivelyFindPossibleFiles(e));
  final files = await Future.wait(futures);
  final allPossibleFiles = files.expand((element) => element).toSet();
  logger.i('All possible files!!!!!');
  allPossibleFiles.forEach(log);
  return allPossibleFiles.toList();
});

class AliasStateNotifier extends StateNotifier<AsyncValue<List<Alias>>> {
  final Ref ref;

  AliasStateNotifier(this.ref, super.state);

  Future<void> loadAliases() async {
    final possibleConfFiles =
        await ref.read(possibleConfigFilePathsFutureProvider.future);
    final aliases = await Future.wait(
      [...possibleConfFiles, bashBuddyFilePath].map(
        (path) => _checkFileForAliases(path),
      ),
    );

    final aliasesList = aliases.expand((element) => element).toList();
    state = AsyncValue.data(aliasesList.reversed.toList());
  }

  Future<bool> addAliasFromCommand(String command, String alias) async {
    final Alias newAlias =
        Alias(name: alias, command: command, sourceFile: bashBuddyFilePath);
    return addAlias(newAlias);
  }

  Future<bool> addAlias(Alias newAlias) async {
    if (state is AsyncData) {
      final aliases = (state as AsyncData<List<Alias>>).value;
      final aliasExists =
          aliases.any((element) => element.name == newAlias.name);
      if (aliasExists) {
        return false;
      }
    }
    await addLineToBashBuddyFile(newAlias.configLine);
    await loadAliases();
    return true;
  }

  void removeAlias(Alias alias) {
    if (state is AsyncData) {
      final aliases = (state as AsyncData<List<Alias>>).value;
      final aliasExists = aliases.any((element) => element.name == alias.name);
      if (aliasExists) {
        final file = File(bashBuddyFilePath);
        final lines = file.readAsLinesSync();
        print(lines.join('\n'));
        print(alias.configLine);
        final newLines =
            lines.where((element) => !element.contains(alias.configLine));
        file.writeAsStringSync(newLines.join('\n'));
        loadAliases();
      }
    }
  }
}

// Future<void> addAlias(String alias, String command) async {
//   final file = File(bashBuddyFilePath);
//   await file.writeAsString('\n', mode: FileMode.append);
//   file.writeAsString('alias $alias="$command"', mode: FileMode.append);
// }

final aliasStateProvider =
    StateNotifierProvider<AliasStateNotifier, AsyncValue<List<Alias>>>((ref) =>
        AliasStateNotifier(ref, const AsyncValue.loading())..loadAliases());

final aliasForCommandFutureProvider =
    Provider.family<AsyncValue<List<Alias>>, String>((ref, command) {
  final aliases = ref.watch(aliasStateProvider);

  return aliases.when(
      data: (aliases) {
        final alias = aliases.where((al) => al.isAliasFor(command));
        return AsyncValue.data(alias.toList());
      },
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s));
});

Future<void> addSourceFile() async {
  final sourceFile = File(bashBuddyFilePath);
  final sourceFileExists = await sourceFile.exists();
  if (!sourceFileExists) {
    await sourceFile.create(recursive: true);
  }
  await Future.wait(possibleMacSourceFiles.map((e) => _addSourceFileToFile(e)));
}

Future<void> _addSourceFileToFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return;
  }
  final content = await file.readAsString();
  if (content.contains(bashBuddySourceLine)) {
    return;
  } else {
    await file.writeAsString('\n', mode: FileMode.append);
    await file.writeAsString(bashBuddySourceLine, mode: FileMode.append);
  }
}

Future<List<Alias>> _checkFileForAliases(String filePath,
    {Encoding encoding = utf8}) async {
  final file = File(filePath);
  if (!await file.exists()) {
    return [];
  }
  // zsh logic
  final content = await file.readAsLines(encoding: encoding);
  return getAliasesFromLine(content, filePath);
}

List<Alias> getAliasesFromLine(List<String> content, String filePath) {
  final entries = <Alias>[];
  for (var line in content) {
    try {
      if (line.startsWith('alias')) {
        final entry = Alias.fromLine(line, filePath);
        if (entry != null) {
          entries.add(entry);
        }
      }
    } on Exception catch (e) {
      logger.i(e.toString());
      continue;
    }
  }
  return entries;
}

Future<Set<String>> recursivelyFindPossibleFiles(String filePath,
    [Set<String> alreadyExplored = const {}]) async {
  final paths = {...alreadyExplored};
  paths.add(filePath);
  var file = File(filePath);

  if (!(await file.exists())) {
    logger.i("File does not exist: $filePath");
    return {};
  }

  logger.i("Contents of $filePath:");
  var lines = await file.readAsLines();
  for (var line in lines) {
    if (line.startsWith("source")) {
      logger.i("Found possible source$line");
      var sourceFilePath = line.split(" ")[1];
      if (sourceFilePath.startsWith("~")) {
        sourceFilePath = sourceFilePath.replaceFirst("~", userHomePath);
      }
      if (sourceFilePath.startsWith("./")) {
        sourceFilePath = sourceFilePath.replaceFirst(".", userHomePath);
      }
      if (!sourceFilePath.startsWith("/")) {
        sourceFilePath = '$userHomePath/$sourceFilePath';
      }
      logger.i("Found possible source file: $sourceFilePath");
      if (sourceFilePath == bashBuddyFilePath) {
        continue;
      }
      var sourceFile = File(sourceFilePath);
      if (!(await sourceFile.exists())) {
        continue;
      }
      if (alreadyExplored.contains(sourceFilePath)) {
        continue;
      }
      paths.add(sourceFilePath);
      final files = await recursivelyFindPossibleFiles(sourceFilePath, paths);
      paths.addAll(files);
    }
  }
  return paths;
}

final directoryRegex = RegExp(r'^([~$]?[A-Za-z0-9_\-./]+)+[^.]$');

Future<void> addPathVariable(String path) async {
  if (!directoryRegex.hasMatch(path)) {
    throw Exception("Invalid path");
  }
  return addLineToBashBuddyFile('export PATH="\$PATH:$path"');
}
