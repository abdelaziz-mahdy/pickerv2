import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:pickerv2/main.dart';
import 'package:pickerv2/models/choices_operation.dart';
import 'package:pickerv2/screens/app_shell.dart';
import 'package:pickerv2/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Runs the app's database on the host through sqflite's FFI backend,
/// starting each test with no saved lists.
Future<void> useTestDatabase() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await databaseFactory.deleteDatabase(
    join(await getDatabasesPath(), ChoicesOperation().databaseName),
  );
}

/// Pumps the app and lets its startup database work (both tabs read at
/// launch) finish, so it can't outlive the test and hit the next test's
/// fresh database.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pump();
  // Wait for the startup reads themselves, not a fixed time (a fixed wait
  // raced under load): queries run one at a time, so a query issued now
  // completes only after the ones the screens started.
  final operation = Provider.of<ChoicesOperation>(
      tester.element(find.byType(AppShell)),
      listen: false);
  await tester.runAsync(() async {
    final db = await operation.database;
    await db.rawQuery('SELECT 1');
  });
  await tester.pump();
}

Future<void> addChoice(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextFormField), text);
  await tester.tap(find.text('Add Choice'));
  await tester.pump();
}

void main() {
  setUp(useTestDatabase);

  testWidgets('a whitespace-only choice is not added', (tester) async {
    await pumpApp(tester);
    await addChoice(tester, '   ');

    expect(find.text('Type a choice first'), findsOneWidget);
  });

  testWidgets('Back clears the selection instead of leaving the app',
      (tester) async {
    await pumpApp(tester);
    await addChoice(tester, 'Pizza');
    await addChoice(tester, 'Sushi');

    await tester.longPress(find.text('Pizza'));
    await tester.pump();
    expect(find.text('1 selected'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pump();

    expect(handled, isTrue, reason: 'Back must not reach the system');
    expect(find.text('1 selected'), findsNothing);
    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('Sushi'), findsOneWidget);
  });

  testWidgets('the X button leaves selection mode; Select all still works',
      (tester) async {
    await pumpApp(tester);
    await addChoice(tester, 'Pizza');
    await addChoice(tester, 'Sushi');

    await tester.longPress(find.text('Pizza'));
    await tester.pump();
    await tester.tap(find.byTooltip('Select all'));
    await tester.pump();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear selection'));
    await tester.pump();
    expect(find.text('2 selected'), findsNothing);
    expect(find.text('Choice Picker'), findsOneWidget);
  });

  testWidgets('Save list keeps the list; the Saved tab shows it and loads it',
      (tester) async {
    await pumpApp(tester);
    await addChoice(tester, 'Pizza');
    await addChoice(tester, 'Sushi');

    await tester.tap(find.byTooltip('Save list'));
    await tester.pump();
    expect(find.textContaining('List saved'), findsOneWidget);

    await tester.tap(find.text('Saved'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    expect(find.text('Saved Lists'), findsOneWidget);
    expect(find.text('2 choices'), findsOneWidget);

    // Loading a saved list returns to the Choices tab.
    await tester.tap(find.text('2 choices'));
    await tester.pumpAndSettle();
    expect(find.text('Choice Picker'), findsOneWidget);
  });

  testWidgets('the blank-choice error clears when the user types',
      (tester) async {
    await pumpApp(tester);
    await addChoice(tester, '   ');
    expect(find.text('Type a choice first'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Pi');
    await tester.pump();
    expect(find.text('Type a choice first'), findsNothing);
  });

  testWidgets('empty Choices shows a hint; Roll needs 2 choices, Choices only',
      (tester) async {
    await pumpApp(tester);
    expect(
        find.text('Add two or more choices, then tap Roll.'), findsOneWidget);
    // Roll appears once there are two choices to pick from.
    expect(find.byType(RollButton), findsNothing);
    await addChoice(tester, 'Pizza');
    await tester.pumpAndSettle();
    expect(find.byType(RollButton), findsNothing);
    await addChoice(tester, 'Sushi');
    await tester.pumpAndSettle();
    expect(find.byType(RollButton), findsOneWidget);

    await tester.tap(find.text('Saved'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    expect(find.byType(RollButton), findsNothing);
  });

  testWidgets('the keyboard stays up between added choices', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    await addChoice(tester, 'Pizza');
    expect(tester.testTextInput.isVisible, isTrue);
    await addChoice(tester, '   ');
    expect(tester.testTextInput.isVisible, isTrue);
  });
}
