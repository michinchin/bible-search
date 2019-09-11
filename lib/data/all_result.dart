import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';

import 'package:bible_search/labels.dart';
import 'package:bible_search/data/translation.dart';
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
    final json = await getAllResponse(
      auth: kTBApiServer,
      unencodedPath: '/allverses',
      queryParameters: {
        'key': kTBkey,
        'version': kTBApiVersion,
        'volumes': translations.formatIds(),
        'book': '$book',
        'chapter': '$chapter',
        'verse': '$verse',
      },
    );
    if (json != null) {
      return AllResults.fromJson(json);
    } else {
      return AllResults(data: []);
    }
  }

  static Future<List<dynamic>> getAllResponse(
      {String auth,
      String unencodedPath,
      Map<String, String> queryParameters}) async {
    final uri = Uri.https(auth, unencodedPath, queryParameters);
    final jsonResponse = await _getAllJson(uri);

    if (jsonResponse == null) {
      print('Error retrieving json. URL:${uri.toString()}');
      return null;
    }
    return jsonResponse;
  }

  static Future<List<dynamic>> _getAllJson(Uri uri) async {
    final _httpClient = HttpClient();
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.ok) {
        return null;
      }
      // The response is sent as a Stream of bytes that we need to convert to a
      // `String`.
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      // Finally, the string is parsed into a JSON object.
      final response = tec.as<List<dynamic>>(json.decode(responseBody));
      return response;
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}
