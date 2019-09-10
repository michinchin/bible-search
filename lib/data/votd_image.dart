import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../tec_settings.dart';

final _year = DateTime.now().year;
final _jan1 = DateTime.utc(_year, 1, 1);
final _ordinalDay = DateTime.now().difference(_jan1).inDays;
final _parameters = '/$kTBApiVersion/home/votd-$_year.json';

class VOTDImage {
  final String url;

  VOTDImage({this.url});

  factory VOTDImage.fromJson(Map<String, dynamic> json) {
    final specials = tec.as<Map<String, dynamic>>(json['specials']);
    final data = tec.as<List<dynamic>>(json['data']);
    final image = tec.as<String>(tec.isNullOrEmpty(specials['$_ordinalDay'])
        ? data[_ordinalDay][1]
        : specials['$_ordinalDay'][1]);
    return VOTDImage(
      url: 'https://$kTBStreamServer/$kTBApiVersion/votd/$image',
    );
  }

  static Future<VOTDImage> fetch() async {
    final json = await TecCache().jsonFromUrl(
      url: 'https://$kTBStreamServer$_parameters',
    );
    if (json != null) {
      return VOTDImage.fromJson(json);
    } else {
      return null;
    }
  }
}
