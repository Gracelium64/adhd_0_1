import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
import 'package:flutter/material.dart';

class PrizesWidget extends StatefulWidget {
  final DataBaseRepository repository;

  const PrizesWidget(this.repository, {super.key});

  @override
  State<PrizesWidget> createState() => _PrizesWidgetState();
}

class _PrizesWidgetState extends State<PrizesWidget> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: buildImages(context),
    );
  }

  List<Widget> buildImages(BuildContext context) {
    List<Widget> displayPrizes = [];

    for (Prizes gridItem in widget.repository.getPrizes()) {
      displayPrizes.add(
        GestureDetector(
          onTap: () {},
          child: Card(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: gridItem.prizeUrl,
                    child: Image.asset(
                      gridItem.prizeUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return displayPrizes;
  }
}
