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
          return Center(
            child: Text(
              "You're gonna have to work for your meal",
              textAlign: TextAlign.center,
            ),
          );
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
    // Aggregate by prizeUrl (assumption: same URL => same prize type)
    final Map<String, int> counts = {};
    final Map<String, Prizes> sample = {};
    for (final p in listData) {
      final key = p.prizeUrl;
      counts[key] = (counts[key] ?? 0) + 1;
      sample.putIfAbsent(key, () => p);
    }

    final List<Widget> displayPrizes = [];
    for (final entry in sample.entries) {
      final prizeUrl = entry.key;
      final gridItem = entry.value;
      final dupCount = counts[prizeUrl] ?? 1;

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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
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
                if (dupCount > 1)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'x$dupCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
