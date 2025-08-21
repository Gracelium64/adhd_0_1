import 'package:flutter/material.dart';

class TutorialItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final String imgUrl;

  const TutorialItem({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30),
        SizedBox(height: 30, width: 30, child: Image.asset(imgUrl)),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subTitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
