import 'dart:async';

import 'package:flutter/material.dart';
import 'package:term_buddy/themes.dart';
import 'package:term_buddy/widgets/snack_bar.dart';

import '../util/log.dart';

class HelpButton extends StatefulWidget {
  final String? helpText;
  final RichText? richText;
  final Duration? delay;

  const HelpButton({
    Key? key,
    this.helpText,
    this.richText,
    this.delay,
  }) : super(key: key);

  @override
  State<HelpButton> createState() => _HelpButtonState();
}

class _HelpButtonState extends State<HelpButton> {
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
          borderRadius: Dimens.borderRadius,
          onTap: () {},
          onHover: (value) {
            logger.i('value');

            if (value) {
              _timer?.cancel();
              _timer = null;
              showExplanationSnackbar(context);
              // context.showTooltip(
              //     message: 'Remove Alias',
              //     position: TooltipPosition.top);
            } else {
              if (widget.delay != null) {
                _timer = Timer(widget.delay!, () {
              clearSnackBar(context);
                });
              } else {
              clearSnackBar(context);
              }
              // context.hideTooltip();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Help',
                    style: TextStyle(
                        color: context.primary(), fontWeight: FontWeight.bold)),
                Icon(
                  Icons.question_mark_rounded,
                  color: context.primary(),
                ),
              ],
            ),
          )),
    );
  }

  showExplanationSnackbar(BuildContext context) {
    showSnackBar(
      context,
      duration: const Duration(seconds: 60),
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: widget.richText != null
            ? widget.richText!
            : Text(
                widget.helpText ?? '',
                style: context
                    .textTheme()
                    .labelMedium!
                    .copyWith(color: context.onPrimary(), fontSize: 14),
              ),
      ),
    );
  }
}
