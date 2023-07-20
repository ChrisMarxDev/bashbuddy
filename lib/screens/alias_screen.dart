import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:term_buddy/themes.dart';
import 'package:term_buddy/util/extensions.dart';
import 'package:term_buddy/widgets/dialog.dart';
import 'package:term_buddy/widgets/title.dart';

import '../app/config.dart';
import '../logic.dart';
import '../models.dart';
import '../util/log.dart';
import '../widgets/async_val_page.dart';
import '../widgets/help_button.dart';
import '../widgets/snack_bar.dart';

class AliasScreen extends ConsumerWidget {
  const AliasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aliasStateProvider);
    return SelectionArea(
      child: AsyncValuePage(
          asyncValue: state,
          builder: (context, data) {
            return AliasScreenContent(data: data);
          }),
    );
  }
}

class AliasScreenContent extends ConsumerWidget {
  final List<Alias> data;

  const AliasScreenContent({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const TitleWidget(title: 'Your Aliases', actions: [

        AliasExplanationBadge(),
        ]),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: MakeAliasButton(
            onSubmit: (Alias val) {
              print('🎯 🎯 🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯🎯 $val');
              ref.read(aliasStateProvider.notifier).addAlias(val);
            },
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
        ),
        Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final alias = data[index];
                return AliasTile(alias: alias);
              }),
        ),
      ],
    );
  }
}

class AliasTile extends ConsumerWidget {
  final Alias alias;

  const AliasTile({
    Key? key,
    required this.alias,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alias.sourceFile,
                    style: context.textTheme().labelMedium!.copyWith(
                        color: alias.fromApp
                            ? context.primary().withOpacity(0.4)
                            : weakestGrey),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                    child: Text(alias.name,
                        style: context
                            .textTheme()
                            .titleMedium!
                            .copyWith(color: context.primary())),
                  ),
                  Text(alias.command),
                ],
              ),
            ),
            if (alias.fromApp)
              IconButton(
                onPressed: () {
                  BaseDialog.show(context,
                      body:
                          'Are you sure that you want to delete the alias:\n${alias.name}\n${alias.command}?',
                      title: 'Delete Alias?',
                      buttons: [
                        ButtonData(
                          highlighted: false,
                          text: 'Cancel'.tr(),
                          onTap: (context) {
                            Navigator.of(context).pop();
                          },
                        ),
                        ButtonData(
                          text: 'Confirm Deletion'.tr(),
                          onTap: (context) {
                            ref
                                .read(aliasStateProvider.notifier)
                                .removeAlias(alias);
                            Navigator.of(context).pop();
                          },
                        ),
                      ]);
                },
                icon: Icon(Icons.delete, color: accentRed.withOpacity(0.5)),
              ),
          ],
        ),
      ),
    );
  }
}

class MakeAliasButton extends StatefulWidget {
  final void Function(Alias) onSubmit;
  final void Function(bool isHighlighted)? expansionStateChanged;

  const MakeAliasButton({
    super.key,
    required this.onSubmit,
    this.expansionStateChanged,
  });

  @override
  State<MakeAliasButton> createState() => _MakeAliasButtonState();
}

class _MakeAliasButtonState extends State<MakeAliasButton> {
  var isExpanded = false;

