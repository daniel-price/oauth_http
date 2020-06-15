
import 'package:oauth_http/util/http_client.dart';

class FakeHttpClient implements HttpJsonClient {
	final Map<String, dynamic> _json;

	FakeHttpClient(this._json);

  @override
  Future<Map<String, dynamic>> get(String url, Map<String, String> headers) {
	  return _getFutureJson();
  }

  @override
  Future<Map<String, dynamic>> post(String url, Map<String, String> head) {
    return _getFutureJson();
  }

	Future<Map<String, dynamic>> _getFutureJson() {
		return Future.value(_json);
	}
}