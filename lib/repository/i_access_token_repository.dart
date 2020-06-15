
import 'package:oauth_http/oauth/access_token.dart';

abstract class IAccessTokenRepository {
  insert(AccessToken accessToken);

  update(AccessToken accessToken);

  delete(AccessToken accessToken);

  Future<List<AccessToken>> getAll();

  Future<AccessToken> get(String uuidAccessToken);
}
