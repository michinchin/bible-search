
class Verse{
  final String title;
  final int id;
  final String a;
  final verseContent;
  String contextText;
  List<int> verseIdx; //for when context expanded (v3-5)

  Verse({
    this.title,
    this.id,
    this.a,
    this.verseContent,
    this.contextText = '',
    this.verseIdx,
  });

  factory Verse.fromJson(Map<String, dynamic> json, String ref){
    return Verse(
      title: ref,
      id: json['id'] as int,
      a: json['a'] as String,
      verseContent: json['text'] as String,
    );
  }
}