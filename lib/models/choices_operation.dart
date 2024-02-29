import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pickerv2/models/choice.dart';
import 'package:sqflite/sqflite.dart';

class ChoicesOperation extends ChangeNotifier{
  List<Choice> _choices = [];
  List<Choice> _DBchoices = [];
  int select_all_state=1;
  List<Choice> get getChoices{
    return _choices;
  }

  List<Choice> get getDBChoices{
    return _DBchoices;
  }

  void addNewChoice(String description){
    Choice note=Choice(description);
    _choices.add(note);
    notifyListeners();
  }
  void Selected(var Choices_List,int index){
    Choices_List[index].toggleSelected();
    notifyListeners();
  }
  bool SelectedExist(var Choices_List){
    for(int i=0;i<Choices_List.length;i++){
      if(Choices_List[i].Selected==1){
        print(true);
      return true;
    }}
    print(false);
    return false;
  }
  int  NumSelected(var Choices_List){
    int selected=0;
    for(int i=0;i<Choices_List.length;i++){
      if(Choices_List[i].Selected==1){
        selected++;
      }}

    return selected;
  }
  void SetNewChoices(String Choices_List){
    _choices=DBChoicesToList(Choices_List);
    notifyListeners();
  }
  void DeleteSelected(var Choices_List){
    var toRemove = [];
    Choices_List.forEach((element) {if(element.Selected==1){
      toRemove.add(element);
    }});
    Choices_List.removeWhere((item) => toRemove.contains(item));
    //deleteDBChoices
    toRemove.forEach((element) {
      deleteDBChoices(element.description);
    });
    select_all_state=1;
    ReadDB();
    //UpdateDB(); need to update the database
    notifyListeners();
  }
  void Select_All(var Choices_List){
    if(NumSelected(Choices_List)==Choices_List.length){
      for(int i=0;i<Choices_List.length;i++){
        Choices_List[i].Selected=0;
      }
    }else{
      for(int i=0;i<Choices_List.length;i++){
        Choices_List[i].Selected=1;
      }
    }
      notifyListeners();
    }

  void EditChoice(String description,int index){
    Choice choice=Choice(description);
    _choices[index]=choice;
    notifyListeners();
  }
  void deleteChoice(String description) {
    Choice tmp=Choice(description);
    _choices.removeWhere((item) => item.description == tmp.description);
    notifyListeners();
  }
  // ignore: non_constant_identifier_names
  Map<int,String> ToLabels() {
    Map<int,String> tmp={};
    for(int i=0;i<_choices.length;i++){
      tmp[i+1]=_choices[i].description;
  }
    return tmp;
  }
  void Save_Choices() {
    if(_choices.length>=1) {
      _DBchoices.add(Choice(ListToDBChoices(_choices)));
      _DBchoices.forEach((element) {
        print(element.description);
      });
      UpdateDB();
    notifyListeners();
    }
  }

  //database values
  String DatabaseName="Choices_database.db";
  String TableName="Choices";
  late Future<Database> database;
  //create the DB+Get refrence for it

  Future<void> CreateDB() async {
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), DatabaseName),
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
    List<String> values=[];
    values.add(choice);
    await db.delete(
        TableName,
        // Use a `where` clause to delete a specific dog.
        where: "Description = ?",
        // Pass the Dog's id as a whereArg to prevent SQL injection.
        whereArgs:values
    );

    notifyListeners();
  }


  Future<void> UpdateDB() async {

    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    _DBchoices.forEach((element) async {
      await db.insert(
        TableName,
        element.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );});
  }
  Future<void> ReadDB() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Notes.
    final List<Map<String, dynamic>> maps = await db.query(TableName);

    // Convert the List<Map<String, dynamic> into a List<Note>.
    _DBchoices.clear();
    _DBchoices = List.generate(maps.length, (i) {
      return Choice(
        maps[i]['Description'],
      );
    });
    notifyListeners();
  }
  List<Choice> DBChoicesToList(String DBChoices){
    List<String> choices=DBChoices.split(',');
    List<Choice> choices_return=[];
    choices_return.clear();
    for(int i=0;i<choices.length;i++){
      choices_return.add(Choice(choices[i]));
    }
    return choices_return;
  }
  String ListToDBChoices(List<Choice> ListOfChoices){
    List<String>ListOfDescription=[];
    for(int i=0;i<ListOfChoices.length;i++){
      ListOfDescription.add(ListOfChoices[i].description);
    }
    return ListOfDescription.join(',');
  }
}


