import 'package:http/http.dart';
import 'package:oauth_http/util/http_client.dart';
import 'package:test/test.dart';

void main() {
  group(
    'jsonFromResponse',
    () {
      test(
        'returns a map if success response without error',
        () {
          var response = generateTestResponse();
          var json = jsonFromResponse(response);
          expect(
            json,
            const TypeMatcher<Map<String, dynamic>>(),
          );
        },
      );

      test(
        'returns null if response code is not 200',
        () {
          var response = generateTestResponse(statusCode: 300);
          var json = jsonFromResponse(response);
          expect(
            json,
            null,
          );
        },
      );

      test(
        'returns null if success response contains an error',
        () {
          var response = generateTestResponse(body: '{"error": "There was an error!","expires_in": 3600,"token_type": "Bearer"}', statusCode: 300);
          var json = jsonFromResponse(response);
          expect(
            json,
            null,
          );
        },
      );
    },
  );
}

generateTestResponse({
  String body = '{"access_token": "JWT-ACCESS-TOKEN-HERE","expires_in": 3600,"token_type": "Bearer"}',
  int statusCode = 200,
  String reasonPhrase = 'default reason phrase',
  BaseRequest request,
}) {
  return Response(
    body,
    statusCode,
    reasonPhrase: reasonPhrase,
    request: request ?? Request('request', null),
  );
}
