import 'package:flutter_web_auth/flutter_web_auth.dart';


class AuthCodeGenerator {
  final String _authUrl;
  final String _callbackUrlScheme;

  AuthCodeGenerator(this._authUrl, this._callbackUrlScheme);

  Future<String> generate() async {
    try {
      final result = await FlutterWebAuth.authenticate(url: _authUrl, callbackUrlScheme: _callbackUrlScheme);
      var queryParameters = Uri.parse(result).queryParameters;
      String error = queryParameters['error'];
      if (error != null) {
        print('Error generating access token code: $error');
        return null;
      }

      return queryParameters['code'];
    } catch (e) {
      //TODO unit test
      print('error authenticating');
      print(e);
      return null;
    }
  }
}
