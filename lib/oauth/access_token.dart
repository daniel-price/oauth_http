import 'package:oauth_http/util/datetime_util.dart';
import 'package:uuid/uuid.dart';

class AccessToken {
  final String uuid;
  final String _accessToken;
  final DateTime _expiresAt;
  final String _tokenType;
  final String _refreshToken;
  final String _scope;

  AccessToken(this._accessToken, this._expiresAt, this._tokenType, this._refreshToken, this._scope, [String uuid]) : this.uuid = uuid ?? Uuid().v4();

  String get accessToken => _accessToken;

  DateTime get expiresAt => _expiresAt;

  String get tokenType => _tokenType;

  String get refreshToken => _refreshToken;

  String get scope => _scope;

  bool get shouldRefresh => inPast(expiresAt);
}