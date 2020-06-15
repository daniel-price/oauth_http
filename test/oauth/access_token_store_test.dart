import 'package:oauth_http/oauth/access_token.dart';
import 'package:oauth_http/oauth/access_token_retriever.dart';
import 'package:oauth_http/oauth/access_token_store.dart';
import 'package:oauth_http/oauth/auth_request_generator.dart';
import 'package:oauth_http/repository/fake_access_token_repository.dart';
import 'package:oauth_http/repository/i_access_token_repository.dart';
import 'package:test/test.dart';

import 'access_token_retriever_test.dart';

void main() {
  group('authenticate', () {
    test(
      'returns a uuid if successful authentication',
      () async {
        var accessTokenStore = generateTestAccessTokenStore();

        var result = await accessTokenStore.authenticate("code");

        expect(result, const TypeMatcher<String>());
      },
    );

    test(
      'access token saved if successful authentication',
      () async {
        var accessTokenRepository = generateFakeAccessTokenRepository();
        var accessTokenStore = generateTestAccessTokenStore(accessTokenRepository: accessTokenRepository);

        await accessTokenStore.authenticate("code");

        expect(accessTokenRepository.size(), 1);
      },
    );

    test(
      'returns null if authentication unsuccessful',
      () async {
        var accessTokenStore = generateUnsuccessfulAccessTokenStore();

        var result = await accessTokenStore.authenticate("code");

        expect(result, null);
      },
    );

    test(
      'access token not saved if successful authentication',
      () async {
        var accessTokenRepository = generateFakeAccessTokenRepository();
        var accessTokenStore = generateUnsuccessfulAccessTokenStore(accessTokenRepository: accessTokenRepository);

        await accessTokenStore.authenticate("code");

        expect(accessTokenRepository.size(), 0);
      },
    );
  });

  group('getToken', () {
    test(
      'returns refresh token for the original access token if is it valid',
      () async {
        var accessTokenRepository = generateFakeAccessTokenRepository();
        var accessTokenStore = generateTestAccessTokenStore(accessTokenRepository: accessTokenRepository);

        var accessToken = generateTestAccessToken(expiresInSeconds:120);
        accessTokenRepository.insert(accessToken);

        var result = await accessTokenStore.getToken(accessToken.uuid);

        expect(result, accessToken.accessToken);
      },
    );

    test(
      'returns refresh token for a refreshed access token if is has expired',
      () async {
        var accessTokenRepository = generateFakeAccessTokenRepository();
        var accessTokenStore = generateTestAccessTokenStore(accessTokenRepository: accessTokenRepository);

        AccessToken accessToken = generateTestAccessToken(expiresInSeconds:-120);
        accessTokenRepository.insert(accessToken);

        var result = await accessTokenStore.getToken(accessToken.uuid);
        var isDifferent = result != accessToken.accessToken;

        expect(isDifferent, true);
      },
    );

    test(
      'saves a refreshed access token if is has expired',
      () async {
        var accessTokenRepository = generateFakeAccessTokenRepository();
        var accessTokenStore = generateTestAccessTokenStore(accessTokenRepository: accessTokenRepository);

        AccessToken accessToken = generateTestAccessToken(expiresInSeconds:-120);
        accessTokenRepository.insert(accessToken);

        await accessTokenStore.getToken(accessToken.uuid);
        var refreshedAccessToken = await accessTokenRepository.get(accessToken.uuid);
        var isDifferent = refreshedAccessToken.accessToken != accessToken.accessToken;

        expect(isDifferent, true);
      },
    );

    test(
      'returns null if the uuid not in the store',
          () async {
        var accessTokenStore = generateTestAccessTokenStore();
        AccessToken accessToken = generateTestAccessToken();
        var response = await accessTokenStore.getToken(accessToken.uuid);

        expect(response, null);
      },
    );
  });
}

AccessToken generateTestAccessToken({int expiresInSeconds = 120}) {
  var expiresInDuration = Duration(seconds: expiresInSeconds);
  var now = DateTime.now();
  var expiresAt = now.add(expiresInDuration);
  return AccessToken('accessToken', expiresAt, 'tokenType', 'refreshToken', 'scope');
}

FakeAccessTokenRepository generateFakeAccessTokenRepository() {
  return FakeAccessTokenRepository();
}

AccessTokenStore generateUnsuccessfulAccessTokenStore({FakeAccessTokenRepository accessTokenRepository}) {
  var accessTokenRetriever = generateTestAccessTokenRetriever();
  var accessTokenStore = generateTestAccessTokenStore(accessTokenRepository: accessTokenRepository, accessTokenRetriever: accessTokenRetriever);
  return accessTokenStore;
}

AccessTokenStore generateTestAccessTokenStore({IAccessTokenRepository accessTokenRepository, AccessTokenRetriever accessTokenRetriever}) {
  AuthRequestGenerator authRequestGenerator = AuthRequestGenerator('identifier', 'secret', 'redirecturl');
  var accessTokenStore = AccessTokenStore(
    accessTokenRepository ?? generateFakeAccessTokenRepository(),
    authRequestGenerator,
    accessTokenRetriever ?? generateValidAccessTokenRetriever(),
  );
  return accessTokenStore;
}
