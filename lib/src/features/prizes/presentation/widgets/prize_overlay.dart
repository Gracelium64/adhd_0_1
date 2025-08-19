import 'dart:ui';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';

class PrizeOverlay extends StatelessWidget {
  final String prizeImageUrl;
  final GlobalKey
  captureKey; // RepaintBoundary key to capture the composited image
  final VoidCallback onShare;
  final VoidCallback onClose;

  const PrizeOverlay({
    super.key,
    required this.prizeImageUrl,
    required this.captureKey,
    required this.onShare,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    Future<int> dupCountFuture() async {
      final repo = context.read<DataBaseRepository>();
      final List<Prizes> list = await repo.getPrizes();
      return list.where((p) => p.prizeUrl == prizeImageUrl).length;
    }

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
              // Composited image (image + duplicate badge) for sharing
              RepaintBoundary(
                key: captureKey,
                child: SizedBox(
                  width: 230,
                  height: 230,
                  child: FutureBuilder<int>(
                    future: dupCountFuture(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 1;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              prizeImageUrl,
                              fit: BoxFit.fill,
                            ),
                          ),
                          if (count > 1)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'x$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
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
