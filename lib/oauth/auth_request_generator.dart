class AuthRequestGenerator {
  final String _identifier;
  final String _secret;
  final String _redirectUrl;

  AuthRequestGenerator(this._identifier, this._secret, this._redirectUrl);

  Map<String, String> generateForCode(String code) {
    return {
      "grant_type": "authorization_code",
      "client_id": _identifier,
      "client_secret": _secret,
      "redirect_uri": _redirectUrl,
      "code": code,
    };
  }

  Map<String, String> generateForRefreshToken(String refreshToken) {
    return {
      "grant_type": "refresh_token",
      "client_id": _identifier,
      "client_secret": _secret,
      "refresh_token": refreshToken,
    };
  }
}