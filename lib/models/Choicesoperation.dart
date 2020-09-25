import 'package:flutter/material.dart';
import 'package:pickerv2/models/Choice.dart';

class ChoicesOperation extends ChangeNotifier{
  List<Choice> _choices = new List<Choice>();

  List<Choice> get getChoices{
    return _choices;
  }


  void addNewChoice(String description){
    Choice note=Choice(description);
    _choices.add(note);
    notifyListeners();
  }
  void Selected(int index){
    _choices[index].toggleSelected();
    notifyListeners();
  }
  bool SelectedExist(){
    for(int i=0;i<_choices.length;i++){
      if(_choices[i].Selected==1){
        print(true);
      return true;
    }}
    print(false);
    return false;
  }
  int  NumSelected(){
    int selected=0;
    for(int i=0;i<_choices.length;i++){
      if(_choices[i].Selected==1){
        selected++;
      }}

    return selected;
  }

  void DeleteSelected(){
    var toRemove = [];
    _choices.forEach((element) {if(element.Selected==1){
      toRemove.add(element);
    }});
    _choices.removeWhere((item) => toRemove.contains(item));
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
  }


