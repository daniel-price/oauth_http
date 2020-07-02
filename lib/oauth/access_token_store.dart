import 'package:oauth_http/oauth/access_token.dart';
import 'package:oauth_http/oauth/access_token_retriever.dart';
import 'package:oauth_http/oauth/auth_request_generator.dart';
import 'package:oauth_http/repository/i_access_token_repository.dart';

class AccessTokenStore {
  final IAccessTokenRepository _accessTokenRepository;
  final AuthRequestGenerator _authRequestGenerator;
  final AccessTokenRetriever _accessTokenRetriever;

  AccessTokenStore(this._accessTokenRepository, this._authRequestGenerator, this._accessTokenRetriever);

  Future<String> authenticate(String code) async {
    var body = _authRequestGenerator.generateForCode(code);
    var accessToken = await _accessTokenRetriever.retrieveAccessToken(body);
    if (accessToken == null) {
      return null;
    }

    await _accessTokenRepository.insert(accessToken);
    return accessToken.uuid;
  }

  Future<String> getToken(String uuidAccessToken) async {
    AccessToken accessToken = await _getRefreshAccessToken(uuidAccessToken);
    if (accessToken == null)
      {
        return null;
      }
    return accessToken.accessToken;
  }

  Future<List<String>> getAllKeys() async {
    List<AccessToken> accessTokens = await _accessTokenRepository.getAll();
    List<String> uuidAccessTokens = List();
    for (AccessToken accessToken in accessTokens) {
      uuidAccessTokens.add(accessToken.uuid);
    }
    return uuidAccessTokens;
  }

  Future<AccessToken> _getRefreshAccessToken(String uuidAccessToken) async {
    AccessToken accessToken = await _accessTokenRepository.get(uuidAccessToken);
    if (accessToken == null) {
      return null;
    }

    if (!accessToken.shouldRefresh) {
      return accessToken;
    }
    var body = _authRequestGenerator.generateForRefreshToken(accessToken.refreshToken);

    //TODO - write unit test
    try {
      var refreshedAccessToken = await _accessTokenRetriever.retrieveAccessToken(body, uuid: accessToken.uuid);
      await _accessTokenRepository.update(refreshedAccessToken);
      return refreshedAccessToken;
    }
    catch (e) {
      print(e);
      return null;
    }
  }
}