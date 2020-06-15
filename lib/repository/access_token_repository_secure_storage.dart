import 'dart:convert';

import 'package:oauth_http/oauth/access_token.dart';
import 'package:oauth_http/repository/i_access_token_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccessTokenRepositorySecureStorage extends IAccessTokenRepository {
  final FlutterSecureStorage _storage;

  AccessTokenRepositorySecureStorage(this._storage);

  @override
  Future<void> delete(AccessToken accessToken) async {
    await _deleteForUuid(accessToken.uuid);
  }

  @override
  Future<AccessToken> get(String uuidAccessToken) async {
    var accessTokenString = await _storage.read(key: uuidAccessToken);
    return _accessTokenFromString(uuidAccessToken, accessTokenString);
  }

  @override
  Future<List<AccessToken>> getAll() async {
    Map<String, String> accessTokenMaps = await _storage.readAll();
    return _accessTokensFromString(accessTokenMaps);
  }

  @override
  Future<void> insert(AccessToken accessToken) async {
    String value = _toPersistString(accessToken);
    await _storage.write(key: accessToken.uuid, value: value);
  }

  @override
  Future<void> update(AccessToken accessToken) async {
    await _deleteForUuid(accessToken.uuid);
    await insert(accessToken);
  }

  _deleteForUuid(String uuid) async {
    await _storage.delete(key: uuid);
  }
}

AccessToken _accessTokenFromString(String uuid, String value) {
  AccessToken accessToken = _fromPersistString(value);
  return accessToken;
}

String _toPersistString(AccessToken accessToken) {
  var map = <String, dynamic>{
    'uuid': accessToken.uuid,
    'accessToken': accessToken.accessToken,
    'expiresAt': accessToken.expiresAt.millisecondsSinceEpoch,
    'tokenType': accessToken.tokenType,
    'refreshToken': accessToken.refreshToken,
    'scope': accessToken.scope,
  };

  return json.encode(map);
}

AccessToken _fromPersistString(String string) {
  Map<String, dynamic> map = json.decode(string) as Map<String, dynamic>;
  return AccessToken(
    map['accessToken'] as String,
    DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] as int),
    map['tokenType'] as String,
    map['refreshToken'] as String,
    map['scope'] as String,
    map['uuid'] as String,
  );
}

List<AccessToken> _accessTokensFromString(Map<String, String> accessTokenMaps) {
  List<AccessToken> accessTokens = new List();
  accessTokenMaps.forEach((key, value) {
    AccessToken accessToken = _accessTokenFromString(key, value);
    accessTokens.add(accessToken);
  });
  return accessTokens;
}
