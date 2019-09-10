import 'package:tec_util/tec_util.dart' as tec;

class Verse {
  final String title;
  final int id;
  final String a;
  final String verseContent;
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

  factory Verse.fromJson(Map<String, dynamic> json, String ref) {
    return Verse(
      title: ref,
      id: tec.as<int>(json['id']),
      a: tec.as<String>(json['a']),
      verseContent: tec.as<String>(json['text']),
      verseIdx: [0, 0],
    );
  }
}
