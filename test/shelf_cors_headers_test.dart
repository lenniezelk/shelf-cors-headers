import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:test/test.dart';

const String _allowedOrigin = 'http://localhost';

// Utils From shelf lib tests
/// Makes a simple GET request to [handler] and returns the result.
Future<Response> makeSimpleRequest(Handler handler,
        {String method = 'GET',
        String origin = _allowedOrigin,
        Map<String, String>? headers}) =>
    Future.sync(() =>
        handler(_request(method: method, origin: origin, headers: headers)));

Request _request(
    {String method = 'GET',
    required String origin,
    Map<String, String>? headers}) {
  return Request(
    method,
    localhostUri,
    headers: {ORIGIN: origin, ...?headers},
  );
}

final localhostUri = Uri.parse('http://localhost/');

Response syncHandler(Request request,
    {int? statusCode, Map<String, String>? headers}) {
  return Response(statusCode ?? 200,
      headers: {...request.headers, ...?headers},
      body: 'Hello from ${request.requestedUri.path}');
}

void main() {
  test('cors headers set in response', () {
    var handler =
        const Pipeline().addMiddleware(corsHeaders()).addHandler(syncHandler);

    return makeSimpleRequest(handler).then((response) {
      expect(response.headers[ACCESS_CONTROL_ALLOW_ORIGIN], _allowedOrigin);
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
      expect(response.headers[ACCESS_CONTROL_ALLOW_ORIGIN], _allowedOrigin);
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
      'Content-Type': 'application/json;charset=utf-8',
      'my-custom-header': 'my-value'
    };

    var handler = const Pipeline()
        .addMiddleware(corsHeaders(headers: headers))
        .addHandler(syncHandler);

    return makeSimpleRequest(handler).then((response) {
      expect(response.headers[ACCESS_CONTROL_ALLOW_ORIGIN], _allowedOrigin);
      expect(response.headers[ACCESS_CONTROL_EXPOSE_HEADERS], '');
      expect(response.headers[ACCESS_CONTROL_ALLOW_CREDENTIALS], 'true');
      expect(response.headers[ACCESS_CONTROL_ALLOW_METHODS],
          'DELETE,GET,OPTIONS,PATCH,POST,PUT');
      expect(response.headers[ACCESS_CONTROL_ALLOW_HEADERS],
          'accept,accept-encoding,authorization,content-type,dnt,origin,user-agent');
      expect(response.headers[ACCESS_CONTROL_MAX_AGE], '86400');
      expect(
          response.headers['Content-Type'], 'application/json;charset=utf-8');
      expect(response.headers['my-custom-header'], 'my-value');
    });
  });

  test('disallowed origin', () async {
    final allowed = 'https://allowed.com';
    final rejected = 'https://rejected.com';
    var handler = const Pipeline()
        .addMiddleware(corsHeaders(originChecker: originOneOf([allowed])))
        .addHandler(syncHandler);

    final response = await makeSimpleRequest(handler, origin: allowed);
    expect(response.headers[ACCESS_CONTROL_ALLOW_ORIGIN], allowed);

    final response2 = await makeSimpleRequest(handler, origin: rejected);
    expect(response2.headers[ACCESS_CONTROL_ALLOW_ORIGIN], isNull);
  });

  test('user provided headers not overwritten', () {
    final headers = {
      'Content-Type': 'application/json;charset=utf-8',
      'my-custom-header': 'my-value'
    };

    var handler = const Pipeline()
        .addMiddleware(corsHeaders(headers: headers))
        .addHandler(syncHandler);

    return makeSimpleRequest(handler,
        headers: {'my-custom-header': 'other-value'}).then((response) {
      expect(response.headers['my-custom-header'], 'other-value');
    });
  });

  test('user can override "Access-Control-Allow-Origin"', () {
    final headers = {'Access-Control-Allow-Origin': '*'};

    var handler = const Pipeline()
        .addMiddleware(corsHeaders(headers: headers))
        .addHandler(syncHandler);

    return makeSimpleRequest(handler,
        headers: {'my-custom-header': 'other-value'}).then((response) {
      expect(response.headers['Access-Control-Allow-Origin'], '*');
      expect(response.headers['Vary'], 'Origin');
    });
  });
}
