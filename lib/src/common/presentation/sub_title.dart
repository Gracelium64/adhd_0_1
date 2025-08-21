import 'package:flutter/material.dart';

class SubTitle extends StatelessWidget {
  final String sub;

  const SubTitle({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 40, 0),
      child: Text(
        sub,
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
