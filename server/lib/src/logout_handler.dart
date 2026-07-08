import 'package:shelf/shelf.dart';

import 'mail_error_response.dart';
import 'session_store.dart';

/// Not wrapped in [withSession] deliberately: sign-out must always succeed
/// locally even if the token is already missing/expired/garbage.
Handler logoutHandler(SessionStore sessionStore) {
  return (Request request) async {
    final header = request.headers['authorization'];
    final token = (header != null && header.startsWith('Bearer '))
        ? header.substring('Bearer '.length)
        : null;
    if (token != null) {
      sessionStore.revoke(token);
    }
    return jsonResponse(200, {'success': true});
  };
}
