import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';

final _year = DateTime.now().year;
final _jan1 = new DateTime.utc(_year, 1, 1);
final _ordinalDay = DateTime.now().difference(_jan1).inDays;
final String _url = 'cf-stream.tecartabible.com';

class VOTDImageAPI {
  final HttpClient _httpClient = HttpClient();

  Future<String> getImageURL() async {
    final uri = Uri.https(_url, '/7/home/votd-$_year.json');

    final jsonResponse = await _getJson(uri);

    if (jsonResponse == null || jsonResponse['data'] == null) {
      print('Error retrieving units.');
      return null;
    }
    final specials = jsonResponse['specials'];
    final data = jsonResponse['data'];

    return specials['$_ordinalDay'] == null
        ? data[_ordinalDay][1]
        : specials['$_ordinalDay'][1];
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.OK) {
        return null;
      }
      // The response is sent as a Stream of bytes that we need to convert to a
      // `String`.
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      // Finally, the string is parsed into a JSON object.
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}
