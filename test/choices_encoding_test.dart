import 'package:flutter_test/flutter_test.dart';
import 'package:pickerv2/models/choices_operation.dart';

void main() {
  group('saved list encoding', () {
    test('a choice containing a comma survives a save and load', () {
      final choices = ['Pizza', 'Tacos, burritos', 'Sushi'];
      final stored = ChoicesOperation.encodeChoices(choices);
      expect(ChoicesOperation.decodeChoices(stored), choices);
    });

    test('lists without commas keep the legacy comma-joined format', () {
      expect(ChoicesOperation.encodeChoices(['Pizza', 'Sushi']), 'Pizza,Sushi');
    });

    test('legacy rows already on the phone still load', () {
      expect(
        ChoicesOperation.decodeChoices('Pizza,Sushi,Tacos'),
        ['Pizza', 'Sushi', 'Tacos'],
      );
    });

    test('a legacy list whose first choice starts with [ still loads', () {
      expect(ChoicesOperation.decodeChoices('[draft],Sushi'),
          ['[draft]', 'Sushi']);
      final stored = ChoicesOperation.encodeChoices(['[draft]', 'Sushi']);
      expect(ChoicesOperation.decodeChoices(stored), ['[draft]', 'Sushi']);
    });

    test('loading a saved list restores every choice', () {
      final operation = ChoicesOperation();
      operation.setNewChoices(
        ChoicesOperation.encodeChoices(['Pizza', 'Tacos, burritos']),
      );
      expect(
        operation.getChoices.map((choice) => choice.description),
        ['Pizza', 'Tacos, burritos'],
      );
    });
  });
}
