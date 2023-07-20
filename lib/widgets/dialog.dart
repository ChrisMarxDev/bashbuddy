
import 'package:flutter/material.dart';
import 'package:term_buddy/themes.dart';

class BaseDialog extends StatelessWidget {
  final String title;
  final String? body;
  final Widget? bodyWidget;
  final bool dismissible;
  final List<ButtonData> buttons;

  const BaseDialog({
    required this.title,
    this.body,
    this.bodyWidget,
    required this.buttons,
    required this.dismissible,
    super.key,
  }) : assert(
          body != null || bodyWidget != null,
          'body or bodyWidget must not be null',
        );

  static void show(
    BuildContext context, {
    required String title,
    String? body,
    Widget? bodyWidget,
    String? lottieAsset,
    bool dismissible = true,
    required List<ButtonData> buttons,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return BaseDialog(
          title: title,
          body: body,
          bodyWidget: bodyWidget,
          buttons: buttons,
          dismissible: dismissible,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Dialog(
        elevation: 8,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    title,
                    style: context.textTheme().titleLarge!.asBold(),
                  ),
                ),
                const SizedBox(height: 16),
                if (body != null)
                  Text(body!, style: context.textTheme().bodyMedium),
                if (body == null && bodyWidget != null) bodyWidget!,
                const SizedBox(height: 32),
                if (buttons.length == 1)
                  _generateButton(buttons.first, context, fill: true)
                else
                  _generateButtonList(buttons)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _generateButtonList(List<ButtonData> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var isVertical = false;

        final maxButtonWidth = constraints.maxWidth / buttons.length;
        for (final button in data) {
          if (button.estimatedWidth > maxButtonWidth) {
            isVertical = true;
          }
        }

        return Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 16,
          spacing: 16,
          children: data
              .map(
                (buttonData) => _generateButton(
                  buttonData,
                  context,
                  fill: isVertical,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _generateButton(ButtonData data, BuildContext context,
      {bool fill = false}) {
    const minWidth = 120.0;

    if (data.highlighted) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: fill ? double.infinity : minWidth,
          minHeight: 48,
        ),
        child: ElevatedButton(
          onPressed: () => data.onTap(context),
          child: Text(data.text),
        ),
      );
    } else {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: fill ? double.infinity : minWidth,
          minHeight: 48,
        ),
        child: OutlinedButton(
          onPressed: () => data.onTap(context),
          child: Text(data.text),
        ),
      );
    }
  }
}

class ButtonData {
  final String text;
  final void Function(BuildContext context) onTap;
  final bool highlighted;

  double get estimatedWidth => text.length * 18 * 1;

  ButtonData({
    required this.text,
    required this.onTap,
    this.highlighted = true,
  });
}
