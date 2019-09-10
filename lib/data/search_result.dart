import 'dart:core';

import 'package:flutter/material.dart';

import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../data/verse.dart';
import '../tec_settings.dart';

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
      return SearchResults(data: []).data;
    }
    final hostAndPath = '$kTBApiServer/search';
    final cachePath = '$kTBStreamServer/cache';
    final tecCache = TecCache();
    final fullCachedPath =
        'https://$cachePath/${getCacheKey(words, translationIds)}.gz';
    final fullPath =
        'https://$hostAndPath?key=$kTBkey&version=$kTBApiVersion&words=${formatWords(words)}&book=0'
        '&bookset=0&exact=0&phrase=0&searchVolumes=$translationIds';
    final cacheJson = await tecCache.jsonFromUrl(
      url: fullCachedPath,
      requestType: 'get',
    );

    if (cacheJson != null) {
      debugPrint('Getting cached results from: $fullCachedPath');
      return SearchResults.fromJson(cacheJson).data;
    } else {
      final json = await tecCache.jsonFromUrl(
        url: fullPath,
        requestType: 'post',
      );
      if (json != null) {
        debugPrint('Getting results from: ${Uri.encodeFull(fullPath)}');
        return SearchResults.fromJson(json).data;
      } else {
        return SearchResults(data: []).data;
      }
    }
  }
}

Map<String, String> urlEncodingExceptions = {
  '’': ''', // UTF-8: E2 80 99
  '‘': ''', // UTF-8: E2 80 98
  '‚': '',
  ',': '', // get rid of commas
  '‛': ''',
  '“': '\"', // UTF-8: E2 80 9C
  '”': '\"', // UTF-8: E2 80 9D
  '„': '\"', // UTF-8: E2 80 9E
  '‟': '\"',
  '′': '\"',
  '″': '\"',
  '‴': '\"',
  '‵': ''',
  '‶': '\"',
  '‷': '\"',
  '–': '-', // UTF-8: E2 80 93
  '‐': '-',
  '‒': '-',
  '—': '-', // UTF-8: E2 80 94
  '―': '-' // UTF-8: E2 80 95
};
const base64Map =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

String formatWords(String keywords) {
  String modifiedKeywords;
  urlEncodingExceptions
      .forEach((k, v) => modifiedKeywords = keywords.replaceAll(RegExp(k), v));
  final wordList = modifiedKeywords.split(' ')
    ..sort((a, b) => b.length.compareTo(a.length));
  return wordList
      .sublist(0, wordList.length < 5 ? wordList.length : 4)
      .join(' ');
}

String getCacheKey(String keywords, String translationIds) {
  String modKeywords;
  modKeywords = keywords.toLowerCase();
  modKeywords = formatWords(modKeywords);
  // var klist = keywords.split(' ');
  // klist.sort((f,l)=> f.length.compareTo(l.length));
  // keywords = klist.join(' ');
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
  return '$words${encoded.toString()}0_0_0_0';
}
