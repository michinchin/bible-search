import '../tecarta.dart';
import '../Model/verse.dart';
import '../Model/singleton.dart';
import 'package:tec_cache/tec_cache.dart';

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
    final hostAndPath = '$kTBApiServer/search';
    final json = await TecCache().jsonFromUrl(
        url: 'https://$hostAndPath?key=$kTBkey&version=$kTBApiVersion&words=${formatWords(words)}&book=0'+
              '&bookset=0&exact=0&phrase=0&searchVolumes=$translationIds',
        cachedPath: 'cache/${getCacheKey(words)}.json',
        requestType: 'post',
    );
    if (json != null) {
      return SearchResults.fromJson(json);
    } else {
      return SearchResults(data: []);
    }
  }

  // static Future<SearchResults> fetch(String words) async {
  //   final api = API();
  //   final json = await api.getResponse(
  //     auth: kTBApiServer,
  //     unencodedPath: '/search',
  //     queryParameters: {
  //       'key' : kTBkey,
  //       'version' : kTBApiVersion,
  //       'words' : formatWords(words), 
  //       'book' : '0',
  //       'bookset' : '0',
  //       'exact' : '0',
  //       'phrase' : '0',
  //       'searchVolumes' : translationIds,
  //     },
  //     isGet: true,
  //   );
  //   if (json != null) {
  //     return SearchResults.fromJson(json);
  //   } else {
  //     return SearchResults(data: []);
  //   }
  // }
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
final String base64Map = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

String formatWords(String keywords) {
  urlEncodingExceptions.forEach(
    (k,v) => keywords = keywords.replaceAll(RegExp(k), v)
  );
  List<String> wordList = keywords.split(" ");
  wordList.sort((a,b) => b.length.compareTo(a.length));
  return wordList.length < 5 ? keywords : wordList.sublist(0,4).join(" ");
}

String getCacheKey(String keywords) {
  var encoded = '';
  final length = base64Map.length;
  final volumeIds = translationIds
    .split('|')
    .toList()
    .map((id)=>double.parse(id))
    .toList();

  volumeIds.sort();
  for (var i = 0; i < volumeIds.length; i++) {
    var volumeId = volumeIds[i];
    final digit = volumeId / length;
    encoded += base64Map[base64Map.indexOf('${digit.toInt()}')];
    volumeId -= digit * length;
    encoded += base64Map[base64Map.indexOf('${volumeId.toInt()}')];
  }
  return encoded;
}