import 'package:flutter/material.dart';

class ConfirmButton extends StatelessWidget {
  // Allow null to represent disabled state, same as Flutter buttons.
  final VoidCallback? onPressed;

  const ConfirmButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    // Provide Material ancestor for proper InkWell semantics across platforms.
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed, // null disables tap hit-testing
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: Image.asset('assets/img/buttons/confirm.png'),
          ),
        ),
      ),
    );
  }
}
