import 'package:flutter/material.dart';

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
////// TODO: add variable for onTap
      child: Image.asset('assets/img/buttons/confirm.png'),
    );
  }
}

