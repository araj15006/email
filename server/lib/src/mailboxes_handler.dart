import 'package:shelf/shelf.dart';

import 'imap_service.dart';
import 'mail_error_response.dart';
import 'session_store.dart';

Future<Response> handleListMailboxes(Request request, Session session) async {
  try {
    final mailboxes = await listMailboxes(session);
    return jsonResponse(200, {
      'success': true,
      'mailboxes': mailboxes
          .map((m) => {
                'path': m.path,
                'displayName': m.displayName,
                'kind': m.kind,
                'unreadCount': m.unreadCount,
              })
          .toList(),
    });
  } on MailFetchException catch (e) {
    return mailFetchErrorResponse(e);
  } catch (_) {
    return jsonResponse(500, {
      'success': false,
      'errorType': 'server_error',
      'message': 'Unexpected error while loading mailboxes.',
    });
  }
}
