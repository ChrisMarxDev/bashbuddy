import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:term_buddy/util/extensions.dart';
import 'package:term_buddy/themes.dart';
import 'package:term_buddy/widgets/async_val_page.dart';
import 'package:term_buddy/widgets/snack_bar.dart';

import '../logic.dart';
import '../models.dart';
import '../util/log.dart';
import '../widgets/extending_text_input.dart';
import '../widgets/search_bar.dart';
import '../widgets/title.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SummaryScreenState();
  }
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(historySummaryFilteredStateProvider);
    return SelectionArea(
      child: AsyncValuePage(
        asyncValue: entries,
        builder: (context, data) {
          return SummaryView(data: data);
        },
      ),
    );
  }
}

class SummaryView extends ConsumerStatefulWidget {
  final List<HistorySummaryEntry> data;

  const SummaryView({
    super.key,
    required this.data,
  });

  @override
  ConsumerState<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends ConsumerState<SummaryView> {
  late final TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TitleWidget(
              title: 'Summary',
            ),
            BashBuddySearchBar(
              controller: controller,
              onChanged: (value) {
                ref.read(summarySearchWordFilter.notifier).state = value;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(
              height: 1,
              thickness: 1,
            )
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(right: 8.0),
            itemCount: widget.data.length,
            itemBuilder: (context, index) {
              final entry = widget.data.elementAt(index);
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 8.0 : 0),
                child: SummaryTile(entry).animate().fadeIn(duration: 100.ms),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SummaryTile extends ConsumerWidget {
  final HistorySummaryEntry entry;

  const SummaryTile(this.entry, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 80),
                          child: Text(
                            entry.command,
                            maxLines: 3,
                            style: context.textTheme().titleSmall,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      if (entry.lastRun != null)
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 16),
                          child: Text(
                            "Last: ${entry.lastRun!.formatWithTime()}",
                            overflow: TextOverflow.fade,
                            style: context
                                .textTheme()
                                .labelMedium!
                                .copyWith(color: weakestGrey),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text('Alias:',
                      style: context
                          .textTheme()
                          .labelMedium!
                          .copyWith(color: weakGrey)),
                  const SizedBox(
                    height: 4,
                  ),
                  AliasWidget(command: entry.command),
                ],
              ),
            ),
            const SizedBox(
              width: 24,
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  entry.count.toString(),
                  style: context
                      .textTheme()
                      .headlineMedium!
                      .asSemiBold()
                      .copyWith(color: context.colorScheme().primary),
                )),
          ],
        ),
      ),
    );
  }
}

class AliasWidget extends ConsumerWidget {
  final String? existingAlias;
  final String command;

  const AliasWidget({this.existingAlias, required this.command, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final state = ref.watch(Provider);
    final state = ref.watch(aliasForCommandFutureProvider(command));

    return state.map(
      data: (data) {
        final alias = data.value;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...alias.mapIndexed((index, e) => AliasBadge(alias: e)),
            MakeAliasTextInput(
              isHighlighted: alias.isEmpty,
              command: command,
              key: Key('${command}_${alias.length} '),
            )
          ],
        );
      },
      error: (error) => const Text('Error'),
      loading: (loading) => const CircularProgressIndicator(),
    );
  }
}

class MakeAliasField extends ConsumerStatefulWidget {
  final String command;

  const MakeAliasField({
    super.key,
    required this.command,
  });

  @override
  createState() => _MakeAliasFieldState();
}

class _MakeAliasFieldState extends ConsumerState<MakeAliasField> {
  var isExpanded = false;
  late FocusNode focusNode;
  late TextEditingController textController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      // if (!focusNode.hasFocus) {
      //   setState(() {
      //     isExpanded = false;
      //   });
      // }
    });
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 360.milliseconds,
      child: isExpanded
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.add),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      labelText: 'Make Alias!',
                    ),
                  ),
                ),
                IconButton(
                  key: Key('save_alias_${widget.command}'),
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final response = ref
                        .read(aliasStateProvider.notifier)
                        .addAliasFromCommand(
                            widget.command, textController.text);
                  },
                ),
              ],
            )
          : Row(
              children: [
                IconButton(
                  key: Key('make_alias_${widget.command}'),
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      focusNode.requestFocus();
                      isExpanded = true;
                    });
                  },
                ),
              ],
            ),
    );
  }
}

class AliasBadge extends StatelessWidget {
  final Color color;
  final Alias alias;

  const AliasBadge({Key? key, this.color = primaryDark, required this.alias})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 80),
        child: ColorBadge(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      alias.name,
                      style: context
                          .textTheme()
                          .bodyMedium!
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              if (alias.isCompound)
                const SizedBox(
                  width: 8,
                ),
              if (alias.isCompound)
                InkWell(
                    onTap: () {
                      logger.i('alias: $alias');
                    },
                    onHover: (value) {
                      logger.i('value');

                      if (value) {
                        showCompoundAlias(context, alias);
                        // context.showTooltip(
                        //     message: 'Remove Alias',
                        //     position: TooltipPosition.top);
                      } else {
                        clearSnackBar(context);
                        // context.hideTooltip();
                      }
                    },
                    child: const Icon(
                      Icons.info_outline,
                      color: kWhite,
                    ))
            ],
          ),
        ),
      ),
    );
  }

  void showCompoundAlias(BuildContext context, Alias alias) {
    // RenderBox box = context.findRenderObject() as RenderBox;
    // Offset position = box.localToGlobal(Offset.zero); //this is global position
    // double y = position.dy;
    // logger.i('y: $y');

    showSnackBar(
      context,
      duration: const Duration(seconds: 60),
      AliasSnackBarWidget(alias: alias),
    );
  }


}

class AliasSnackBarWidget extends StatelessWidget {
  final Alias alias;

  const AliasSnackBarWidget({
    Key? key,
    required this.alias,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: '',
            style: context.textTheme().bodyMedium!.copyWith(color: kWhite),
            children: <TextSpan>[
              TextSpan(
                  text: alias.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: ' is a chained alias for:'),
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          alias.command,
          style: context.textTheme().titleMedium!.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class ColorBadge extends StatelessWidget {
  final Color color;
  final Widget child;

  const ColorBadge({Key? key, this.color = primaryDark, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
