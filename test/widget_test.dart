import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:pickerv2/main.dart';
import 'package:pickerv2/models/choices_operation.dart';
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

Future<void> addChoice(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextFormField), text);
  await tester.tap(find.text('Add Choice'));
  await tester.pump();
}

void main() {
  setUp(useTestDatabase);

  testWidgets('a whitespace-only choice is not added', (tester) async {
    await tester.pumpWidget(const MyApp());
    await addChoice(tester, '   ');

    expect(find.text('Type a choice first'), findsOneWidget);
  });

  testWidgets('Back clears the selection instead of leaving the app',
      (tester) async {
    await tester.pumpWidget(const MyApp());
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
    await tester.pumpWidget(const MyApp());
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
}
