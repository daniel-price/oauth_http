import 'dart:convert';

import 'package:oauth_http/oauth/access_token.dart';
import 'package:oauth_http/oauth/access_token_retriever.dart';
import 'package:oauth_http/util/fake_http_client.dart';
import 'package:test/test.dart';


void main() {
  group(
    'retrieveAccessToken',
    () {
      test(
        'returns an access token if json returned',
        () async {
	        AccessTokenRetriever accessTokenRetriever = generateValidAccessTokenRetriever();
          var accessToken = await accessTokenRetriever.retrieveAccessToken({'body': 'default'});

          expect(accessToken, const TypeMatcher<AccessToken>());
        },
      );

      test(
	      'returns null if json not returned',
			      () async {
		      var accessTokenRetriever = generateTestAccessTokenRetriever();
		      var accessToken = await accessTokenRetriever.retrieveAccessToken({'body': 'default'});

		      expect(accessToken, null);
	      },
      );

      test(
	      'returns an access token with the passed in uuid',
			      () async {
	      	AccessTokenRetriever accessTokenRetriever = generateValidAccessTokenRetriever();
	      	var uuid = 'specificuuid';
		      var accessToken = await accessTokenRetriever.retrieveAccessToken({'body': 'default'}, uuid: uuid);

		      expect(accessToken.uuid, uuid);
	      },
      );

      test(
	      'sets expires at correctly from json and tolerance on generated access token',
			      () async {
		      var date = DateTime.parse('2014-09-11T12:53:39');
		      var expiresIn = 7200; //2 hours
		      var tolerance = 180; //3 mins
		      var expectedExpiresAt = DateTime.parse('2014-09-11T14:50:39');

		      AccessTokenRetriever accessTokenRetriever = generateValidAccessTokenRetriever(expiresIn: expiresIn, refreshTolerance: tolerance);
		      var accessToken = await accessTokenRetriever.retrieveAccessToken({'body': 'default'}, testNow: date);

		      expect(accessToken.expiresAt, expectedExpiresAt);
	      },
      );
    },
  );
}

AccessTokenRetriever generateValidAccessTokenRetriever({int expiresIn = 3600, int refreshTolerance = 120, String refreshToken = 'REFRESH-TOKEN-HERE'}) {
  //var responseJson = json.decode('{"access_token": "JWT-ACCESS-TOKEN-HERE","expires_in": $expiresIn,"token_type": "Bearer"}');
	var responseJson = json.decode('{"access_token": "JWT-ACCESS-TOKEN-HERE","expires_in": $expiresIn,"token_type": "Bearer","refresh_token": "$refreshToken"}');
	          var accessTokenRetriever = generateTestAccessTokenRetriever(responseJson: responseJson, refreshTolerance: refreshTolerance);
  return accessTokenRetriever;
}

AccessTokenRetriever generateTestAccessTokenRetriever({
  String url = 'google.com',
  int refreshTolerance = 120,
  Map<String, dynamic> responseJson,
}) {
  var fakeHttpClient = FakeHttpClient(responseJson);
  return AccessTokenRetriever(url, refreshTolerance, fakeHttpClient);
}
