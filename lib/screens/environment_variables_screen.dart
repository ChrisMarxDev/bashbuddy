import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:process_run/shell.dart';
import 'package:term_buddy/themes.dart';
import 'package:term_buddy/util/extensions.dart';
import 'package:term_buddy/widgets/async_val_page.dart';
import 'package:term_buddy/widgets/search_bar.dart';
import 'package:term_buddy/widgets/snack_bar.dart';

import '../logic/alias.dart';
import '../logic/path.dart';
import '../models.dart';
import '../widgets/extending_text_input.dart';
import '../widgets/help_button.dart';
import '../widgets/title.dart';

class EnvironmentVariablesScreen extends ConsumerWidget {
  const EnvironmentVariablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TitleWidget(
          title: 'Summary',
          actions: [
            HelpButton(
              helpText:
                  'Here is a list of all PATH folders that are currently setup for your system. If you select one of the folders you can see all programms that are available there. \n\nAll of the programms can be executed by typing the name of the programm into the terminal. You can also search for programms. \n\nSo for example if you want to know which "node" your system is using, just type node in the searchbar. But be aware, some programms might be conflicting.',
            ),
          ],
        ),
        EnvSearchBar(),
        SizedBox(height: 20),
        Divider(
          height: 1,
          thickness: 1,
        ),
        Expanded(child: AsyncEnvList()),
      ],
    );
  }
}

class EnvSearchBar extends ConsumerWidget {
  const EnvSearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Row(
        children: [
          Expanded(
            child: BashBuddySearchBar(onChanged: (value) {
              ref.read(envVariableSearchProvider.notifier).state = value;
            }),
          ),
          ExtendingTextInput(
            onSubmit: (String val) async {
              await addPathVariable(val);
              // ignore: use_build_context_synchronously
              showSnackBar(
                  context,
                  Text(
                    'Added $val to PATH',
                    style: TextStyle(color: context.onPrimary()),
                  ));
            },
            hintText: 'Add Path var',
            initialIcon: Icon(Icons.add, color: context.onPrimary()),
            submitIcon: Icon(Icons.check_rounded, color: context.onPrimary()),
          )
        ],
      ),
    );
  }
}

class AsyncEnvList extends ConsumerWidget {
  const AsyncEnvList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(filteredPathProgramsProvider);
    return AsyncValuePage(
      asyncValue: state,
      builder: (context, data) {
        return SingleChildScrollView(child: EnvVarListView(data));
      },
    );
  }
}

class EnvVarListView extends ConsumerWidget {
  final List<PathEntry> pathEntries;

  const EnvVarListView(
    this.pathEntries, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(expandedPathEntriesProvider);
    final searchTerms = ref.watch(envVariableSearchProvider).toLowerCase();
    return ExpansionPanelList(
      dividerColor: Colors.transparent,
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.zero,
      expansionCallback: (int index, bool isExpanded) {
        ref.read(expandedPathEntriesProvider.notifier).state =
            Set.from(expanded.toggle(index));
      },
      children: pathEntries
          .mapIndexed((index, entry) =>
              itemBuilder(entry, expanded.contains(index), searchTerms, index))
          .toList(),
    );
  }

  ExpansionPanel itemBuilder(
      PathEntry entry, bool isExpanded, String search, int index) {
    final programs =
        entry.programs.where((element) => element.contains(search)).toList();

    late bool expanded;
    if (search.isNotEmpty) {
      expanded = programs.isNotEmpty;
    } else {
      expanded = isExpanded;
    }
    final isLast = index == pathEntries.length - 1;
    return ExpansionPanel(
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) => SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder,
                  color: isExpanded ? context.primary() : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(entry.path,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          )),
      isExpanded: expanded,
      body: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 64.0 : 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: programs
              .map(
                (e) => SizedBox(
                    width: double.infinity,
                    child: PathProgrammLine(programPath: e)),
              )
              .toList(),
        ),
      ),
    );
  }
}

class PathProgrammLine extends StatelessWidget {
  final String programPath;

  const PathProgrammLine({
    Key? key,
    required this.programPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final programName = programPath.split('/').last;
    final restOfPath =
        programPath.substring(0, programPath.length - programName.length);
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: programPath));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Copied $programPath to clipboard'),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 2, left: 32, bottom: 2),
        child: RichText(
            text: TextSpan(children: [
          TextSpan(text: restOfPath, style: context.textTheme().labelMedium),
          TextSpan(
              text: programName,
              style: context
                  .textTheme()
                  .labelMedium!
                  .copyWith(color: context.primary())),
        ])),
      ),
    );
  }
}

final expandedPathEntriesProvider = StateProvider.autoDispose<Set<int>>((ref) {
  ref.watch(filteredPathProgramsProvider);
  return {};
});

class EnvVarTile extends StatelessWidget {
  final EnvVariableEntry entry;

  const EnvVarTile({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(entry.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            ...entry.values.map((e) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(e),
                )),
          ]),
    );
  }
}
