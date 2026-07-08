import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'imap_service.dart';

Response jsonResponse(int status, Map<String, dynamic> body) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {'Content-Type': 'application/json'},
  );
}

Response mailFetchErrorResponse(MailFetchException e) {
  return jsonResponse(_statusFor(e.errorType), {
    'success': false,
    'errorType': _wireErrorType(e.errorType),
    'message': e.message,
  });
}

int _statusFor(MailFetchErrorType type) => switch (type) {
      MailFetchErrorType.connectionFailed => 502,
      MailFetchErrorType.imapAuthFailed => 401,
      MailFetchErrorType.notConfigured => 400,
      MailFetchErrorType.notFound => 404,
      MailFetchErrorType.serverError => 500,
    };

String _wireErrorType(MailFetchErrorType type) => switch (type) {
      MailFetchErrorType.connectionFailed => 'connection_failed',
      MailFetchErrorType.imapAuthFailed => 'imap_auth_failed',
      MailFetchErrorType.notConfigured => 'imap_not_configured',
      MailFetchErrorType.notFound => 'not_found',
      MailFetchErrorType.serverError => 'server_error',
    };
