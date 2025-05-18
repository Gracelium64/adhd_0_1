import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
////// TODO: add variable for onTap
      child: Image.asset('assets/img/buttons/cancel.png'),
    );
  }
}

