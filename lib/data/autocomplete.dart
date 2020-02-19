import 'dart:async';

import 'package:bible_search/labels.dart';
import 'package:diacritic/diacritic.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

class AutoComplete {
  final String word;
  final List<String> possibles;

  AutoComplete({this.word, this.possibles});

  factory AutoComplete.fromJson(Map<String, dynamic> json) {
    final possibles = tec
        .as<List<dynamic>>(json['possibles'])
        .map((dynamic s) => tec.as<String>(s)) //ignore: unnecessary_lambdas
        .toList();
    return AutoComplete(
        word: tec.as<String>(json['partial']), possibles: possibles);
  }

  static Future<AutoComplete> fetch(
      {String phrase, String translationIds}) async {

    final cleanPhrase = optimizePhrase(phrase);
    final suggestions = getSuggestions(cleanPhrase);
    final cacheParam = '${_getCacheKey(cleanPhrase, translationIds)}';
    final tecCache = TecCache();

    if (cleanPhrase.trim().isEmpty) {
      return AutoComplete.fromJson(<String, dynamic>{
        'words': '',
        'parital': '',
        'possibles': <String>[]
      });
    }

    // check cloudfront cache
    var json = await tecCache.jsonFromUrl(
      url: '${tec.cacheUrl}/$cacheParam',
      connectionTimeout: const Duration(seconds: 10),
    );

    // check the server
    if (tec.isNullOrEmpty(json)) {
      json = await tec.apiRequest(
          endpoint: 'suggest',
          parameters: <String, dynamic>{
            'words': suggestions['words'],
            'partialWord': suggestions['partialWord'],
            'searchVolumes': translationIds,
          },
          completion: (status, json, dynamic error) async {
            if (status == 200) {
              // save to tecCache...
              await tecCache.saveJsonToCache(
                  json: json, cacheUrl: '${tec.cacheUrl}/$cacheParam');

              return json;
            } else {
              return null;
            }
          });
    }

    if (tec.isNullOrEmpty(json)) {
      return Future.error('Error getting results from server');
    } else {
      return AutoComplete.fromJson(json);
    }
  }
}

//  final cacheParam =
//         '-${phrase}_AIAJANAPAgAtAuAvAwAxAyAzBBBMBOBPBWBZDIDJDKDaDgDjDmDnD6EqE1Fd.gz';

String _getCacheKey(String phrase, String translationIds) {
  final words = getSuggestions(phrase);
  final fullWords = words['words'].split(' ').join('_');
  var partial = '';
  if (tec.isNotNullOrEmpty(words['partialWord'])) {
    partial += '-${words['partialWord']}';
  }

  final encoded = StringBuffer();
  const length = base64Map.length;
  final volumeIds =
      translationIds.split('|').toList().map(double.parse).toList()..sort();

  for (var i = 0; i < volumeIds.length; i++) {
    var volumeId = volumeIds[i];
    final digit = volumeId / length;
    encoded.write(base64Map[digit.toInt()]);
    volumeId -= digit.toInt() * length;
    encoded.write(base64Map[volumeId.toInt()]);
  }

  return '$fullWords${partial}_${encoded.toString()}.gz';
}

String optimizePhrase(String phrase) {
  //    if (normalize) {
  //      searchText = TecartaBible.normalize(searchText);
  //    }
  //
  //    if (latinBased) {
  //      // remove non alpha/number/space/quote and lowercase
  //      searchText = searchText.replaceAll("[^ a-zA-Z'0-9:\\\\-]", " ").toLowerCase(Locale.ENGLISH);
  //    } else {
  //      // remove punctuation from non latin languages
  //      searchText = searchText.replaceAll("\\P{L}", " ");
  //    }

  // normalize phrase
  var cleanPhrase = removeDiacritics(phrase.trimLeft());

  // remove punctuation
  cleanPhrase = cleanPhrase.replaceAll(RegExp('[^ a-zA-Z\'0-9:\-]'), ' ');

  // top 5 words...
  final words = cleanPhrase.split(' ');
  cleanPhrase = '';

  var partial = '';
  if (!phrase.endsWith(' ')) {
    partial = ' ${words.last}';
    words.removeLast();
  }

  for (final word in words) {
    if (word.trim().isNotEmpty) {
      cleanPhrase += ' ${word.trim()}';
    }
  }

  // sort by length descending then alpha ascending...
  final wordList = cleanPhrase.trim().split(' ')
    ..sort((a, b) {
      if (a.length == b.length) {
        return a.compareTo(b);
      } else {
        return b.length.compareTo(a.length);
      }
    });

  cleanPhrase = wordList
      .sublist(0, wordList.length <= 5 ? wordList.length : 5)
      .join(' ');

  // so we get full/partial word correct...
  if (partial.isNotEmpty) {
    cleanPhrase += ' $partial';
  }
  else {
    cleanPhrase += ' ';
  }

  return cleanPhrase;
}

Map<String, String> getSuggestions(String phrase) {
  String words, partialWord;
  final s = phrase..replaceAll('\'', '')..replaceAll('\"', '');

  final index = s.lastIndexOf(' ');

  if (index < 0) {
    words = '';
    partialWord = s;
  } else {
    words = s.substring(0, index).trim();
    partialWord = s.substring(index).trim();
  }

  if (words.isEmpty && partialWord.isEmpty) {
    return {'words': '', 'partialWord': ''};
  }

  return {'words': words, 'partialWord': partialWord};
}
