import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final void Function() onPressed;

  const CancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Image.asset('assets/img/buttons/cancel.png'));
  }
}
