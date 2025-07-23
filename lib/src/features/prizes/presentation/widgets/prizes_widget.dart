import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrizesWidget extends StatefulWidget {
  final void Function(Prizes prize)? onPrizeTap;

  const PrizesWidget(this.onPrizeTap, {super.key});

  @override
  State<PrizesWidget> createState() => _PrizesWidgetState();
}

class _PrizesWidgetState extends State<PrizesWidget> {
  late Future<List<Prizes>> myList;

  @override
  void initState() {
    super.initState();
    final repository = context.read<DataBaseRepository>();
    myList = repository.getPrizes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Prizes>>(
      future: myList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 35,
                    width: 35,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(width: 18),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No prizes yet!');
        }

        final data = snapshot.data!;

        return GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: buildImages(context, data),
        );
      },
    );
  }

  List<Widget> buildImages(BuildContext context, List<Prizes> listData) {
    List<Widget> displayPrizes = [];

    for (Prizes gridItem in listData) {
      displayPrizes.add(
        GestureDetector(
          onTap: () {
            if (widget.onPrizeTap != null) {
              widget.onPrizeTap!(gridItem);
            }
          },
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
