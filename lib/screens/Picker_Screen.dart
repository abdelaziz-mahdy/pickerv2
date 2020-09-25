import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_spinning_wheel/flutter_spinning_wheel.dart';
import 'package:circular_menu/circular_menu.dart';

class Roulette extends StatelessWidget {
  final StreamController _dividerController = StreamController<int>();

  final _wheelNotifier = StreamController<double>();
  final Map<int,String> labels ;

  Roulette(this.labels);

  dispose() {
    _dividerController.close();
    _wheelNotifier.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0,centerTitle:true,title: Text('Test Your Luck')),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinningWheel(
              Image.asset('assets/images/roulette-center-300.png'),
              width: 310,
              height: 310,
              initialSpinAngle: _generateRandomAngle(),
              spinResistance: 0.6,
              canInteractWhileSpinning: false,
              dividers: labels.length,
              onUpdate: _dividerController.add,
              onEnd: _dividerController.add,
              shouldStartOrStop: _wheelNotifier.stream,
              //secondaryImage: ,
            ),
            SizedBox(height: 30),
            StreamBuilder(
              stream: _dividerController.stream,
              builder: (context, snapshot) =>
              snapshot.hasData ? RouletteScore(snapshot.data,labels) : Container(),
            ),
            SizedBox(height: 30),

            FlatButton(
              padding: const EdgeInsets.all(5),
              color: Colors.white,
              child: Text('Roll',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue
                ),),
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
  final Map<int,String> labels;


  RouletteScore(this.selected,this.labels);

  @override
  Widget build(BuildContext context) {
    return Text('${labels[selected]}',
        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 24.0));
  }
}
class circleWheel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularMenu(items: []);
  }
}
