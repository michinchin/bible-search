import '../tecarta.dart';
import '../Services/api.dart';

final _year = DateTime.now().year;
final _jan1 = new DateTime.utc(_year, 1, 1);
final _ordinalDay = DateTime.now().difference(_jan1).inDays;
final _parameters = '/$kTBApiVersion/home/votd-$_year.json';

class VOTDImage{
  
  final String url;

  VOTDImage({this.url});

  factory VOTDImage.fromJson(Map<String, dynamic> json) {
    final specials = json['specials'];
    final data = json['data'];
    final image = specials['$_ordinalDay'] == null
        ? data[_ordinalDay][1]
        : specials['$_ordinalDay'][1];
    return VOTDImage(
      url: 'https://$kTBStreamServer/$kTBApiVersion/votd/$image',
    );
  }

  static Future<VOTDImage> fetch() async {
    final api = API();
    final json = await api.getResponse(
      auth:kTBStreamServer,
      unencodedPath: _parameters,
      isGet: true
    );
    if (json != null) {
      return VOTDImage.fromJson(json);
    } else {
      return null;
    }
  }
}