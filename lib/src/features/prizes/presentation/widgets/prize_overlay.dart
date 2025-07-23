import 'dart:ui';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class PrizeOverlay extends StatelessWidget {
  final String prizeImageUrl;
  final VoidCallback onShare;
  final VoidCallback onClose;

  const PrizeOverlay({
    super.key,
    required this.prizeImageUrl,
    required this.onShare,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          width: 300,
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Palette.basicBitchWhite.withAlpha(175),
                offset: Offset(-0, -0),
                blurRadius: 5,
                blurStyle: BlurStyle.inner,
              ),
              BoxShadow(
                color: Palette.basicBitchBlack.withAlpha(125),
                offset: Offset(4, 4),
                blurRadius: 5,
              ),
              BoxShadow(
                color: Palette.monarchPurple1Opacity,
                offset: Offset(0, 0),
                blurRadius: 20,
                blurStyle: BlurStyle.solid,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Look!',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 24),
              ),
              Text(
                'A wild... whatever this thing is',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Image.asset(prizeImageUrl, width: 230, height: 230),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onShare,
                icon: Icon(Icons.share),
                label: Text('Share'),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: IconButton(
                  icon: Image.asset('assets/img/buttons/confirm.png'),
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
