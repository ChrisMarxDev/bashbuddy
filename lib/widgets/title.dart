import 'package:flutter/material.dart';
import 'package:term_buddy/themes.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const TitleWidget({
    Key? key,
    required this.title,
    this.actions = const <Widget>[],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  title,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: context.primary(),
                      ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

class SubTitleWidget extends StatelessWidget {
  final String title;

  const SubTitleWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 32),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            title,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: context.primary(),
                ),
          ),
        ),
      ),
    );
  }
}
