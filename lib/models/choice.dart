class Choice {
  String description;
  int selected = 0;
  Choice(this.description);

  Map<String, dynamic> toMap() {
    return {
      'Description': description,
    };
  }

  // ignore: non_constant_identifier_names
  void Print() {
    print("description $description");
  }

  void toggleSelected() {
    selected++;
    selected = selected % 2;
    print(selected);
  }
}
