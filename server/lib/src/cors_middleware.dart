import 'package:shelf/shelf.dart';

const Map<String, String> corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

/// Adds CORS headers to every response and short-circuits the browser's
/// OPTIONS preflight before it reaches the router — otherwise an unmatched
/// OPTIONS request 404s, which breaks only the web build while native
/// builds (which never send a preflight) keep working.
Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }
      final response = await innerHandler(request);
      return response.change(headers: corsHeaders);
    };
  };
}
