import 'package:flutter/foundation.dart';

/// Simple singleton to broadcast a request to open the Dailys tab.
class NotificationRouter {
  NotificationRouter._();
  static final NotificationRouter instance = NotificationRouter._();

  /// Emits true when a notification tap should switch to the Dailys tab.
  final ValueNotifier<bool> openDailysRequested = ValueNotifier<bool>(false);

  void openDailys() {
    openDailysRequested.value = true;
  }
}
