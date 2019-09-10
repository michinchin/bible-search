import 'package:bible_search/models/home_model.dart';
import 'package:bible_search/tec_settings.dart';
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
  bool isSelected;

  BibleTranslation({
    this.id,
    this.name,
    this.a,
    this.lang,
    this.isOnSale,
    this.isSelected,
  });

  factory BibleTranslation.fromJson(Map<String, dynamic> json) {
    final onSale = tec.as<bool>(json['onsale']);
    if (onSale) {
      return BibleTranslation(
        id: tec.as<int>(json['id']),
        name: tec.as<String>(json['name']),
        a: tec.as<String>(json['abbreviation']),
        lang: HomeModel()
            .languages
            .firstWhere((t) => t.a == (tec.as<String>(json['language']))),
        isOnSale: onSale,
        isSelected: true,
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
    for (final each in data) {
      if (each.isSelected && each.isOnSale) {
        formattedIds += '${each.id}|';
      }
    }
    if (formattedIds.isNotEmpty) {
      final idx = formattedIds.lastIndexOf('|');
      formattedIds = formattedIds.substring(0, idx);
    }
    return formattedIds;
  }

  void selectTranslations(String id) {
    if (id.isEmpty) {
      final tempData = data;
      for (final t in tempData) {
        t.isSelected = false;
      }
      data = tempData;
    } else {
      final arr = id.split('|').toList();
      final intArr = arr.map(int.parse).toList();
      final tempData = data;
      for (final t in tempData) {
        if (intArr.contains(t.id)) {
          t.isSelected = true;
        } else {
          t.isSelected = false;
        }
      }
      data = tempData;
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
    final json = await TecCache().jsonFromUrl(
        url: 'https://$hostAndPath/$fileName',
        bundlePath: 'assets/Translation.json');
    if (json != null) {
      return BibleTranslations.fromJson(json);
    } else {
      return BibleTranslations(data: []);
    }
  }
}
