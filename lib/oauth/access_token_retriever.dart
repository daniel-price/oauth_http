import 'package:oauth_http/oauth/access_token.dart';
import 'package:oauth_http/util/http_client.dart';

class AccessTokenRetriever {
  final String _url;
  final int _refreshTolerance;
  final HttpJsonClient _httpJsonClient;

  AccessTokenRetriever(this._url, this._refreshTolerance, this._httpJsonClient);

  Future<AccessToken> retrieveAccessToken(Map<String, String> body, {String uuid, DateTime testNow}) async {
    var json = await _httpJsonClient.post(_url, body);
    if (json == null) {
      return null;
    }

    String accessToken = json['access_token'] as String;
    int expiresIn = json['expires_in'] as int;
    var expiresAt = _calculateExpiresAt(expiresIn, _refreshTolerance, testNow: testNow);
    String tokenType = json['token_type'] as String;
    String refreshToken = json['refresh_token'] as String;
    String scope = json['scope'] as String;

    return AccessToken(accessToken, expiresAt, tokenType, refreshToken, scope, uuid);
  }
}

DateTime _calculateExpiresAt(int expiresIn, int refreshTolerance, {DateTime testNow}) {
  DateTime now = testNow ?? DateTime.now();
  int expiresInWithTolerance = expiresIn - refreshTolerance;
  Duration expiresInWithToleranceDuration = Duration(seconds: expiresInWithTolerance);
  return now.add(expiresInWithToleranceDuration);
}
