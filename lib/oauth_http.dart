library oauth_http;

import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/io_client.dart';
import 'package:oauth_http/oauth/access_token_retriever.dart';
import 'package:oauth_http/oauth/access_token_store.dart';
import 'package:oauth_http/oauth/auth_code_generator.dart';
import 'package:http/http.dart';
import 'package:oauth_http/oauth/auth_request_generator.dart';
import 'package:oauth_http/repository/access_token_repository_secure_storage.dart';
import 'package:oauth_http/repository/i_access_token_repository.dart';
import 'package:oauth_http/util/http_client.dart';

import 'oauth/auth_code_generator.dart';

class OAuthHttp {
  final HttpJsonClient _httpJsonClient;
  final AccessTokenStore _accessTokenStore;
  final AuthCodeGenerator _authCodeGenerator;

  OAuthHttp(this._httpJsonClient, this._accessTokenStore, this._authCodeGenerator);

  factory OAuthHttp.factory(String authUrl, String callbackUrlScheme, String url, String identifier, String secret, String redirectUrl, {IAccessTokenRepository accessTokenRepository, Client client, int refreshTolerance}) {
    if (accessTokenRepository == null) {
      accessTokenRepository = AccessTokenRepositorySecureStorage(FlutterSecureStorage());
    }

    if (client == null) {
      client = IOClient();
    }

    if (refreshTolerance == null) {
      refreshTolerance = 120;
    }

    var httpJsonClient = HttpJsonClient(client);

    var authCodeGenerator = AuthCodeGenerator(authUrl, callbackUrlScheme);
    var accessTokenRetriever = AccessTokenRetriever(url, refreshTolerance, httpJsonClient);
    var authRequestGenerator = AuthRequestGenerator(identifier, secret, redirectUrl);
    var accessTokenStore = AccessTokenStore(accessTokenRepository, authRequestGenerator, accessTokenRetriever);

    return OAuthHttp(httpJsonClient, accessTokenStore, authCodeGenerator);
  }

  Future<List> doGet(String url, String uuidAccessToken) async {
    var token = await _accessTokenStore.getToken(uuidAccessToken);
    if (token == null) {
      print('no token found for uuid $uuidAccessToken');
      return null;
    }

    var json = await _httpJsonClient.get(
      url,
      {HttpHeaders.authorizationHeader: "Bearer $token"},
    );

    if (json == null) {
      return null;
    }

    return json['results'] as List<dynamic>;
  }

  Future<String> authenticate() async {
    String code = await _authCodeGenerator.generate();
    if (code == null) {
      return null;
    }

    return _accessTokenStore.authenticate(code);
  }
}
