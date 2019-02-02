import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';

// final _year = DateTime.now().year;
// final _jan1 = new DateTime.utc(_year, 1, 1);
// final _ordinalDay = DateTime.now().difference(_jan1).inDays;
// final String _url = 'cf-stream.tecartabible.com';

class API {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String,dynamic>> getResponse({String auth, String unencodedPath, Map<String,String> queryParameters,bool isGet}) async {
    final uri = Uri.https(auth, unencodedPath, queryParameters);
    final jsonResponse = await _getJson(uri,isGet);

    if (jsonResponse == null) {
      print('Error retrieving json.');
      return null;
    }
    return jsonResponse;
  }

  Future<Map<String, dynamic>> _getJson(Uri uri, bool isGet) async {
    try {
      final httpRequest = isGet ? await _httpClient.getUrl(uri) : await _httpClient.postUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.ok) {
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
