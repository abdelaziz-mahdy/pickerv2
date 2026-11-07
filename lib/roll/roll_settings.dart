import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// How the pick is animated.
enum RollStyle {
  wheel('Wheel'),
  reel('Slot reel');

  const RollStyle(this.label);
  final String label;
}

/// The colours used for the choices.
enum RollLook {
  theme('Theme'),
  pastel('Pastel'),
  vivid('Vivid'),
  mono('Mono');

  const RollLook(this.label);
  final String label;
}

/// The roll style and look the user picked, remembered between launches in a
/// small JSON file next to the app's database.
class RollSettings {
  const RollSettings(
      {this.style = RollStyle.wheel, this.look = RollLook.theme});

  final RollStyle style;
  final RollLook look;

  static const fileName = 'roll_settings.json';

  RollSettings copyWith({RollStyle? style, RollLook? look}) =>
      RollSettings(style: style ?? this.style, look: look ?? this.look);

  Map<String, String> toJson() => {'style': style.name, 'look': look.name};

  static RollSettings fromJson(Map<String, dynamic> json) => RollSettings(
        style: RollStyle.values.firstWhere((s) => s.name == json['style'],
            orElse: () => RollStyle.wheel),
        look: RollLook.values.firstWhere((l) => l.name == json['look'],
            orElse: () => RollLook.theme),
      );

  static Future<File> _file(String? directory) async =>
      File(join(directory ?? await getDatabasesPath(), fileName));

  /// Defaults when nothing was saved yet or the file can't be read.
  static Future<RollSettings> load({String? directory}) async {
    try {
      final file = await _file(directory);
      if (!await file.exists()) return const RollSettings();
      return fromJson(
          jsonDecode(await file.readAsString()) as Map<String, dynamic>);
    } catch (_) {
      return const RollSettings();
    }
  }

  Future<void> save({String? directory}) async {
    try {
      await (await _file(directory)).writeAsString(jsonEncode(toJson()));
    } catch (_) {
      // Not remembering a preference isn't worth interrupting a roll for.
    }
  }

  @override
  bool operator ==(Object other) =>
      other is RollSettings && other.style == style && other.look == look;

  @override
  int get hashCode => Object.hash(style, look);
}
