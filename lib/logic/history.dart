import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';

import '../util/log.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:process_run/shell.dart';

import '../encoding.dart';
import '../logic.dart';
import '../models.dart';

class HistoryLineStateNotifier
    extends StateNotifier<AsyncValue<List<HistoryLine>>> {
  final Ref ref;

  HistoryLineStateNotifier(this.ref, super.state);

  Future<void> loadHistory() async {
    // zsh logic
    final entries = <HistoryLine>[];

    // ❯ echo $HISTFILE
    // /Users/christophermarx/.zsh_history

    final zshHistory = File('$userHomePath/.zsh_history');
    if (await zshHistory.exists()) {
      const customEncoding = CustomEncoding();
      final zshContent = await zshHistory.readAsLines(encoding: customEncoding);
      logger.i('zsh_history file: ${zshContent.length} lines');
      final zshEntries = getHistoryLinesFromLines(zshContent);
      logger.i('zsh_history file: ${zshEntries.length} entries');
      entries.addAll(zshEntries);
    }

    final historyFile = File('$userHomePath/.bash_history');
    if (await historyFile.exists()) {
      final content = await historyFile.readAsLines(encoding: utf8);
      logger.i('bash_history file: ${content.length} lines');
      final bashEntries = getHistoryLinesFromLines(content);
      logger.i('bash_history file: ${bashEntries.length} entries');
      entries.addAll(bashEntries);
    }

    final hastExtendedHistory =
        entries.firstWhereOrNull((element) => element.time != null) != null;

    ref.read(isExtendedHistoryEnabledProvider.notifier).state =
        hastExtendedHistory;

    state = AsyncValue.data(entries);
  }
}

final isExtendedHistoryEnabledProvider = StateProvider<bool>((ref) => false);

List<HistoryLine> getHistoryLinesFromLines(List<String> lines) {
  final entries = <HistoryLine>[];
  for (var line in lines) {
    try {
      final entry = HistoryLine.fromLine(line);
      if (entry != null) {
        entries.add(entry);
      }
    } on Exception catch (e) {
      logger.i('Crashing line: $line $e');
      continue;
    }
  }
  return entries;
}

final historyLineStateProvider = StateNotifierProvider<HistoryLineStateNotifier,
        AsyncValue<List<HistoryLine>>>(
    (ref) => HistoryLineStateNotifier(ref, const AsyncValue.loading())
      ..loadHistory());

final historySummaryStateProvider =
    StateProvider<AsyncValue<List<HistorySummaryEntry>>>((ref) {
  final historyState = ref.watch(historyLineStateProvider);
  final aliasState = ref.watch(aliasStateProvider);

  final data = historyState.asData?.value;
  final aliasData = aliasState.asData?.value;

  if (data == null || aliasData == null) {
    return const AsyncValue.loading();
  }

  final Map<String, HistorySummaryEntry> entries = {};

  for (var line in data) {
    // ': 1628669488:0;cd Desktop'

    final content = line.command;
    try {
      final entry = entries.putIfAbsent(content, () {
        // compute if the command is actually an alias for something
        String? isAliasFor;

        final aliasIndex =
            aliasData.indexWhere((element) => element.name == content);

        if (aliasIndex != -1) {
          isAliasFor = aliasData[aliasIndex].command;
        }
        // end alias computation
        return HistorySummaryEntry(content, line.time, isAliasFor: isAliasFor);
      });
      entry.count++;
      if (line.time != null && entry.lastRun != null) {
        entry.lastRun =
            line.time!.isAfter(entry.lastRun!) ? line.time : entry.lastRun;
      }
    } on Exception catch (e) {
      logger.i(e.toString());
    }

    // entry.lastRun = DateTime.fromMillisecondsSinceEpoch(
    //     int.parse(element.substring(2, element.indexOf(':'))) *
    //         1000);
  }
  final sorted = entries.values.toList()..sort((a, b) => b.count - a.count);

  return AsyncValue.data(sorted);
});

final summarySearchWordFilter = StateProvider.autoDispose<String>((ref) => '');

final historySummaryFilteredStateProvider =
    StateProvider.autoDispose<AsyncValue<List<HistorySummaryEntry>>>((
  ref,
) {
  final historyState = ref.watch(historySummaryStateProvider);
  final filterState = ref.watch(summarySearchWordFilter);

  final data = historyState.asData?.value;
  final filter = filterState;

  if (data == null) {
    return const AsyncValue.loading();
  }

  final filtered =
      data.where((element) => element.command.contains(filter)).toList();

  return AsyncValue.data(filtered);
});
