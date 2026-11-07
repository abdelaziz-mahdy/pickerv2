import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:pickerv2/models/choice.dart';
import 'package:sqflite/sqflite.dart';

class ChoicesOperation extends ChangeNotifier {
  List<Choice> _choices = [];
  List<Choice> dBChoices = [];
  int selectAllState = 1;
  List<Choice> get getChoices {
    return _choices;
  }

  List<Choice> get getDBChoices {
    return dBChoices;
  }

  /// Form validator for a new choice: blank or whitespace-only text is not
  /// a choice (it showed up as an empty card and an empty wheel slice).
  static String? validateChoice(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Type a choice first';
    if (text.length > maxChoiceLength) {
      return 'Keep it under $maxChoiceLength characters';
    }
    return null;
  }

  static const int maxChoiceLength = 1500;

  void addNewChoice(String description) {
    Choice note = Choice(description);
    _choices.add(note);
    notifyListeners();
  }

  void selected(List<Choice> choicesList, int index) {
    choicesList[index].toggleSelected();
    notifyListeners();
  }

  bool selectedExist(List<Choice> choicesList) {
    for (int i = 0; i < choicesList.length; i++) {
      if (choicesList[i].selected == 1) {
        return true;
      }
    }
    return false;
  }

  int numSelected(List<Choice> choicesList) {
    int selected = 0;
    for (int i = 0; i < choicesList.length; i++) {
      if (choicesList[i].selected == 1) {
        selected++;
      }
    }

    return selected;
  }

  void setNewChoices(String choicesList) {
    _choices = dBChoicesToList(choicesList);
    notifyListeners();
  }

  /// Removes the selected choices from the list being built on the home
  /// screen. Saved lists are not touched.
  void deleteSelectedChoices() {
    _choices.removeWhere((choice) => choice.selected == 1);
    selectAllState = 1;
    notifyListeners();
  }

  /// Deletes the selected saved lists from the database, then reloads them.
  Future<void> deleteSelectedSaved() async {
    final toRemove = [
      for (final choice in dBChoices)
        if (choice.selected == 1) choice.description,
    ];
    dBChoices.removeWhere((choice) => choice.selected == 1);
    selectAllState = 1;
    notifyListeners();
    for (final description in toRemove) {
      await deleteDBChoices(description);
    }
    await readDB();
  }

  void clearSelection(List<Choice> choicesList) {
    for (final choice in choicesList) {
      choice.selected = 0;
    }
    notifyListeners();
  }

  void selectAll(List<Choice> choicesList) {
    if (numSelected(choicesList) == choicesList.length) {
      for (int i = 0; i < choicesList.length; i++) {
        choicesList[i].selected = 0;
      }
    } else {
      for (int i = 0; i < choicesList.length; i++) {
        choicesList[i].selected = 1;
      }
    }
    notifyListeners();
  }

  void editChoice(String description, int index) {
    Choice choice = Choice(description);
    _choices[index] = choice;
    notifyListeners();
  }

  void deleteChoice(String description) {
    Choice tmp = Choice(description);
    _choices.removeWhere((item) => item.description == tmp.description);
    notifyListeners();
  }

  // ignore: non_constant_identifier_names
  Map<int, String> ToLabels() {
    Map<int, String> tmp = {};
    for (int i = 0; i < _choices.length; i++) {
      tmp[i + 1] = _choices[i].description;
    }
    return tmp;
  }

  void saveChoices() {
    if (_choices.isNotEmpty) {
      dBChoices.add(Choice(listToDBChoices(_choices)));
      updateDB();
      notifyListeners();
    }
  }

  //database values
  String databaseName = "Choices_database.db";
  String tableName = "Choices";

  /// Opened once, on first use. Both tabs touch the database at startup (the
  /// Saved tab reads it while Choices is still opening it), so every caller
  /// awaits the same open instead of racing a late field.
  Future<Database>? _database;
  Future<Database> get database => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), databaseName),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE Choices(Description TEXT,PRIMARY KEY (Description))",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> createDB() async {
    await database;
  }

  Future<void> deleteDBChoices(String choice) async {
    final db = await database;
    List<String> values = [];
    values.add(choice);
    await db.delete(tableName,
        // Use a `where` clause to delete a specific dog.
        where: "Description = ?",
        // Pass the Dog's id as a whereArg to prevent SQL injection.
        whereArgs: values);

    notifyListeners();
  }

  Future<void> updateDB() async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    dBChoices.forEach((element) async {
      await db.insert(
        tableName,
        element.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> readDB() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Notes.
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    // Convert the List<Map<String, dynamic> into a List<Note>.
    dBChoices.clear();
    dBChoices = List.generate(maps.length, (i) {
      return Choice(
        maps[i]['Description'],
      );
    });
    notifyListeners();
  }

  List<Choice> dBChoicesToList(String dBChoices) {
    return [for (final choice in decodeChoices(dBChoices)) Choice(choice)];
  }

  String listToDBChoices(List<Choice> listOfChoices) {
    return encodeChoices(
        [for (final choice in listOfChoices) choice.description]);
  }

  /// Turns a list of choices into the single string kept in the database.
  ///
  /// Lists have always been stored comma-joined, which split a choice such
  /// as "Tacos, burritos" in two when the list was loaded again. Lists whose
  /// choices hold no comma keep that format, so rows already on the phone
  /// still match (no duplicate saved lists) and older app versions can read
  /// them. Only a list that cannot be comma-joined safely is stored as JSON.
  static String encodeChoices(List<String> choices) {
    final joined = choices.join(',');
    final needsJson =
        choices.any((choice) => choice.contains(',')) || joined.startsWith('[');
    return needsJson ? jsonEncode(choices) : joined;
  }

  /// Reads a list written by [encodeChoices] (JSON or the legacy
  /// comma-joined format).
  static List<String> decodeChoices(String stored) {
    if (stored.startsWith('[')) {
      try {
        final decoded = jsonDecode(stored);
        if (decoded is List && decoded.every((item) => item is String)) {
          return decoded.cast<String>();
        }
      } on FormatException {
        // Not JSON: a legacy list whose first choice starts with '['.
      }
    }
    return stored.split(',');
  }
}
