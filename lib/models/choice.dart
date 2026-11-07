class Choice {
  String description;
  int selected = 0;
  Choice(this.description);

  Map<String, dynamic> toMap() {
    return {
      'Description': description,
    };
  }

  void toggleSelected() {
    selected++;
    selected = selected % 2;
  }
}
