import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'imap_service.dart';
import 'mail_error_response.dart';
import 'session_store.dart';

Future<Response> handleListMessages(Request request, Session session) async {
  final folder = request.url.queryParameters['folder'];
  if (folder == null || folder.isEmpty) {
    return jsonResponse(400, {
      'success': false,
      'errorType': 'invalid_input',
      'message': 'A folder query parameter is required.',
    });
  }
  final limit = int.tryParse(request.url.queryParameters['limit'] ?? '') ?? 30;

  try {
    final messages = await listMessages(session, folder, limit: limit);
    return jsonResponse(200, {
      'success': true,
      'folder': folder,
      'messages': messages
          .map((m) => {
                'id': m.id,
                'sender': m.sender,
                'senderEmail': m.senderEmail,
                'subject': m.subject,
                'preview': m.preview,
                'date': m.date?.toIso8601String(),
                'unread': m.unread,
                'starred': m.starred,
              })
          .toList(),
    });
  } on MailFetchException catch (e) {
    return mailFetchErrorResponse(e);
  } catch (_) {
    return jsonResponse(500, {
      'success': false,
      'errorType': 'server_error',
      'message': 'Unexpected error while loading messages.',
    });
  }
}

Future<Response> handleGetMessage(Request request, Session session) async {
  final folder = request.url.queryParameters['folder'];
  final uid = int.tryParse(request.params['id'] ?? '');
  if (folder == null || folder.isEmpty || uid == null) {
    return jsonResponse(400, {
      'success': false,
      'errorType': 'invalid_input',
      'message': 'A folder query parameter and a numeric message id are required.',
    });
  }

  try {
    final message = await getMessage(session, folder, uid);
    return jsonResponse(200, {
      'success': true,
      'id': message.id,
      'sender': message.sender,
      'senderEmail': message.senderEmail,
      'subject': message.subject,
      'date': message.date?.toIso8601String(),
      'starred': message.starred,
      'bodyText': message.bodyText,
    });
  } on MailFetchException catch (e) {
    return mailFetchErrorResponse(e);
  } catch (_) {
    return jsonResponse(500, {
      'success': false,
      'errorType': 'server_error',
      'message': 'Unexpected error while loading the message.',
    });
  }
}

Future<Response> handleSetFlag(Request request, Session session) async {
  final folder = request.url.queryParameters['folder'];
  final uid = int.tryParse(request.params['id'] ?? '');
  if (folder == null || folder.isEmpty || uid == null) {
    return jsonResponse(400, {
      'success': false,
      'errorType': 'invalid_input',
      'message': 'A folder query parameter and a numeric message id are required.',
    });
  }

  bool? starred;
  bool? unread;
  try {
    final payload = await request.readAsString();
    final body = jsonDecode(payload) as Map<String, dynamic>;
    if (body.containsKey('starred')) starred = body['starred'] == true;
    if (body.containsKey('unread')) unread = body['unread'] == true;
  } catch (_) {
    return jsonResponse(400, {
      'success': false,
      'errorType': 'invalid_input',
      'message': 'Request body must be valid JSON with a boolean "starred" field.',
    });
  }

  try {
    await setFlagged(session, folder, uid, starred: starred, unread: unread);
    return jsonResponse(200, {'success': true, 'starred': starred, 'unread': unread});
  } on MailFetchException catch (e) {
    return mailFetchErrorResponse(e);
  } catch (_) {
    return jsonResponse(500, {
      'success': false,
      'errorType': 'server_error',
      'message': 'Unexpected error while updating the message.',
    });
  }
}

Future<Response> handleMoveMessage(Request request, Session session) async {
  final folder = request.url.queryParameters['folder'];
  final uid = int.tryParse(request.params['id'] ?? '');
  if (folder == null || folder.isEmpty || uid == null) {
    return jsonResponse(400, {
      'success': false,
      'errorType': 'invalid_input',
      'message': 'A folder query parameter and a numeric message id are required.',
    });
  }

  String targetFolder;
  try {
    final payload = await request.readAsString();
    final body = jsonDecode(payload) as Map<String, dynamic>;
    targetFolder = body['targetFolder'] as String? ?? '';
    if (targetFolder.isEmpty) throw Exception();
  } catch (_) {
    return jsonResponse(400, {
      'success': false,
      'errorType': 'invalid_input',
      'message': 'Request body must be valid JSON with a "targetFolder" string.',
    });
  }

  try {
    await moveMessage(session, folder, uid, targetFolder);
    return jsonResponse(200, {'success': true});
  } on MailFetchException catch (e) {
    return mailFetchErrorResponse(e);
  } catch (_) {
    return jsonResponse(500, {
      'success': false,
      'errorType': 'server_error',
      'message': 'Unexpected error while moving the message.',
    });
  }
}
