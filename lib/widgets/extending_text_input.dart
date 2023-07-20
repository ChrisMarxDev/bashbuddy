import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:term_buddy/logic.dart';
import 'package:term_buddy/themes.dart';

import '../util/log.dart';

class ExtendingTextInput extends StatefulWidget {
  final double height;
  final void Function(String) onSubmit;
  final Widget initialIcon;
  final Widget submitIcon;
  final bool isHighlighted;
  final void Function(bool isHighlighted)? expansionStateChanged;
  final String? hintText;

  const ExtendingTextInput({
    super.key,
    this.height = 48,
    required this.onSubmit,
    required this.initialIcon,
    required this.submitIcon,
    this.isHighlighted = true,
    this.expansionStateChanged,
    this.hintText,
  });

  @override
  State<ExtendingTextInput> createState() => _ExtendingTextInputState();
}

class _ExtendingTextInputState extends State<ExtendingTextInput> {
  var isExpanded = false;
  late FocusNode focusNode;
  late TextEditingController textController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode = FocusNode(onKey: _handleKeyPress);
    focusNode.addListener(() async {
      if (!focusNode.hasFocus) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          toggleExpand(false);
        }
      } else {
        if (mounted) {
          setState(() {
            // isExpanded = true;
          });
        }
      }
    });
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyPress(FocusNode focusNode, RawKeyEvent event) {
    // handles submit on enter
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      handleResult();
      focusNode.unfocus();
      // handled means that the event will not propagate
      return KeyEventResult.handled;
    }
    // ignore every other keyboard event including SHIFT+ENTER
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height;


    return AnimatedContainer(
      duration: 360.milliseconds,
      height: height,
      decoration: BoxDecoration(
        color: isExpanded
            ? Colors.transparent
            : (widget.isHighlighted ? context.primary() : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          // color: isExpanded ? context.primary() : (widget.isHighlighted ? context.primary() : Colors.white ),
          color: context.primary(),
          width: 2,
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedSize(
          duration: 360.milliseconds,
          child: isExpanded
              ? SizedBox(
                  width: 256,
                  height: height,
                  child: Center(
                    child: TextField(
                      controller: textController,
                      focusNode: focusNode,
                      decoration:  InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(left: 16, right: 2, bottom: 8),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        border: InputBorder.none,
                        hintText: widget.hintText,

                        // labelText: 'Make Alias!',
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Container(
          // color: isExpanded ? Colors.white : (widget.isHighlighted ? context.primary() : Colors.white ),
          color: context.primary(),
          width: height,
          height: height,
          child: InkWell(
            child: isExpanded ? widget.submitIcon : widget.initialIcon,
            onTap: () {
              logger.i('tapped $isExpanded');
              if (isExpanded) {
                handleResult();
                toggleExpand(false);
              } else {
                setState(() {
                  focusNode.requestFocus();
                  toggleExpand(true);
                });
              }
            },
          ),
        ),
      ]),
    );
  }

  void toggleExpand(bool expand) {
    return setState(() {
      isExpanded = expand;
    });
  }

  void handleResult() {
    final result = textController.text;
    if (result.isNotEmpty) {
      widget.onSubmit(result);
      textController.clear();
    }
  }
}

class MakeAliasTextInput extends ConsumerWidget {
  final String command;
  final bool isHighlighted;

  const MakeAliasTextInput({
    Key? key,
    required this.command,
    required this.isHighlighted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExtendingTextInput(
      isHighlighted: isHighlighted,
      onSubmit: (text) {
        ref.read(aliasStateProvider.notifier).addAliasFromCommand(command, text);
      },
      initialIcon: const Icon(Icons.add, color: Colors.white),
      submitIcon: const Icon(Icons.check, color: Colors.white),
    );
  }
}
