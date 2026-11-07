import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pickerv2/roll/roll_settings.dart';

/// One colour per choice, in choice order, for [look].
///
/// Colours depend only on the look, the theme and the choice's position, so a
/// choice keeps its colour across spins (and after "Remove & spin"), and
/// neighbours alternate light and dark so slices never blend together.
List<Color> rollPalette(RollLook look, int count, ColorScheme scheme) {
  if (count <= 0) return const [];
  final base = HSLColor.fromColor(scheme.primary).hue;
  return List.generate(count, (i) {
    final light = i.isEven;
    switch (look) {
      case RollLook.theme:
        // Hues spread up to ±60° around the theme colour.
        final spread = min(120.0, 24.0 * count);
        final offset =
            count == 1 ? 0.0 : -spread / 2 + spread * i / (count - 1);
        return HSLColor.fromAHSL(
                1, (base + offset) % 360, 0.45, light ? 0.78 : 0.42)
            .toColor();
      case RollLook.pastel:
        return HSLColor.fromAHSL(
                1, (base + 360 * i / count) % 360, 0.6, light ? 0.86 : 0.68)
            .toColor();
      case RollLook.vivid:
        return HSLColor.fromAHSL(
                1, (base + 360 * i / count) % 360, 0.75, light ? 0.58 : 0.42)
            .toColor();
      case RollLook.mono:
        final step = (i ~/ 2) % 3 * 0.06;
        return HSLColor.fromAHSL(
                1, base, 0.0, light ? 0.86 - step : 0.30 + step)
            .toColor();
    }
  });
}

/// Black or white, whichever reads better on [background].
Color labelColorOn(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black;
