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
}
