import 'dart:core';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';

import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../data/verse.dart';
import '../labels.dart';

class SearchResult {
  final String ref;
  final int bookId;
  final int chapterId;
  final int verseId;
  final List<Verse> verses;
  bool contextExpanded;
  bool compareExpanded;
  bool isExpanded;
  bool isSelected;
  int currentVerseIndex;
  String fullText;
  final GlobalKey key;

  SearchResult({
    this.ref,
    this.bookId,
    this.chapterId,
    this.verseId,
    this.verses,
    this.contextExpanded = false,
    this.compareExpanded = true,
    this.isExpanded = false,
    this.isSelected = false,
    this.currentVerseIndex = 0,
    this.fullText = '',
    this.key,
  });

  SearchResult copyWith({
    String ref,
    int bookId,
    int chapterId,
    int verseId,
    List<Verse> verses,
    bool contextExpanded,
    bool compareExpanded,
    bool isExpanded,
    bool isSelected,
    int currentVerseIndex,
    String fullText,
    GlobalKey key,
  }) =>
      SearchResult(
        ref: ref ?? this.ref,
        bookId: bookId ?? this.bookId,
        chapterId: chapterId ?? this.chapterId,
        verseId: verseId ?? this.verseId,
        verses: verses ?? this.verses,
        contextExpanded: contextExpanded ?? this.contextExpanded,
        compareExpanded: compareExpanded ?? this.compareExpanded,
        isExpanded: isExpanded ?? this.isExpanded,
        isSelected: isSelected ?? this.isSelected,
        currentVerseIndex: currentVerseIndex ?? this.currentVerseIndex,
        fullText: fullText ?? this.fullText,
        key: key ?? this.key,
      );

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final ref = tec.as<String>(json['reference']);
    final v = <Verse>[];
    final a = tec.as<List<dynamic>>(json['verses']);
    for (final b in a) {
      if (b is Map<String, dynamic>) {
        final verse = Verse.fromJson(b, ref);
        if (verse != null) {
          v.add(verse);
        }
      }
    }
    return SearchResult(
        ref: ref,
        bookId: tec.as<int>(json['bookId']),
        chapterId: tec.as<int>(json['chapterId']),
        verses: v,
        verseId: tec.as<int>(json['verseId']),
        key: GlobalKey());
  }
}

class SearchResults {
  var data = <SearchResult>[];
  SearchResults({this.data});

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    final d = <SearchResult>[];
    final a = tec.as<List<dynamic>>(json['searchResults']);
    for (final b in a) {
      if (b is Map<String, dynamic>) {
        final res = SearchResult.fromJson(b);
        if (res != null) {
          d.add(res);
        }
      }
    }
    return SearchResults(data: d);
  }

  static Future<List<SearchResult>> fetch(
      {String words, String translationIds}) async {
    if ((words?.trim() ?? '').isEmpty) {
      return [];
    }
    const hostAndPath = '$kTBApiServer/search';
    const cachePath = '$kTBStreamServer/cache';
    var phrase = 0, exact = 0;
    var cacheWords = words;
    var searchWords;

    urlEncodingExceptions
        .forEach((k, v) => cacheWords = cacheWords.replaceAll(RegExp(k), v));
    removeDiacritics(cacheWords)
        .replaceAll(RegExp('[^ a-zA-Z\'0-9:\-]'), ' ')
        .trim();

    // phrase or exact search ?
    if (cacheWords[0] == '"' || cacheWords[0] == '\'') {
      if (cacheWords.contains(' ')) {
        phrase = 1;
      } else {
        exact = 1;
      }

      // remove trailing quote
      if (cacheWords.endsWith(cacheWords[0])) {
        cacheWords = cacheWords.substring(1, cacheWords.length - 1);
      } else {
        cacheWords = cacheWords.substring(1);
      }

      searchWords = cacheWords = cacheWords.toLowerCase();
    }
    else {
      final currQuery = cacheWords.toLowerCase();
      final regex = RegExp(r' *[0-9]? *\w+ *[0-9]+');
      final matches = regex.allMatches(currQuery).toList();

      cacheWords = _formatWords(cacheWords);

      searchWords = (matches.isNotEmpty)
          ? _formatRefs(currQuery)
          : cacheWords;
    }

    final tecCache = TecCache();
    final fullCachedPath =
        'https://$cachePath/${_getCacheKey(cacheWords, translationIds, exact, phrase)}none.gz';
    final fullPath =
        'https://$hostAndPath?key=$kTBkey&version=$kTBApiVersion&words=$searchWords&book=0'
        '&bookset=0&exact=$exact&phrase=$phrase&searchVolumes=$translationIds';
    final cacheJson = await tecCache.jsonFromUrl(
      url: fullCachedPath,
      requestType: 'get',
      connectionTimeout: const Duration(seconds: 10),
    );

    if (cacheJson != null) {
      debugPrint('Getting cached results from: $fullCachedPath');
      return SearchResults.fromJson(cacheJson).data;
    } else {
      final json = await tecCache.jsonFromUrl(
        url: fullPath,
        requestType: 'post',
        connectionTimeout: const Duration(seconds: 10),
      );
      if (json != null) {
        debugPrint('Getting results from: ${Uri.encodeFull(fullPath)}');
        return SearchResults.fromJson(json).data;
      } else {
        return Future.error(
            'Error getting results from: ${Uri.encodeFull(fullPath)}');
      }
    }
  }
}

