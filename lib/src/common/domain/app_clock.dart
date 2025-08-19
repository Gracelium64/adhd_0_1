import 'package:flutter/foundation.dart';

/// Global clock with an optional override for debugging time-dependent logic.
class AppClock {
  AppClock._();
  static final AppClock instance = AppClock._();

  /// If non-null, this value is returned by now().
  final ValueNotifier<DateTime?> _override = ValueNotifier<DateTime?>(null);

  /// Returns the effective "now": override (if set) or DateTime.now().
  DateTime now() => _override.value ?? DateTime.now();

  /// Whether an override is active.
  bool get isOverridden => _override.value != null;

  /// Current override value, if any.
  DateTime? get overrideValue => _override.value;

  /// Set an override value.
  void setOverride(DateTime value) => _override.value = value;

  /// Clear the override and fall back to real system time.
  void clearOverride() => _override.value = null;

  /// Listen for override changes.
  ValueListenable<DateTime?> get listenable => _override;
}
