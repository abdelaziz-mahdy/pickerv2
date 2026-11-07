import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_color/random_color.dart';

class Roulette extends StatefulWidget {
  final Map<int, String> labels;

  const Roulette(this.labels, {super.key});

  @override
  RouletteState createState() => RouletteState();
}

class RouletteState extends State<Roulette> {
  ValueNotifier<int> selected = ValueNotifier<int>(0);
  ValueNotifier<bool> animating = ValueNotifier<bool>(false);
  // No result until the wheel has been spun once: before that, the name
  // under the pointer is just the first choice, not a pick.
  ValueNotifier<bool> hasRolled = ValueNotifier<bool>(false);
  StreamController<int> controller = StreamController<int>.broadcast();
  final List<Color> colors = [];
  @override
  dispose() {
    controller.close();
    selected.dispose();
    animating.dispose();
    hasRolled.dispose();
    super.dispose();
  }

  final RandomColor _randomColor = RandomColor();

  @override
  void initState() {
    for (int i = 0; i < widget.labels.keys.length; i++) {
      colors.add(getRandomColor());
    }
    // TODO: implement initState
    super.initState();
  }

  Color getRandomColor() {
    return _randomColor.randomColor(colorBrightness: ColorBrightness.random);
  }

  static Color labelColorFor(Color slice) {
    return ThemeData.estimateBrightnessForColor(slice) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  void handleRoll() {
    // Generate a random number from 0 to widget.labels.keys.length - 1
    int randomIndex = Random().nextInt(widget.labels.keys.length);
    // Add the random number to the stream
    controller.add(randomIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Test Your Luck',
          style: GoogleFonts.roboto(
            fontSize: 24,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: FortuneWheel(
                selected: controller.stream,
                animateFirst: false,
                items: [
                  for (var i in widget.labels.entries)
                    FortuneItem(
                        // The slice lays its label out across the radius,
                        // centred halfway out. One line with an ellipsis, kept
                        // off the hub and the rim, instead of wrapping into
                        // lines the slice's edges clip.
                        child: LayoutBuilder(
                          builder: (context, constraints) => SizedBox(
                            width: constraints.maxWidth * 0.8,
                            child: Text(
                              i.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        style: FortuneItemStyle(
                          color: colors[i.key - 1],
                          // Slice colours are random, light or dark: pick
                          // the label colour that stays readable on each.
                          textStyle: TextStyle(
                            color: labelColorFor(colors[i.key - 1]),
                          ),
                        ))
                ],
                onFocusItemChanged: (value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // The screen may be closed mid-spin before this runs.
                    if (mounted) selected.value = value;
                  });
                },
                onAnimationStart: () {
                  hasRolled.value = true;
                  animating.value = true;
                },
                onAnimationEnd: () {
                  animating.value = false;
                },
                onFling: () => handleRoll(),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ListenableBuilder(
                listenable: Listenable.merge([selected, hasRolled]),
                builder: (context, child) {
                  if (!hasRolled.value) {
                    return Text(
                      'Tap Roll or swipe the wheel',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).hintColor,
                      ),
                    );
                  }
                  return RouletteScore(selected.value, widget.labels);
                }),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ValueListenableBuilder(
              valueListenable: animating,
              builder: (context, value, child) {
                return Center(
                  child: ElevatedButton(
                    onPressed: value ? null : handleRoll,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Center(
                        child: const Text(
                          'Roll',
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class RouletteScore extends StatelessWidget {
  final int selected;
  final Map<int, String> labels;

  const RouletteScore(this.selected, this.labels, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text('${labels[selected + 1]}',
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 24.0,
        ));
  }
}
