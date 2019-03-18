import 'package:bible_search/models/home_model.dart';
import 'package:bible_search/tecarta.dart';
import 'package:tec_cache/tec_cache.dart';

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

  // operator <(BibleTranslation bt) => lang != bt.lang;

  factory BibleTranslation.fromJson(Map<String, dynamic> json) {
    final onSale = json['onsale'] as bool;
    if (onSale) {
      return BibleTranslation(
        id: json['id'] as int,
        name: json['name'] as String,
        a: json['abbreviation'] as String,
        lang: HomeModel().languages.firstWhere((t) => t.a == (json['language'] as String)),
        isOnSale: onSale,
        isSelected: true,
      );
    }
  }
}

class BibleTranslations {
  var data = <BibleTranslation>[];

  BibleTranslations({this.data});

  factory BibleTranslations.fromJson(Map<String, dynamic> json) {
    var d = <BibleTranslation>[];
    final a = json['categories'] as List<dynamic>;
    for (final b in a) {
      if (b is Map<String, dynamic>) {
        if (b['name'] == 'Bible Translations' || b['name'] == 'Español') {
          for (final c in b['products']) {
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
    String formattedIds = "";
    for (final each in this.data) {
      if (each.isSelected && each.isOnSale) {
        formattedIds += '${each.id}|';
      }
    }
    if (formattedIds.length > 0) {
      var idx = formattedIds.lastIndexOf('|');
      formattedIds = formattedIds.substring(0, idx);
    }
    return formattedIds;
  }

  void selectTranslations(String id) {
    final arr = id.split('|').toList();
    final intArr = arr.map((e) => int.parse(e)).toList();
    var tempData = this.data;
    for (final t in tempData) {
      if (intArr.contains(t.id)) {
        t.isSelected = true;
      } else {
        t.isSelected = false;
      }
    }
    this.data = tempData;
  }

  String getFullName(int id) {
    var tempData = this.data;
    return tempData
        .where((bt) {
          return bt.id == id;
        })
        .toList()[0]
        .name;
  }

  static Future<BibleTranslations> fetch() async {
    final fileName = 'WebSite.json.gz';
    final hostAndPath = '$kTBStreamServer/$kTBApiVersion/products-list';
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
