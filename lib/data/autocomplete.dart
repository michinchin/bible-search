import 'dart:async';

import 'package:bible_search/labels.dart';
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
    final suggestions = getSuggestions(phrase);
    const path = 'https://$kTBApiServer/';
    final parameters =
        'suggest?key=$kTBkey&version=$kTBApiVersion&words=${suggestions['words']}&partialWord=${suggestions['partialWord']}&searchVolumes=$translationIds';
    const cachePath = 'https://$kTBStreamServer/cache/';
    final cacheParam = '${_getCacheKey(phrase, translationIds)}';

    Map<String, dynamic> json;

    if (phrase
        .trim()
        .isEmpty) {
      json =
      <String, dynamic>{ 'words': '', 'parital': '', 'possibles': <String>[]};
      print('Getting empty results');
    }

    final tecCache = TecCache();

    if (tec.isNullOrEmpty(json)) {
      print('Getting cached results from $cachePath$cacheParam');

      json = await tecCache.jsonFromUrl(
        url: '$cachePath$cacheParam',
      );
    }

    if (tec.isNullOrEmpty(json)) {
      print('Getting results from ${Uri.encodeFull('$path$parameters')}');

      json = await tecCache.jsonFromUrl(
        requestType: 'post',
        url: '$path$parameters',
      );
    }

    if (json != null) {
      return AutoComplete.fromJson(json);
    } else {
      return null;
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
