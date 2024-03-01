import 'package:flutter/material.dart';
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
        print(true);
        return true;
      }
    }
    print(false);
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

  void deleteSelected(List<Choice> choicesList) {
    var toRemove = [];
    for (var element in choicesList) {
      if (element.selected == 1) {
        toRemove.add(element);
      }
    }
    choicesList.removeWhere((item) => toRemove.contains(item));
    //deleteDBChoices
    for (var element in toRemove) {
      deleteDBChoices(element.description);
    }
    selectAllState = 1;
    readDB();
    //UpdateDB(); need to update the database
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
      for (var element in dBChoices) {
        print(element.description);
      }
      updateDB();
      notifyListeners();
    }
  }

  //database values
  String databaseName = "Choices_database.db";
  String tableName = "Choices";
  late Future<Database> database;
  //create the DB+Get refrence for it

  Future<void> createDB() async {
    database = openDatabase(
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
    List<String> choices = dBChoices.split(',');
    List<Choice> choicesReturn = [];
    choicesReturn.clear();
    for (int i = 0; i < choices.length; i++) {
      choicesReturn.add(Choice(choices[i]));
    }
    return choicesReturn;
  }

  String listToDBChoices(List<Choice> listOfChoices) {
    List<String> listOfDescription = [];
    for (int i = 0; i < listOfChoices.length; i++) {
      listOfDescription.add(listOfChoices[i].description);
    }
    return listOfDescription.join(',');
  }
}
