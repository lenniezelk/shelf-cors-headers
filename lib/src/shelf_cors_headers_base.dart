import 'package:shelf/shelf.dart';

const ACCESS_CONTROL_ALLOW_ORIGIN = 'Access-Control-Allow-Origin';
const ACCESS_CONTROL_EXPOSE_HEADERS = 'Access-Control-Expose-Headers';
const ACCESS_CONTROL_ALLOW_CREDENTIALS = 'Access-Control-Allow-Credentials';
const ACCESS_CONTROL_ALLOW_HEADERS = 'Access-Control-Allow-Headers';
const ACCESS_CONTROL_ALLOW_METHODS = 'Access-Control-Allow-Methods';
const ACCESS_CONTROL_MAX_AGE = 'Access-Control-Max-Age';

const ORIGIN = 'origin';

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
  ACCESS_CONTROL_EXPOSE_HEADERS: '',
  ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
  ACCESS_CONTROL_ALLOW_HEADERS: _defaultHeadersList.join(','),
  ACCESS_CONTROL_ALLOW_METHODS: _defaultMethodsList.join(','),
  ACCESS_CONTROL_MAX_AGE: '86400',
};

final _defaultHeadersAll =
    _defaultHeaders.map((key, value) => MapEntry(key, [value]));

typedef OriginChecker = bool Function(String origin);

bool originAllowAll(String origin) => true;

OriginChecker originOneOf(List<String> origins) =>
    (origin) => origins.contains(origin);

Middleware corsHeaders({
  Map<String, String>? headers,
  OriginChecker originChecker = originAllowAll,
}) {
  final headersAll = headers?.map((key, value) => MapEntry(key, [value]));
  return (Handler handler) {
    return (Request request) async {
      final origin = request.headers[ORIGIN];
      if (origin == null || !originChecker(origin)) {
        return handler(request);
      }
      final _headers = <String, List<String>>{
        ..._defaultHeadersAll,
        ...?headersAll,
        ACCESS_CONTROL_ALLOW_ORIGIN: [origin],
      };

      if (request.method == 'OPTIONS') {
        return Response.ok(null, headers: _headers);
      }

      final response = await handler(request);
      return response.change(headers: {...response.headersAll, ..._headers});
    };
  };
}
