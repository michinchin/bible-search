class Book {
  final String name;
  final int id;
  bool isSelected = true;
  int numResults;

  Book({
    this.name,
    this.id,
    this.isSelected = true,
    this.numResults = 0,
  });

  bool isOT() {
    return id <= 46;
  }

  Book getById(int id) {
    return id == this.id ? this : null;
  }
}
