import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:term_buddy/themes.dart';


class AsyncValuePage<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRefresh;
  final Widget Function(BuildContext context, Widget child)? frameBuilder;

  const AsyncValuePage({
    Key? key,
    required this.asyncValue,
    required this.builder,
    this.onRefresh,
    this.frameBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return asyncValue.map(
        data: (data) => builder(context, data.value),
        error: (error) {
          return ErrorScreen(
              message: error.error.toString(), onRetry: onRefresh);
        },
        loading: (_) => const LoadSpinner());
  }
}

class ErrorScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;
  final bool showAppBar;

  const ErrorScreen({
    Key? key,
    this.onRetry,
    this.message,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
        title: const Text('Error'),
      )
          : null,
      body: ErrorView(
        onRetry: onRetry,
        message: message,
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const ErrorView({
    this.onRetry,
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Material(
                  color: Colors.transparent,
                  child: Text(
                    message ?? 'Error',
                    style: context
                        .textTheme()
                        .bodyMedium,
                  )),
            ),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}


class LoadSpinner extends StatelessWidget {
  final Color? color;
  final double strokeWidth;

  const LoadSpinner({
    Key? key,
    this.color,
    this.strokeWidth = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 64),
        child:  AspectRatio(
            aspectRatio: 1,
            child: CircularProgressIndicator(
              color: color ?? primary,
              strokeWidth: strokeWidth,
            )
        ),
      ),
    );
  }
}

