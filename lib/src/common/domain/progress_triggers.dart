import 'package:flutter/foundation.dart';

final ValueNotifier<Future<double>> dailyProgressFuture = ValueNotifier(
  Future.value(0),
);
final ValueNotifier<Future<double>> weeklyProgressFuture = ValueNotifier(
  Future.value(0),
);
final ValueNotifier<Future<double>> deadnlineProgressFuture = ValueNotifier(
  Future.value(0),
);
final ValueNotifier<Future<double>> questProgressFuture = ValueNotifier(
  Future.value(0),
);
