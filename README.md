# oauth_http

oauth_http is a Flutter/Dart package for managing multiple OAuth2 authentication tokens for custom APIs and retrieving results.

## Usage

A single OAuthHttp object is responsible for generating one or more Access Tokens and use these for making authenticated API GET requests. It is used via two methods, which encapsulate behaviour as described below:

- `authenticate()`
	- **Authenticates** with an OAuth2 API to generate an [Authorization Code](https://oauth.net/2/grant-types/authorization-code/), through an in-app browser
	- **Exchanges** this Authorization Code  for an [Access Token](https://www.oauth.com/oauth2-servers/access-tokens/)
	- **Persists** the Access Token
- `doGet(url, uuidAccessToken)`
	- **Refreshes** the Access Token and **persists** the refreshed token (only if it has expired)
	- [**Requests data**](https://www.oauth.com/oauth2-servers/accessing-data/making-api-requests/) from the API  and returns the results as JSON

## Example
The`factory()` method offers a convenient way of constructing an OAuthHttp object. 
By default, this uses FlutterSecureStorage to persist Access Tokens and an IOClient for making GET requests, but takes optional parameters if you wish to specifying a custom repository or client.
You can also specify how soon an Access Token should be refreshed before it expires. By default this is 120 seconds.

```
//Set up  
var identifier = 'YOUR-IDENTIFIER-HERE'; //get by signing up on truelayer.com  
var secret = 'YOUR-SECRET-HERE'; //get by signing up on truelayer.com  
var callbackUrlScheme = 'YOUR-APP-NAME-HERE'; //Also need to set this in AndroidManifest.xml  
var callBackUrlHost = 'YOUR-CALLBACK-URL-HOST-HERE'; //Also need to set this in AndroidManifest.xml  
  
var createPostUrl = 'https://auth.truelayer.com/connect/token';  
var redirectUrl = '$callbackUrlScheme://$callBackUrlHost';  
var authUrl = 'https://auth.truelayer.com/?response_type=code'  
 '&client_id=$identifier'  
 '&scope=info%20accounts%20balance%20cards%20transactions%20direct_debits%20standing_orders%20offline_access' '&redirect_uri=$redirectUrl'  
 '&providers=uk-ob-all%20uk-oauth-all';  

//factory 
var oAuthHttp = OAuthHttp.factory(authUrl, callbackUrlScheme, createPostUrl, identifier, secret, redirectUrl);  

//authenticate
var uuidAccessToken = await oAuthHttp.authenticate();  

//doGet
var results = await oAuthHttp.doGet("https://api.truelayer.com/data/v1/me", uuidAccessToken);  
```
