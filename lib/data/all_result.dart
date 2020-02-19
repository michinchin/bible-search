import 'dart:async';

import 'package:bible_search/data/translation.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

class AllResult {
  final int id;
  final String a;
  final String text;

  const AllResult({this.id, this.a, this.text});

  factory AllResult.fromJson(Map<String, dynamic> json) {
    final id = tec.as<int>(json['id']);
    final abbreviation = tec.as<String>(json['a']);
    final text = tec.as<String>(json['text']);

    return AllResult(
      id: id,
      a: abbreviation,
      text: text,
    );
  }
}

class AllResults {
  var data = <AllResult>[];

  AllResults({this.data});

  factory AllResults.fromJson(List<dynamic> json) {
    final d = <AllResult>[];
    for (final b in json) {
      if (b is Map<String, dynamic>) {
        final res = AllResult.fromJson(b);
        if (res != null) {
          d.add(res);
        }
      }
    }
    return AllResults(data: d);
  }

  static Future<AllResults> fetch(
      {int book,
      int chapter,
      int verse,
      BibleTranslations translations}) async {
    final _cachedPath = '${book}_${chapter}_${verse}_${translations.formatIds()}';

    final tecCache = TecCache();

    final json = await tecCache.jsonFromFile(cachedPath: _cachedPath);

    if (tec.isNotNullOrEmpty(json)) {
      return AllResults.fromJson(tec.as<List<dynamic>>(json['list']));
    }

    return tec.apiRequest(
        endpoint: 'allverses',
        parameters: <String, dynamic>{
          'volumes': translations.formatIds(),
          'book': book,
          'chapter': chapter,
          'verse': verse,
        },
        completion: (status, json, dynamic error) async {
          if (status == 200) {
            await tecCache.saveJsonToCache(json: json, cacheUrl: _cachedPath);
            return AllResults.fromJson(tec.as<List<dynamic>>(json['list']));
          } else {
            return AllResults(data: []);
          }
        });
  }
}
