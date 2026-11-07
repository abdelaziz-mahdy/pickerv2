import 'package:flutter_test/flutter_test.dart';
import 'package:pickerv2/models/choices_operation.dart';

void main() {
  test('deleting choices on the home screen leaves saved lists alone', () {
    // No database is opened here: if deleting a home-screen choice still
    // reached the saved lists table, this would fail with a
    // LateInitializationError on `database`.
    final operation = ChoicesOperation()
      ..addNewChoice('Coffee')
      ..addNewChoice('Tea');
    operation.selected(operation.getChoices, 0);

    operation.deleteSelectedChoices();

    expect(operation.getChoices.map((choice) => choice.description), ['Tea']);
  });
}
