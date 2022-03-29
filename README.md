# CORS headers middleware for Shelf

A Shelf middleware to add [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) headers to shelf responses.

## Features

- Handles preflight requests.
- Allows override of default headers.
- Allows user to provide their own origin checker function.

## Usage

A simple usage example:

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

void main() async {
  var handler = const Pipeline()
      // Just add corsHeaders() middleware.
      .addMiddleware(corsHeaders())
      .addHandler(_requestHandler);

  await serve(handler, 'localhost', 8080);
}

Response _requestHandler(Request request) {
  return Response.ok('Request for "${request.url}"');
}
```

### Override Headers

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

void main() async {
  // optionally override default headers
  final overrideHeaders = {
    ACCESS_CONTROL_ALLOW_ORIGIN: 'example.com',
    'Content-Type': 'application/json;charset=utf-8'
  };

  var handler = const Pipeline()
      // Just add corsHeaders() middleware and pass your header overrides.
      .addMiddleware(corsHeaders(headers: overrideHeaders))
      .addHandler(_requestHandler);

  await serve(handler, 'localhost', 8080);
}

Response _requestHandler(Request request) {
  return Response.ok('Request for "${request.url}"');
}
```

### Custom origin checker

Your origin checker function should consume a string as a parameter(the value of ORIGIN header) and return a boolean value
indicating if this middleware should process the request from that origin.

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

// define our origin checker
bool dontCheckCNNRequests(String origin) {
  if (origin.contains('cnn.com')) return false;
  return true;
}

void main() async {
  // optionally override default headers
  final overrideHeaders = {
    'Content-Type': 'application/json;charset=utf-8'
  };

  var handler = const Pipeline()
      // Just add corsHeaders() middleware and pass your origin checker
      .addMiddleware(corsHeaders(headers: overrideHeaders, originChecker: dontCheckCNNRequests))
      .addHandler(_requestHandler);

  await serve(handler, 'localhost', 8080);
}

Response _requestHandler(Request request) {
  return Response.ok('Request for "${request.url}"');
}
```

You can also use the inbuilt `originOneOf` which takes a list of origins to check:

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

// define our origin checker
final listChecker = originOneOf(['https://cnn.com', 'https://dart.dev'])

void main() async {
  // optionally override default headers
  final overrideHeaders = {
    'Content-Type': 'application/json;charset=utf-8'
  };

  var handler = const Pipeline()
      // Just add corsHeaders() middleware and pass your origin checker
      .addMiddleware(corsHeaders(headers: overrideHeaders, originChecker: listChecker))
      .addHandler(_requestHandler);

  await serve(handler, 'localhost', 8080);
}

Response _requestHandler(Request request) {
  return Response.ok('Request for "${request.url}"');
}
```
