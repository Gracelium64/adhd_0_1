import 'package:flutter/material.dart';

class Bla extends StatefulWidget {
  const Bla({super.key});

  @override
  State<Bla> createState() => _BlaState();
}

class _BlaState extends State<Bla> {
  double sliderValue = 0;
  bool showSlider = false;
  double boxSize = 48;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Align(
          alignment: Alignment.center,
          child: Text('Steckbrief Berlin'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Name'), Text('Berlin')],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Einwohner'), Text('Viel zu viele')],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sehenswürdigkeiten'),
                Text('App Akademie, Berghain'),
              ],
            ),
            SizedBox(height: 50),
            FilledButton(
              onPressed: () {
                setState(() {
                  showSlider = !showSlider;
                  if (boxSize == 48) {
                    boxSize = 0;
                  } else if (boxSize == 0) {
                    boxSize = 48;
                  }
                });
              },

              child: Text('Stadt Bewerten'),
            ),

            SizedBox(height: boxSize),
            if (showSlider)
              Slider(
                value: sliderValue,
                onChanged: (newValue) {
                  setState(() {
                    sliderValue = newValue;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
