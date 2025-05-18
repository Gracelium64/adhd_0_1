import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
////// TODO: add variable for onTap
      child: Image.asset('assets/img/buttons/delete.png'),
    );
  }
}

