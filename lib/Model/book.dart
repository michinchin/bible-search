
class Book {
  final String name;
  final int id;
  bool isSelected = true;

  Book({
    this.name,
    this.id, 
    this.isSelected = true,
  });

  int getotnt(){
    return id > 46 ? 0 : -1;
  }

  String getBookById(int id){
    if (id == this.id){
      return this.name;
    }
  }
}
