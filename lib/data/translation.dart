import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bible_search/models/home_model.dart';
import 'package:bible_search/labels.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

class Language {
  final String a;
  final String name;
  final int id;
  bool isSelected;

  Language({this.a, this.name, this.id, this.isSelected});
}

class BibleTranslation {
  final int id;
  final String name;
  final String a;
  final Language lang;
  final bool isOnSale;
  bool isDefault;
  bool isSelected;

  BibleTranslation(
      {this.id,
      this.name,
      this.a,
      this.lang,
      this.isOnSale,
      this.isSelected,
      this.isDefault});

  factory BibleTranslation.fromJson(Map<String, dynamic> json) {
    final onSale = tec.as<bool>(json['onsale']);
    final id = tec.as<int>(json['id']);
    final lang = tec.as<String>(json['language']);
    if (onSale && (id < 300 || id >= 400) && id < 1000) {
      return BibleTranslation(
        id: id,
        name: tec.as<String>(json['name']),
        a: tec.as<String>(json['abbreviation']),
        lang: HomeModel().languages.firstWhere((t) => t.a == lang),
        isOnSale: onSale,
        isSelected: lang == 'en',
        isDefault: false,
      );
    }
    return null;
  }
}

class BibleTranslations {
  var data = <BibleTranslation>[];

  BibleTranslations({this.data});

  factory BibleTranslations.fromJson(Map<String, dynamic> json) {
    final d = <BibleTranslation>[];
    final a = tec.as<List<dynamic>>(json['categories']);
    for (final b in a) {
      if (b is Map<String, dynamic>) {
        if (b['name'] == 'Bible Translations' || b['name'] == 'Español') {
          for (final Map<String, dynamic> c in b['products']) {
            final res = BibleTranslation.fromJson(c);
            if (res != null) {
              d.add(res);
            }
          }
        }
      }
    }
    return BibleTranslations(data: d);
  }

  String formatIds() {
    var formattedIds = '';
    if (data != null) {
      final toSave = data.where((t) => t.isSelected && t.isOnSale).toList();
      final ids = toSave.map((t) => t.id).toList();
      formattedIds = ids.join('|');
    }

    return formattedIds;
  }

  String formatDefaultIds(String currentIds) {
    var formattedIds = '';
    final defaults = data.where((t) => t.isDefault)?.toList() ?? [];
    if (defaults.isNotEmpty) {
      final chosenDefaultIds = defaults.map((t) => t.id).toList();

      if (currentIds.isNotEmpty) {
        final defaultIds =
            currentIds.split('|').map(int.tryParse).toList().toSet().toList();
        final newDefaultIds = List<int>.from(defaultIds);

        // append any translations not currently saved in pref ids
        if (chosenDefaultIds.length > defaultIds.length) {
          newDefaultIds.add(chosenDefaultIds
              .where((id) => !defaultIds.contains(id))
              .toList()
              .first);
          // remove translations when deselected from defaults
        } else {
          newDefaultIds.removeWhere((id) => !chosenDefaultIds.contains(id));
        }
        formattedIds = newDefaultIds.join('|');
      } else {
        formattedIds = chosenDefaultIds.join('|');
      }
    }

    return formattedIds;
  }

  void selectTranslations(String id, {bool isDefault = false}) {
    if (data != null) {
      if (id.isEmpty) {
        final tempData = data;
        for (final t in tempData) {
          isDefault ? t.isDefault = false : t.isSelected = false;
        }
        data = tempData;
      } else {
        final arr = id.split('|').toList();
        final intArr = arr.map(int.parse).toList();
        final tempData = data;
        for (final t in tempData) {
          if (intArr.contains(t.id)) {
            isDefault ? t.isDefault = true : t.isSelected = true;
          } else {
            isDefault ? t.isDefault = false : t.isSelected = false;
          }
        }
        data = tempData;
      }
    }
  }

  String getFullName(int id) {
    final tempData = data;
    return tempData
        .where((bt) {
          return bt.id == id;
        })
        .toList()[0]
        .name;
  }

  static Future<BibleTranslations> fetch() async {
    const fileName = 'WebSite.json.gz';
    const hostAndPath = '$kTBStreamServer/$kTBApiVersion/products-list';
    final translations = await readTranslationsJson('Translation.txt');

    Map<String, dynamic> bibleJson;
    // if the current vs fetched don't match, update current
    bibleJson =
        await TecCache().jsonFromUrl(url: 'https://$hostAndPath/$fileName');

    var needsUpdate = false;

    if (bibleJson != null) {
      needsUpdate = (translations ?? '').compareTo(json.encode(bibleJson)) != 0;

      if (!needsUpdate) {
        debugPrint('Using translation json from file system');
        bibleJson = tec.as<Map<String, dynamic>>(json.decode(translations));
      } else {
        debugPrint('Updating translation json');
        unawaited(writeToTranslationJson(jsonEncode(bibleJson)));
      }
      return BibleTranslations.fromJson(bibleJson);
    } else {
      return BibleTranslations(data: []);
    }
  }

  static Future<String> readTranslationsJson(String path) async {
    String text;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$path');
      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

  static Future<void> writeToTranslationJson(String text) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    final file = File('$directory/Translation.txt');
    await file.writeAsString(text);
  }
}
