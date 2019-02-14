
class Book {
  final String name;
  final int id;
  bool isSelected = true;

  Book({
    this.name,
    this.id, 
    this.isSelected = true,
  });

  bool isOT(){
    return id > 46 ? false : true;
  }

  Book getById(int id){
    return id == this.id ? this : null;
  }
}
