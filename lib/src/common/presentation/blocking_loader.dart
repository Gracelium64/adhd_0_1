import 'package:flutter/material.dart';

/// Shows a centered, blocking loader while [task] is running.
/// Dismisses automatically when the task completes or throws.
Future<T> showBlockingLoaderDuring<T>(
  BuildContext context,
  Future<T> Function() task,
) async {
  // Show a modal, non-dismissible overlay with a centered spinner
  if (!context.mounted) {
    // If the context isn't mounted, just run the task
    return await task();
  }
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: Colors.black45,
    builder:
        (_) => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
  );

  try {
    return await task();
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
