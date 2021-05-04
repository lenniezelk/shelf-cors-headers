import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:test/test.dart';

// Utils From shelf lib tests
/// Makes a simple GET request to [handler] and returns the result.
Future<Response> makeSimpleRequest(Handler handler, {String method = 'GET'}) =>
    Future.sync(() => handler(_request(method: method)));

Request _request({String method = 'GET'}) => Request(method, localhostUri);

final localhostUri = Uri.parse('http://localhost/');

Response syncHandler(Request request,
    {int? statusCode, Map<String, String>? headers}) {
  return Response(statusCode ?? 200,
      headers: headers, body: 'Hello from ${request.requestedUri.path}');
}

void main() {
  test('cors headers set in response', () {
    var handler =
        const Pipeline().addMiddleware(corsHeaders()).addHandler(syncHandler);

    return makeSimpleRequest(handler).then((response) {
      print(response.headers);
      expect(response.headers[ACCESS_CONTROL_ALLOW_ORIGIN], '*');
      expect(response.headers[ACCESS_CONTROL_EXPOSE_HEADERS], '');
      expect(response.headers[ACCESS_CONTROL_ALLOW_CREDENTIALS], 'true');
      expect(response.headers[ACCESS_CONTROL_ALLOW_METHODS],
          'DELETE,GET,OPTIONS,PATCH,POST,PUT');
      expect(response.headers[ACCESS_CONTROL_ALLOW_HEADERS],
          'accept,accept-encoding,authorization,content-type,dnt,origin,user-agent');
      expect(response.headers[ACCESS_CONTROL_MAX_AGE], '86400');
    });
  });

  test('cors headers set in options request', () {
    var handler =
        const Pipeline().addMiddleware(corsHeaders()).addHandler(syncHandler);

    return makeSimpleRequest(handler, method: 'OPTIONS').then((response) {
      expect(response.headers[ACCESS_CONTROL_ALLOW_ORIGIN], '*');
      expect(response.headers[ACCESS_CONTROL_EXPOSE_HEADERS], '');
      expect(response.headers[ACCESS_CONTROL_ALLOW_CREDENTIALS], 'true');
      expect(response.headers[ACCESS_CONTROL_ALLOW_METHODS],
          'DELETE,GET,OPTIONS,PATCH,POST,PUT');
      expect(response.headers[ACCESS_CONTROL_ALLOW_HEADERS],
          'accept,accept-encoding,authorization,content-type,dnt,origin,user-agent');
      expect(response.headers[ACCESS_CONTROL_MAX_AGE], '86400');
    });
  });

  test('user provided headers', () {
    final headers = {
      ACCESS_CONTROL_ALLOW_ORIGIN: 'example.com',
      'Content-Type': 'application/json;charset=utf-8'
    };

    var handler = const Pipeline()
        .addMiddleware(corsHeaders(headers: headers))
        .addHandler(syncHandler);

    return makeSimpleRequest(handler).then((response) {
      expect(response.headers[ACCESS_CONTROL_ALLOW_ORIGIN], 'example.com');
      expect(response.headers[ACCESS_CONTROL_EXPOSE_HEADERS], '');
      expect(response.headers[ACCESS_CONTROL_ALLOW_CREDENTIALS], 'true');
      expect(response.headers[ACCESS_CONTROL_ALLOW_METHODS],
          'DELETE,GET,OPTIONS,PATCH,POST,PUT');
      expect(response.headers[ACCESS_CONTROL_ALLOW_HEADERS],
          'accept,accept-encoding,authorization,content-type,dnt,origin,user-agent');
      expect(response.headers[ACCESS_CONTROL_MAX_AGE], '86400');
      expect(
          response.headers['Content-Type'], 'application/json;charset=utf-8');
    });
  });
}
