import 'dart:convert';

import 'package:http/http.dart';

class HttpJsonClient {
  final Client _client;

  HttpJsonClient(this._client);

  Future<Map<String, dynamic>> post(String url, Map<String, String> body) async {
    var response = await _client.post(url, body: body);
    return jsonFromResponse(response);
  }

  Future<Map<String, dynamic>> get(String url, Map<String, String> headers) async {
    var response = await _client.get(url, headers: headers);
    return jsonFromResponse(response);
  }
}

Map<String, dynamic> jsonFromResponse(Response response) {
  if (response.statusCode != 200) {
    print("Status code: " + response.statusCode.toString());
    print("Reason: " + response.reasonPhrase);
    print("Request: " + response.request.toString());
    print("Body: " + response.body);
    return null;
  }

  var jsonMap = json.decode(response.body) as Map<String, dynamic>;

  String error = jsonMap['error'] as String;
  if (error != null) {
    print("Error retrieving json" + error);
    return null;
  }

  return jsonMap;
}