  late FocusNode aliasNameNode;
  late FocusNode aliasCommandNode;
  late FocusNode saveButtonNode;
  late TextEditingController aliasCommandTextController;
  late TextEditingController aliasNameTextController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    aliasNameNode = FocusNode(onKey: _handleKeyPress);
    aliasCommandNode = FocusNode(onKey: _handleKeyPress);
    saveButtonNode = FocusNode(onKey: _handleKeyPress);
    aliasCommandTextController = TextEditingController();
    aliasNameTextController = TextEditingController();
  }

  @override
  void dispose() {
    aliasCommandTextController.dispose();
    aliasNameTextController.dispose();
    aliasCommandNode.dispose();
    aliasNameNode.dispose();
    saveButtonNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyPress(FocusNode focusNode, RawKeyEvent event) {
    // handles submit on enter
    if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
        event.isKeyPressed(LogicalKeyboardKey.tab)) {
      if (focusNode == aliasNameNode) {
        aliasCommandNode.requestFocus();
      } else if (focusNode == aliasCommandNode) {
        saveButtonNode.requestFocus();
      } else {
        handleResult();
      }
      // handled means that the event will not propagate
      return KeyEventResult.handled;
    }
    // ignore every other keyboard event including SHIFT+ENTER
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // final iconColor = isExpanded
    //     ? Colors.white
    //     : (widget.isHighlighted ? context.primary() : Colors.white);

    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedContainer(
          duration: Animations.baseDuration,
          decoration: BoxDecoration(
            borderRadius: Dimens.borderRadius,
            border: Border.all(
              color: isExpanded ? context.primary() : Colors.transparent,
              // color: isExpanded ? Colors.transparent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: Dimens.borderRadius,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.primary(),
                            borderRadius: Dimens.borderRadius * 0.6,
                          ),
                          height: 48,
                          width: 48,
                          child: isExpanded
                              ? const Icon(
                                  Icons.clear,
                                  color: kWhite,
                                )
                              : const Icon(
                                  Icons.add,
                                  color: kWhite,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 16),
                          child: Text(
                            'Add your alias',
                            style: context.textTheme().titleMedium!.copyWith(
                                  color: context.primary(),
                                ),
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      logger.i('tapped $isExpanded');
                      if (isExpanded) {
                        toggleExpand(false);
                      } else {
                        setState(() {
                          // focusNode.requestFocus();
                          toggleExpand(true);
                        });
                      }
                    },
                  ),
                  // Expanded(
                  //   child: AnimatedSize(
                  //       duration: Animations.baseDuration * 0.5,
                  //       child: !isExpanded
                  //           ? const SizedBox(
                  //               height: 48,
                  //               width: 0,
                  //             )
                  //           : ),
                  // )
                ],
              ),
              AnimatedSize(
                duration: Animations.baseDuration,
                child: !isExpanded
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: aliasNameTextController,
                              focusNode: aliasNameNode,
                              decoration: const InputDecoration(
                                label: Text('Name'),
                                hintText: 'A short name for your alias..',
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextField(
                              controller: aliasCommandTextController,
                              focusNode: aliasCommandNode,
                              maxLines: 10,
                              minLines: 2,
                              decoration: const InputDecoration(
                                label: Text('Command'),
                                hintText:
                                    'Your command (chain multiple commands with &&)',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: ElevatedButton(
                                  focusNode: saveButtonNode,
                                  onPressed: () {
                                    handleResult();
                                  },
                                  child: const Text('Create Alias')),
                            )
                          ],
                        ),
                      ),
              )
            ],
          )),
    );
  }

  void toggleExpand(bool expand) {
    if (expand) {
      aliasNameNode.requestFocus();
    }
    return setState(() {
      isExpanded = expand;
    });
  }

  void handleResult() {
    if (aliasCommandTextController.text.isNotEmpty &&
        aliasNameTextController.text.isNotEmpty) {
      final alias = Alias(
          sourceFile: bashBuddyFilePath,
          name: aliasNameTextController.text,
          command: aliasCommandTextController.text);
      widget.onSubmit(alias);
      aliasCommandTextController.clear();
      aliasNameTextController.clear();
      toggleExpand(false);
    }
  }
}

class AliasExplanationBadge extends StatelessWidget {
  const AliasExplanationBadge({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HelpButton(
        helpText:
            'Aliases are basically little shortcuts that you write instead of full commands. They are especially helpful with commands you use on a regular basis. Commands can be chained with &&.\n'
            '\nExample: git add . && git commit\n'
            '\nAliased commands otherwise behave exactly like the command you enter. So if you imagine that we declare the command above as gitac, we can write the following:\n');
  }
}
