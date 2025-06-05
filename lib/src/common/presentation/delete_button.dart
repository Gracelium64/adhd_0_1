import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
final void Function() onPressed;

  const DeleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Image.asset('assets/img/buttons/delete.png'));
  }
}

