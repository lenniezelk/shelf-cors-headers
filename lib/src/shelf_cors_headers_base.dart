import 'package:shelf/shelf.dart';

const ACCESS_CONTROL_ALLOW_ORIGIN = 'Access-Control-Allow-Origin';
const ACCESS_CONTROL_EXPOSE_HEADERS = 'Access-Control-Expose-Headers';
const ACCESS_CONTROL_ALLOW_CREDENTIALS = 'Access-Control-Allow-Credentials';
const ACCESS_CONTROL_ALLOW_HEADERS = 'Access-Control-Allow-Headers';
const ACCESS_CONTROL_ALLOW_METHODS = 'Access-Control-Allow-Methods';
const ACCESS_CONTROL_MAX_AGE = 'Access-Control-Max-Age';

const _defaultHeadersList = [
  'accept',
  'accept-encoding',
  'authorization',
  'content-type',
  'dnt',
  'origin',
  'user-agent',
];

const _defaultMethodsList = [
  'DELETE',
  'GET',
  'OPTIONS',
  'PATCH',
  'POST',
  'PUT'
];

Map<String, String> _defaultHeaders = {
  ACCESS_CONTROL_ALLOW_ORIGIN: '*',
  ACCESS_CONTROL_EXPOSE_HEADERS: '',
  ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
  ACCESS_CONTROL_ALLOW_HEADERS: _defaultHeadersList.join(','),
  ACCESS_CONTROL_ALLOW_METHODS: _defaultMethodsList.join(','),
  ACCESS_CONTROL_MAX_AGE: '86400',
};

Middleware corsHeaders({Map<String, String>? headers}) {
  Response? updateRequest(Request request) {
    var _headers = _defaultHeaders;

    if (headers != null) {
      _headers.addAll(headers);
    }

    if (request.method == 'OPTIONS') {
      return Response.ok(null, headers: _headers);
    }

    return null;
  }

  Response updateResponse(Response response) {
    var _headers = _defaultHeaders;

    if (headers != null) {
      _headers.addAll(headers);
    }

    return response.change(headers: _headers);
  }

  return createMiddleware(
      requestHandler: updateRequest, responseHandler: updateResponse);
}
