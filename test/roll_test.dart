import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickerv2/roll/result_card.dart';
import 'package:pickerv2/roll/roll_palette.dart';
import 'package:pickerv2/roll/roll_settings.dart';
import 'package:pickerv2/roll/slot_reel.dart';
import 'package:pickerv2/screens/picker_screen.dart';

/// Labels the reel draws filled (bold) rather than as quiet outlines.
List<String?> boldReelLabels(WidgetTester tester) => [
      for (final e in find
          .descendant(of: find.byType(SlotReel), matching: find.byType(Text))
          .evaluate())
        if ((e.widget as Text).style?.fontWeight == FontWeight.w600)
          (e.widget as Text).data,
    ];

void main() {
  final scheme = ThemeData.light().colorScheme;

  group('rollPalette', () {
    test('one colour per choice for every look', () {
      for (final look in RollLook.values) {
        expect(rollPalette(look, 7, scheme), hasLength(7), reason: look.name);
      }
      expect(rollPalette(RollLook.theme, 0, scheme), isEmpty);
    });

    test('is stable: same look, theme and count give the same colours', () {
      expect(rollPalette(RollLook.vivid, 5, scheme),
          rollPalette(RollLook.vivid, 5, scheme));
    });

    test('neighbours alternate light and dark so slices never blend', () {
      for (final look in RollLook.values) {
        final colors = rollPalette(look, 6, scheme);
        for (var i = 0; i + 1 < colors.length; i++) {
          final a = HSLColor.fromColor(colors[i]).lightness;
          final b = HSLColor.fromColor(colors[i + 1]).lightness;
          expect((a - b).abs(), greaterThan(0.15),
              reason: '${look.name} slices $i and ${i + 1}');
        }
      }
    });

    test('mono has no hue', () {
      for (final c in rollPalette(RollLook.mono, 6, scheme)) {
        expect(HSLColor.fromColor(c).saturation, closeTo(0, 0.01));
      }
    });
  });

  group('RollSettings', () {
    test('saves and loads the user\'s pick', () async {
      final dir = await Directory.systemTemp.createTemp('roll_settings');
      addTearDown(() => dir.delete(recursive: true));
      const picked = RollSettings(style: RollStyle.reel, look: RollLook.mono);
      await picked.save(directory: dir.path);
      expect(await RollSettings.load(directory: dir.path), picked);
    });

    test('falls back to the defaults when nothing is saved or it is broken',
        () async {
      final dir = await Directory.systemTemp.createTemp('roll_settings');
      addTearDown(() => dir.delete(recursive: true));
      expect(
          await RollSettings.load(directory: dir.path), const RollSettings());
      await File('${dir.path}/${RollSettings.fileName}').writeAsString('{oops');
      expect(
          await RollSettings.load(directory: dir.path), const RollSettings());
    });
  });

  group('Roulette', () {
    const labels = {1: 'Pizza', 2: 'Sushi', 3: 'Ramen'};

    Future<void> openRoll(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Roulette(labels)));
      await tester.pump();
    }

    testWidgets('rolling shows the pick in a result card', (tester) async {
      await openRoll(tester);
      expect(find.text('Tap Roll or swipe the wheel'), findsOneWidget);

      await tester.tap(find.text('Roll'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Spinning…'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(ResultCard), findsOneWidget);
      final card = tester.widget<ResultCard>(find.byType(ResultCard));
      expect(labels.values, contains(card.choice));
      expect(find.text('Spin again'), findsOneWidget);
      expect(find.text('Remove & spin'), findsOneWidget);
    });

    testWidgets('Remove & spin takes the pick out of this roll',
        (tester) async {
      await openRoll(tester);
      await tester.tap(find.text('Roll'));
      await tester.pumpAndSettle();
      final first = tester.widget<ResultCard>(find.byType(ResultCard)).choice;

      await tester.tap(find.text('Remove & spin'));
      await tester.pumpAndSettle();
      final second = tester.widget<ResultCard>(find.byType(ResultCard)).choice;
      expect(second, isNot(first));
      // Two left: removing another would leave nothing to pick from.
      expect(find.text('Remove & spin'), findsNothing);
    });

    testWidgets('a quick swipe across the wheel spins it', (tester) async {
      await openRoll(tester);
      final wheel = tester.getRect(find.byType(FortuneWheel));
      // Starts just off the rim of the disc, inside the wheel area.
      await tester.flingFrom(
          wheel.topCenter + const Offset(-100, 30), const Offset(200, 0), 1500);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Spinning…'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(ResultCard), findsOneWidget);
    });

    testWidgets('switching style clears the last result', (tester) async {
      await openRoll(tester);
      await tester.tap(find.text('Roll'));
      await tester.pumpAndSettle();
      expect(find.byType(ResultCard), findsOneWidget);

      await tester.tap(find.byTooltip('Roll style'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Slot reel'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10)); // close the sheet
      await tester.pumpAndSettle();

      expect(find.byType(ResultCard), findsNothing);
      expect(find.text('Tap Roll or swipe the reel'), findsOneWidget);
      // The new view rests on the first choice, so labels are laid out for
      // that, not for the old pick (which left some reading upside down).
      expect(tester.state<RouletteState>(find.byType(Roulette)).target, 0);
    });

    testWidgets('the style sheet switches to the slot reel', (tester) async {
      await openRoll(tester);
      await tester.tap(find.byTooltip('Roll style'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Slot reel'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10)); // close the sheet
      await tester.pumpAndSettle();

      expect(find.byType(SlotReel), findsOneWidget);
      expect(find.text('Tap Roll or swipe the reel'), findsOneWidget);

      await tester.tap(find.text('Roll'));
      await tester.pumpAndSettle();
      expect(find.byType(ResultCard), findsOneWidget);

      // The reel rests with the pick in the frame and a choice in every
      // slot around it (the old 3D drum left the one above the frame empty).
      final pick = tester.widget<ResultCard>(find.byType(ResultCard)).choice;
      final centre = tester.getCenter(find.byType(SlotReel));
      String? labelAt(Offset point) {
        for (final e in find
            .descendant(of: find.byType(SlotReel), matching: find.byType(Text))
            .evaluate()) {
          if (tester.getRect(find.byWidget(e.widget)).contains(point)) {
            return (e.widget as Text).data;
          }
        }
        return null;
      }

      expect(labelAt(centre), pick);
      for (final rows in [-2, -1, 1, 2]) {
        expect(
            labelAt(centre.translate(0, rows * SlotReel.itemExtent)), isNotNull,
            reason: 'row $rows from the frame');
      }
      // Only the pick's row in the frame stays filled (bold); the rest,
      // repeats of the pick included, are quiet outlines.
      expect(boldReelLabels(tester), [pick]);

      // Mid-spin, every label stays centred in its own row.
      await tester.tap(find.text('Spin again'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      final texts = find.descendant(
          of: find.byType(SlotReel), matching: find.byType(Text));
      expect(texts, findsWidgets);
      for (final e in texts.evaluate()) {
        final text = find.byWidget(e.widget);
        final box =
            find.ancestor(of: text, matching: find.byType(AnimatedContainer));
        expect(tester.getCenter(text).dy,
            closeTo(tester.getCenter(box.first).dy, 1),
            reason: (e.widget as Text).data);
      }
      await tester.pumpAndSettle();
    });

    testWidgets('a reel down to two choices shows one filled pick',
        (tester) async {
      await openRoll(tester);
      await tester.tap(find.byTooltip('Roll style'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Slot reel'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Roll'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove & spin'));
      await tester.pumpAndSettle();

      final pick = tester.widget<ResultCard>(find.byType(ResultCard)).choice;
      // Two choices alternate down the strip; the pick's other rows must
      // not look picked too.
      expect(boldReelLabels(tester), [pick]);
    });
  });
}
