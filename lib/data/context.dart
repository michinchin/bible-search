import 'package:bible_search/tecarta.dart';
import 'package:tec_cache/tec_cache.dart';

class Context {
  Map<int,String> verses;
  int initialVerse = 0;
  int finalVerse = 0;
  String text = '';
 
  Context({this.verses, this.initialVerse, this.finalVerse});

  factory Context.fromJson(Map<String,dynamic> json) {
    var verses = Map<int,String>();
    json['verses'].forEach((k,v){
      int t = int.parse(k);
      verses[t] = v;
    });

    return Context(
      verses: verses
    );
  }

  static Future<Context> fetch({int translation, int book, int chapter, int verse}) async {

      final json = await TecCache().jsonFromUrl(
        url: 'https://$kTBStreamServer/$kTBApiVersion/$translation/chapters/${book}_$chapter.json.gz',
      );
      Context context;
      if (json != null) {
        context = Context.fromJson(json);
      } else {
        context = Context(verses: Map<int,String>());
      }
      context.text = getString(context, verse);
      return context;
    } 
}


  String getString(Context context, int verseId){

    int v = verseId - 1;
    String before = '';
    String after = '';
    int charsToShow = 200;
    Map<int, String> wholeChapter = context.verses;

    while (v >= 1 && before.length < charsToShow) {
      final String verse = wholeChapter[v];
      if (verse != null) {
        if (before.length > 0) {
          before = ' $before';
        }
        before = verse + before;
        before = '[$v] ' + before;
      }
      v--;
    }
    context.initialVerse = ++v;

    final String verse = wholeChapter[v];
    if (verse != null && verse.length > 0) {
      before += "[$verseId] ${wholeChapter[verseId]}";
    }

    if (verseId <= wholeChapter.length) {
      v = ++verseId;
      while (v <= verseId+10 && after.length < charsToShow) {
        final String verse = wholeChapter[v];
        if (verse != null) {
          if (after.length > 0) {
            after += ' ';
          }
          after +=  '[$v] ';
          after += verse;
        }
        v++;
      }
      context.finalVerse = --v;
    } else {
      context.finalVerse = ++v;
    }

    return before + after;
  }