import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:pickerv2/roll/result_card.dart';
import 'package:pickerv2/roll/roll_palette.dart';
import 'package:pickerv2/roll/roll_settings.dart';
import 'package:pickerv2/roll/roll_style_sheet.dart';
import 'package:pickerv2/roll/slot_reel.dart';

/// The roll screen: spins the choices as a wheel or a slot reel (the user's
/// pick, remembered), then shows the result with "Spin again" and
/// "Remove & spin".
class Roulette extends StatefulWidget {
  /// Choices keyed 1..n, as built by ChoicesOperation.ToLabels().
  final Map<int, String> labels;

  const Roulette(this.labels, {super.key});

  @override
  RouletteState createState() => RouletteState();
}

class RouletteState extends State<Roulette> {
  /// Every choice, in order. Colours are tied to these positions so a choice
  /// keeps its colour after others are removed.
  late final List<String> _all = [
    for (final e
        in (widget.labels.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key))))
      e.value,
  ];

  /// Indices into [_all] still in this roll ("Remove & spin" drops one).
  late final List<int> _remaining = [for (var i = 0; i < _all.length; i++) i];

  final StreamController<int> controller = StreamController<int>.broadcast();
  final _random = Random();
  RollSettings _settings = const RollSettings();

  /// Position in [_remaining] the current or last spin lands on. Labels are
  /// laid out for this resting position so none read upside down.
  int target = 0;
  bool _hasRolled = false;
  bool _animating = false;
  Duration _duration = const Duration(milliseconds: 4500);
  int _rotations = 10;

  bool get _showResult => _hasRolled && !_animating;

  @override
  void initState() {
    super.initState();
    RollSettings.load().then((s) {
      if (mounted) setState(() => _settings = s);
    });
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  void handleRoll() {
    if (_animating || _remaining.length < 2) return;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    setState(() {
      target = _random.nextInt(_remaining.length);
      // A slightly different spin every time, so it never looks scripted.
      // The pick itself is uniform: every choice is equally likely.
      _duration = reduceMotion
          ? const Duration(milliseconds: 600)
          : Duration(milliseconds: 4000 + _random.nextInt(1500));
      _rotations = reduceMotion ? 1 : 8 + _random.nextInt(5);
    });
    // Start after the rebuild, so the spin uses this roll's duration.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.add(target);
    });
  }

  /// Takes the picked choice out of this roll (not out of the saved list)
  /// and spins the rest: for deciding an order or eliminating options.
  void _removeAndSpin() {
    if (_animating || _remaining.length <= 2) return;
    setState(() {
      _remaining.removeAt(target);
      target = 0;
      _hasRolled = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) handleRoll();
    });
  }

  void _onSpinStart() => setState(() {
        _hasRolled = true;
        _animating = true;
      });

  void _onSpinEnd() {
    HapticFeedback.mediumImpact();
    setState(() => _animating = false);
  }

  Future<void> _openStyleSheet() {
    return showRollStyleSheet(
      context,
      settings: _settings,
      onChanged: (s) {
        setState(() => _settings = s);
        s.save();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = rollPalette(_settings.look, _all.length, scheme);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: const Text('Test Your Luck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Roll style',
            onPressed: _animating ? null : _openStyleSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              height: size.height * 0.42,
              child: _settings.style == RollStyle.reel
                  ? _reel(palette)
                  : _wheel(palette, scheme),
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _below(palette),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _below(List<Color> palette) {
    final theme = Theme.of(context);
    if (_animating) {
      return Text('Spinning…',
          key: const ValueKey('spinning'),
          style: theme.textTheme.titleLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant));
    }
    if (_showResult) {
      final picked = _remaining[target];
      return ResultCard(
        key: ValueKey('result-$picked-${_remaining.length}'),
        choice: _all[picked],
        color: palette[picked],
        onSpinAgain: handleRoll,
        onRemoveAndSpin: _remaining.length > 2 ? _removeAndSpin : null,
      );
    }
    return Column(
      key: const ValueKey('prompt'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _settings.style == RollStyle.reel
              ? 'Tap Roll or swipe the reel'
              : 'Tap Roll or swipe the wheel',
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        // The screen's one action: a full-size filled button.
        FilledButton.icon(
          onPressed: handleRoll,
          icon: const Icon(Icons.casino_outlined),
          label: const Text('Roll'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(200, 56),
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /// A slice's colour; once a result is showing, the others fade to a
  /// near-neutral tint so the pick stands out in every look (the Theme look
  /// is pale, so fading alone didn't separate it).
  Color _sliceColor(List<Color> palette, int position) {
    final color = palette[_remaining[position]];
    if (!_showResult || position == target) return color;
    final faded = HSLColor.fromColor(
            Color.lerp(color, Theme.of(context).colorScheme.surface, 0.8)!)
        .withSaturation(0.05)
        .toColor();
    return faded;
  }

  bool _isPick(int position) => _showResult && position == target;

  Widget _wheel(List<Color> palette, ColorScheme scheme) {
    final count = _remaining.length;
    return FortuneWheel(
      selected: controller.stream,
      animateFirst: false,
      duration: _duration,
      rotationCount: _rotations,
      // A light tick each time a slice boundary passes the pointer.
      hapticImpact: HapticImpact.light,
      indicators: [
        FortuneIndicator(
          alignment: Alignment.topCenter,
          child: TriangleIndicator(color: scheme.primary),
        ),
      ],
      items: [
        for (var p = 0; p < count; p++)
          FortuneItem(
            // The slice lays its label out across the radius, centred
            // halfway out: one line with an ellipsis, kept off the hub and
            // the rim. The result card always shows the full name.
            child: LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                width: constraints.maxWidth * 0.8,
                child: RotatedBox(
                  // Labels run outward from the hub, so on the left half of
                  // the resting wheel they'd read upside down: turn those
                  // half a turn.
                  quarterTurns: labelReadsUpsideDown(p, target, count) ? 2 : 0,
                  child: Text(
                    _all[_remaining[p]],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            style: FortuneItemStyle(
              color: _sliceColor(palette, p),
              // The pick gets a thick outline in the theme colour.
              borderColor: _isPick(p) ? scheme.primary : scheme.surface,
              borderWidth: _isPick(p) ? 5 : 2,
              textStyle: TextStyle(
                color: labelColorOn(_sliceColor(palette, p)),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
      onAnimationStart: _onSpinStart,
      onAnimationEnd: _onSpinEnd,
      onFling: handleRoll,
    );
  }

  Widget _reel(List<Color> palette) {
    return SlotReel(
      labels: [for (final i in _remaining) _all[i]],
      colors: [for (final i in _remaining) palette[i]],
      selected: controller.stream,
      duration: _duration,
      dimExcept: _showResult ? target : null,
      onAnimationStart: _onSpinStart,
      onAnimationEnd: _onSpinEnd,
      onFling: handleRoll,
    );
  }
}

/// Whether slice [index]'s label would read upside down when the wheel rests
/// with slice [target] under the top pointer. Slices go clockwise from the
/// top; labels run outward from the hub, so those centred on the left half
/// (strictly between 180 and 360 degrees) face the wrong way.
bool labelReadsUpsideDown(int index, int target, int count) {
  if (count <= 0) return false;
  final degrees = ((index - target) % count) * 360 / count;
  return degrees > 180 && degrees < 360;
}
