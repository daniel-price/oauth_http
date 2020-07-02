import 'package:oauth_http/oauth_http.dart';

class Example {
  main() async {
  	//Set up
    var identifier = 'YOUR-IDENTIFIER-HERE'; //get by signing up on truelayer.com
    var secret = 'YOUR-SECRET-HERE'; //get by signing up on truelayer.com
    var callbackUrlScheme = 'YOUR-APP-NAME-HERE'; //Also need to set this in AndroidManifest.xml
    var callBackUrlHost = 'YOUR-CALLBACK-URL-HOST-HERE'; //Also need to set this in AndroidManifest.xml

    var createPostUrl = 'https://auth.truelayer.com/connect/token';
    var redirectUrl = '$callbackUrlScheme://$callBackUrlHost';
    var authUrl = 'https://auth.truelayer.com/?response_type=code'
        '&client_id=$identifier'
        '&scope=info%20accounts%20balance%20cards%20transactions%20direct_debits%20standing_orders%20offline_access'
        '&redirect_uri=$redirectUrl'
        '&providers=uk-ob-all%20uk-oauth-all';

    var oAuthHttp = OAuthHttp.factory(authUrl, callbackUrlScheme, createPostUrl, identifier, secret, redirectUrl);
    
    var uuidAccessToken = await oAuthHttp.authenticate();
    
    var results = await oAuthHttp.doGet("https://api.truelayer.com/data/v1/me", uuidAccessToken);

    print(results);
  }
}
