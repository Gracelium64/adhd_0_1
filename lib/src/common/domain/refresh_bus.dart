import 'package:flutter/foundation.dart';

/// Global refresh bus to notify task lists to refetch after resets or key events.
class RefreshBus extends ChangeNotifier {
  int _tick = 0;
  int get tick => _tick;

  void bump() {
    _tick++;
    notifyListeners();
  }
}
