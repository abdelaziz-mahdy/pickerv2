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

  @override
  Widget build(BuildContext context) {
    RandomColor _randomColor = RandomColor();

    Color get_random_color() {
      return _randomColor.randomColor(colorBrightness: ColorBrightness.random);
    }

    List<ChartChoice> data = [];
    for (int i = 0; i < widget.labels.length; i++) {
      data.add(ChartChoice(widget.labels[i + 1]!, 10, get_random_color()));
    }
    data.forEach((element) {
      print(element.choicetext);
    });
    print(widget.labels);
    var series = [
      charts.Series(
        domainFn: (ChartChoice choice, _) => choice.choicetext,
        measureFn: (ChartChoice choice, _) => choice.share,
        colorFn: (ChartChoice choice, _) => choice.color,
        id: 'Sales',
        data: data,
      )
    ];
    charts.Color color_to_chartscolor(Color color) {
      return charts.Color(
          r: color.red, g: color.green, b: color.blue, a: color.alpha);
    }

    var chart = charts.PieChart(
      series,
      defaultRenderer: charts.ArcRendererConfig(
          startAngle: (-series.length * 1.5).toDouble(),
          arcRendererDecorators: [
            charts.ArcLabelDecorator(
                insideLabelStyleSpec: new charts.TextStyleSpec(
                    fontSize: 30,
                    color: color_to_chartscolor(
                        Theme.of(context).brightness == Brightness.light
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.white)),
                outsideLabelStyleSpec: new charts.TextStyleSpec(
                    fontSize: 30,
                    color: color_to_chartscolor(
                        Theme.of(context).brightness == Brightness.light
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.white))),
          ]),
      animate: false,
    );
    GlobalKey globalKey = GlobalKey();

    Future<Uint8List> cropRonded(ui.Image image) async {
      var recorder = ui.PictureRecorder();
      var canvas = Canvas(recorder);
      var imageSize = Size(image.width.toDouble(), image.height.toDouble());
      var boundsToCrop = Rect.fromCenter(
          center: imageSize.center(Offset.zero),
          width: imageSize.shortestSide,
          height: imageSize.shortestSide);
      var matrix = Matrix4.translationValues(
              -boundsToCrop.topLeft.dx, -boundsToCrop.topLeft.dy, 0)
          .storage;
      var paint = Paint()
        ..shader = ImageShader(image, TileMode.clamp, TileMode.clamp, matrix);
      var radius = imageSize.shortestSide / 2;
      canvas.drawCircle(Offset(radius, radius), radius, paint);

      ui.Image cropped = await recorder.endRecording().toImage(
          imageSize.shortestSide.toInt(), imageSize.shortestSide.toInt());
      var byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    }

    Future<void> _capturePng() async {
      late ui.Image image;
      bool catched = false;
      RenderRepaintBoundary boundary = globalKey!.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      try {
        image = await boundary.toImage();
        catched = true;
      } catch (exception) {
        catched = false;
        Timer(Duration(milliseconds: 1), () {
          _capturePng();
        });
      }
      if (catched) {
        ByteData byteData =
            (await image.toByteData(format: ui.ImageByteFormat.png))!;
        //Uint8List pngBytes = byteData.buffer.asUint8List();
        var pngBytes = await cropRonded(image);
        print(pngBytes);
        setState(() {
          notloaded = false;
          try {
            print("converted");
            chartimage = Image.memory(pngBytes);
          } catch (exception) {
            print("falied");
          }
        });
      }
    }

    if (notloaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _capturePng());
    }
    double size = MediaQuery.of(context).size.width;

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
        child: notloaded
            ? RepaintBoundary(key: globalKey, child: chart)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FortuneWheel(
                    items: [
                      for (var i in widget.labels.entries)
                        FortuneItem(
                            child: Text(
                          i.value,
                        ))
                    ],
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
