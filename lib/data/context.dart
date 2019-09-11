import 'package:bible_search/labels.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

class Context {
  Map<int, String> verses;
  int initialVerse = 0;
  int finalVerse = 0;
  String text = '';

  Context({this.verses, this.initialVerse, this.finalVerse});

  factory Context.fromJson(Map<String, dynamic> json) {
    final verses = <int, String>{};
    tec.as<Map<String, dynamic>>(json['verses']).forEach((k, dynamic v) {
      final t = int.parse(k);
      verses[t] = tec.as<String>(v);
    });

    return Context(verses: verses);
  }

  static Future<Context> fetch(
      {int translation, int book, int chapter, int verse}) async {
    final json = await TecCache().jsonFromUrl(
      url:
          'https://$kTBStreamServer/$kTBApiVersion/$translation/chapters/${book}_$chapter.json.gz',
    );
    Context context;
    if (json != null) {
      context = Context.fromJson(json);
    } else {
      context = Context(verses: <int, String>{});
    }
    context.text = getString(context, verse);
    return context;
  }
}

String getString(Context context, int verseId) {
  var vId = verseId;
  var v = verseId - 1;
  var before = '';
  var after = '';
  const charsToShow = 200;
  final wholeChapter = context.verses;

  while (v >= 1 && before.length < charsToShow) {
    final verse = wholeChapter[v];
    if (verse != null) {
      if (before.isNotEmpty) {
        before = ' $before';
      }
      before = verse + before;
      before = '[$v] $before';
    }
    v--;
  }
  context.initialVerse = ++v;

  final verse = wholeChapter[v];
  if (verse != null && verse.isNotEmpty) {
    before += '[$verseId] ${wholeChapter[verseId]}';
  }

  if (verseId <= wholeChapter.length) {
    v = ++vId;
    while (v <= verseId + 10 && after.length < charsToShow) {
      final verse = wholeChapter[v];
      if (verse != null) {
        if (after.isNotEmpty) {
          after += ' ';
        }
        after += '[$v] ';
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
