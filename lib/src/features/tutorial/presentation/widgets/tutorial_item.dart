import 'package:flutter/material.dart';

class TutorialItem extends StatelessWidget {
  final String title;
  final String imgUrl;

  const TutorialItem({super.key, required this.title, required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 44),
        SizedBox(height: 30, width: 30, child: Image.asset(imgUrl)),
        SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
