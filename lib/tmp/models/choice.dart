class Choice {
  String description;
  int Selected = 0;
  Choice(this.description);

  Map<String, dynamic> toMap() {
    return {
      'Description': description,
    };
  }

  // ignore: non_constant_identifier_names
  void Print() {
    print("description " + description);
  }

  void toggleSelected() {
    Selected++;
    Selected = Selected % 2;
    print(Selected);
  }
}
