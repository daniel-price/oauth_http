import 'dart:convert';

import 'package:oauth_http/oauth/access_token.dart';
import 'package:oauth_http/oauth/auth_code_generator.dart';
import 'package:oauth_http/oauth_http.dart';
import 'package:oauth_http/util/fake_http_client.dart';
import 'package:test/test.dart';

import 'oauth/access_token_store_test.dart';

void main() {
  group(
    'authenticate',
    () {
      test(
        'returns an access token uuid code is generated',
        () async {
          var fakeAuthCodeGenerator = FakeAuthCodeGenerator.forCode();
          var accessTokenStore = generateTestAccessTokenStore();
          var oAuthHttp = OAuthHttp(null, accessTokenStore, fakeAuthCodeGenerator);

          var uuid = await oAuthHttp.authenticate();

          expect(uuid, TypeMatcher<String>());
        },
      );

      test(
        'returns null if no code is generated',
        () async {
          var fakeAuthCodeGenerator = FakeAuthCodeGenerator.forCode(code: null);
          var accessTokenStore = generateTestAccessTokenStore();
          var oAuthHttp = OAuthHttp(null, accessTokenStore, fakeAuthCodeGenerator);

          var uuid = await oAuthHttp.authenticate();

          expect(uuid, null);
        },
      );
    },
  );

  group(
    'doGet',
    () {
      test(
        'returns a list of results if valid',
        () async {
					var accessToken = generateTestAccessToken();
					var responseJson = json.decode(
							'{"results":[{"update_timestamp":"2017-02-07T17:29:24.740802Z","account_id":"f1234560abf9f57287637624def390871","account_type":"TRANSACTION","display_name":"ClubLloyds","currency":"GBP","account_number":{"iban":"GB35LOYD12345678901234","number":"12345678","sort_code":"12-34-56","swift_bic":"LOYDGB2L"},"provider":{"display_name":"LloydsBank","logo_uri":"https://auth.truelayer.com/img/banks/banks-icons/lloyds-icon.svg","provider_id":"lloyds"}},{"update_timestamp":"2017-02-07T17:29:24.740802Z","account_id":"f1234560abf9f57287637624def390872","account_type":"SAVINGS","display_name":"ClubLloyds","currency":"GBP","account_number":{"iban":"GB35LOYD12345678901235","number":"12345679","sort_code":"12-34-57","swift_bic":"LOYDGB2L"},"provider":{"display_name":"LloydsBank","logo_uri":"https://auth.truelayer.com/img/banks/banks-icons/lloyds-icon.svg","provider_id":"lloyds"}}]}');
					var oAuthHttp = generateOAuthHttpForAccessTokenAndResponseJson(accessToken, responseJson);

          var results = await oAuthHttp.doGet('url', accessToken.uuid);

          expect(results, TypeMatcher<List>());
        },
      );

      test(
        'returns null if uuid is not valid',
        () async {
        	var accessTokenStore = generateTestAccessTokenStore();
          var oAuthHttp = OAuthHttp(null, accessTokenStore, null);

          var results = await oAuthHttp.doGet('url', 'uuidAccessToken');

          expect(results, null);
        },
      );

      test(
        'returns null if response is not valid',
        () async {
        	var accessToken = generateTestAccessToken();
	        var oAuthHttp = generateOAuthHttpForAccessTokenAndResponseJson(accessToken, null);

	        var results = await oAuthHttp.doGet('url', 'uuidAccessToken');

          expect(results, null);
        },
      );
    },
  );
}

OAuthHttp generateOAuthHttpForAccessTokenAndResponseJson(AccessToken accessToken, responseJson) {
  var accessTokenRepository = generateFakeAccessTokenRepository();
            accessTokenRepository.insert(accessToken);
            var accessTokenStore = generateTestAccessTokenStore(accessTokenRepository: accessTokenRepository);
            var fakeHttpClient = FakeHttpClient(responseJson);
            var oAuthHttp = OAuthHttp(fakeHttpClient, accessTokenStore, null);
  return oAuthHttp;
}

class FakeAuthCodeGenerator implements AuthCodeGenerator {
  final String _code;

  FakeAuthCodeGenerator(this._code);

  factory FakeAuthCodeGenerator.forCode({String code = 'default code'}) {
    return FakeAuthCodeGenerator(code);
  }
  @override
  Future<String> generate() {
    return Future.value(_code);
  }
}