final urlEncodingExceptions = <String, String>{
  '’': '\'', // UTF-8: E2 80 99
  '‘': '\'', // UTF-8: E2 80 98
  '‚': '',
  ',': '', // get rid of commas
  '‛': '\'',
  '“': '"',
  '”': '"',
  '“': '"', // UTF-8: E2 80 9C
  '”': '"', // UTF-8: E2 80 9D
  '„': '"', // UTF-8: E2 80 9E
  '‟': '"',
  '′': '"',
  '″': '"',
  '‴': '"',
  '‵': '\'',
  '‶': '"',
  '‷': '"',
  '–': '-', // UTF-8: E2 80 93
  '‐': '-',
  '‒': '-',
  '—': '-', // UTF-8: E2 80 94
  '―': '-', // UTF-8: E2 80 95
  '\\.': '',
};

String _formatWords(String keywords) {
  final modifiedKeywords = keywords.toLowerCase();

  // sort by length descending then alpha ascending...
  final wordList = modifiedKeywords.split(' ')
    ..sort((a, b) {
      if (a.length == b.length) {
        return a.compareTo(b);
      } else {
        return b.length.compareTo(a.length);
      }
    });

  // return the top 5 results
  return wordList
      .sublist(0, wordList.length <= 5 ? wordList.length : 5)
      .join(' ');
}

String _formatRefs(String query) {
  final regex = RegExp(r' *[0-9]? *\w+');

  final arr = regex.allMatches(query).toList();
  if (arr.isNotEmpty) {
    final shortRef = arr[0].group(0);
    if (extraBookNames.containsKey(shortRef)) {
      final bookId = extraBookNames[shortRef];
      final fullBookName =
          bookNames.keys.firstWhere((k) => bookNames[k] == bookId);
      final fixedQuery = query.replaceAll(shortRef, fullBookName);

      return fixedQuery;
    }
  }
  return query;
}

String _getCacheKey(
    String keywords, String translationIds, int exact, int phrase) {
  String modKeywords;
  modKeywords = keywords.toLowerCase();
  urlEncodingExceptions
      .forEach((k, v) => modKeywords = modKeywords.replaceAll(RegExp(k), v));
  
  var words = keywords.replaceAll(' ', '_');

  words += '_';
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
  return '$words${encoded.toString()}_0_0_${phrase}_$exact';
}
