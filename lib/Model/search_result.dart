import '../tecarta.dart';
import '../Model/verse.dart';
import '../Services/api.dart';
import '../Model/singleton.dart';

class SearchResult {

  final String ref;
  final int bookId;
  final int chapterId;
  final int verseId;
  final List<Verse> verses;
  bool contextExpanded;
  bool compareExpanded;
  bool isSelected;
  int currentVerseIndex;
  String fullText;

  SearchResult({
    this.ref,
    this.bookId,
    this.chapterId,
    this.verseId,
    this.verses,
    this.contextExpanded = false,
    this.compareExpanded = false,
    this.isSelected = false,
    this.currentVerseIndex = 0,
    this.fullText = '',
  });

  factory SearchResult.fromJson(Map<String,dynamic> json) {
    final String ref = json['reference'];
    final v = <Verse>[];
    final a = json['verses'] as List<dynamic>;
    for (final b in a) {
      if (b is Map<String,dynamic>) {
        final verse = Verse.fromJson(b,ref);
        if(verse != null) {
          v.add(verse);
        }
      }
    }
    return SearchResult(
      ref: ref,
      bookId: json['bookId'] as int,
      chapterId: json['chapterId'] as int,
      verseId: json['verseId'] as int,
      verses: v,
    );
  }

}

class SearchResults {
  var data = <SearchResult>[];
  SearchResults({this.data});

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    var d = <SearchResult>[];
    final a = json['searchResults'] as List<dynamic>;
    for (final b in a) {
      if (b is Map<String,dynamic>) {
        final res = SearchResult.fromJson(b);
        if (res != null) {
          d.add(res);
        }
      }
    }
    return SearchResults(data: d);
  }

  static Future<SearchResults> fetch(String words) async {
    final api = API();
    final json = await api.getResponse(
      auth: kTBApiServer,
      unencodedPath: '/search',
      queryParameters: {
        'key' : kTBkey,
        'version' : kTBApiVersion,
        'words' : formatWords(words), 
        'book' : '0',
        'bookset' : '0',
        'exact' : '0',
        'phrase' : '0',
        'searchVolumes' : translationIds,
      },
      isGet: true,
    );
    if (json != null) {
      return SearchResults.fromJson(json);
    } else {
      return SearchResults(data: []);
    }
  }
}

Map<String,String> urlEncodingExceptions = {
  "’": "'", // UTF-8: E2 80 99
  "‘": "'", // UTF-8: E2 80 98
  "‚": "", // get rid of commas
  "‛": "'",
  "“": "\"", // UTF-8: E2 80 9C
  "”": "\"", // UTF-8: E2 80 9D
  "„": "\"", // UTF-8: E2 80 9E
  "‟": "\"",
  "′": "'",
  "″": "\"",
  "‴": "\"",
  "‵": "'",
  "‶": "\"",
  "‷": "\"",
  "–": "-",   // UTF-8: E2 80 93
  "‐": "-",
  "‒": "-",
  "—": "-", // UTF-8: E2 80 94
  "―": "-" // UTF-8: E2 80 95
};

String formatWords(String keywords) {
  urlEncodingExceptions.forEach(
    (k,v) => keywords = keywords.replaceAll(RegExp(k), v)
  );
  List<String> wordList = keywords.split(" ");
  wordList.sort((a,b) => b.length.compareTo(a.length));
  return wordList.length < 5 ? keywords : wordList.sublist(0,4).join(" ");
}