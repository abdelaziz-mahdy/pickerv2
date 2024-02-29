import 'dart:typed_data';

import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:math';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_color/random_color.dart';
import 'dart:ui' as ui;

class Roulette extends StatefulWidget {
  final Map<int, String> labels;

  Roulette(this.labels);

  @override
  _RouletteState createState() => _RouletteState();
}

class _RouletteState extends State<Roulette> {
  final StreamController _dividerController = StreamController<int>();
  bool notloaded = true;
  final _wheelNotifier = StreamController<double>();
  var chartimage;
  dispose() {
    _dividerController.close();
    _wheelNotifier.close();
    super.dispose();
  }

  RandomColor _randomColor = RandomColor();

  Color get_random_color() {
    return _randomColor.randomColor(colorBrightness: ColorBrightness.random);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Test Your Luck',
          style: GoogleFonts.roboto(
            fontSize: 24,
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.secondary
                : Colors.white,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: FortuneWheel(
                items: [
                  for (var i in widget.labels.entries)
                    FortuneItem(
                        child: Text(
                      i.value,
                    ))
                ],
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder(
              stream: _dividerController.stream,
              builder: (context, snapshot) => snapshot.hasData
                  ? RouletteScore(snapshot.data, widget.labels)
                  : Container(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text(
                'Roll',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: () =>
                  _wheelNotifier.sink.add(_generateRandomVelocity()),
            )
          ],
        ),
      ),
    );
  }

  double _generateRandomVelocity() => (Random().nextDouble() * 6000) + 15000;

  double _generateRandomAngle() => Random().nextDouble() * pi * 2;
}

class RouletteScore extends StatelessWidget {
  final int selected;
  final Map<int, String> labels;

  RouletteScore(this.selected, this.labels);

  @override
  Widget build(BuildContext context) {
    return Text('${labels[selected]}',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 24.0,
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).colorScheme.secondary
              : Colors.white,
        ));
  }
}

class circleWheel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularMenu(items: []);
  }
}

class ChartChoice {
  final String choicetext;
  final int share;
  final charts.Color color;
  ChartChoice(this.choicetext, this.share, Color color)
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}
