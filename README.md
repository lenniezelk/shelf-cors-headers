# CORS headers middleware for Shelf

A Shelf middleware to add [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) headers to shelf responses.

## Features

- Handles preflight requests.
- Allows override of default headers

## Usage

A simple usage example:

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

void main() async {
  final overrideHeaders = {
    ACCESS_CONTROL_ALLOW_ORIGIN: 'example.com',
    'Content-Type': 'application/json;charset=utf-8'
  };

  var handler = const Pipeline()
      .addMiddleware(corsHeaders(headers: overrideHeaders))
      .addHandler(_echoRequest);

  var server = await serve(handler, 'localhost', 8080);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Response _echoRequest(Request request) {
  return Response.ok('Request for "${request.url}"');
}

```
