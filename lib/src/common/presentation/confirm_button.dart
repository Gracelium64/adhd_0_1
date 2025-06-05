import 'package:flutter/material.dart';

class ConfirmButton extends StatelessWidget {
  final void Function() onPressed;
  
  const ConfirmButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Image.asset('assets/img/buttons/confirm.png'));
  }
}

