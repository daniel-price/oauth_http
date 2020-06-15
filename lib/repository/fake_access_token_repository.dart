import 'package:oauth_http/oauth/access_token.dart';
import 'package:oauth_http/repository/i_access_token_repository.dart';

class FakeAccessTokenRepository extends IAccessTokenRepository {
	List<AccessToken> _accessTokens = List();
	@override
	delete(AccessToken accessToken) {
		_accessTokens.remove(accessToken);
	}

	@override
	Future<AccessToken> get(String uuidAccessToken) {
		for (AccessToken accessToken in _accessTokens) {
			if (accessToken.uuid == uuidAccessToken) {
				return Future.value(accessToken);
			}
		}
		return null;
	}

	@override
	Future<List<AccessToken>> getAll() {
		return Future.value(_accessTokens);
	}

	@override
	insert(AccessToken accessToken) {
		_accessTokens.add(accessToken);
	}

	@override
	update(AccessToken accessToken) async {
		var existingAccessToken = await get(accessToken.uuid);
		delete(existingAccessToken);
		insert(accessToken);
	}

	int size() {
		return _accessTokens.length;
	}
}