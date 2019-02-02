import 'package:bible_search/tecarta.dart';
import '../Services/api.dart';

class BibleTranslation {
  final int id;
  final String name;
  final String a;
  final String lang;
  final bool isOnSale;
  bool isSelected;

  BibleTranslation({
    this.id,
    this.name,
    this.a,
    this.lang,
    this.isOnSale,
    this.isSelected = false,
  });

  factory BibleTranslation.fromJson(Map<String, dynamic> json){
    return BibleTranslation(
      id: json['id'],
      name: json['name'],
      a: json['abbreviation'],
      lang: json['language'],
    );
  }

}

class BibleTranslations {
  var data = <BibleTranslation>[];

  BibleTranslations({this.data});

  factory BibleTranslations.fromJson(Map<String, dynamic> json) {
    var d = <BibleTranslation>[];
    final a = json['categories'] as List<dynamic>;
    for (final b in a) {
      if (b is Map<String,dynamic>) {
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

  static Future<BibleTranslations> fetch() async {
    final api = API();
    final json = await api.getResponse(
      auth: kTBStreamServer,
      unencodedPath: '/$kTBApiVersion/products-list/WebSite.json.gz',
      isGet: true,
    );
    if (json != null) {
      return BibleTranslations.fromJson(json);
    } else {
      return BibleTranslations(data: []);
    }
  }
}