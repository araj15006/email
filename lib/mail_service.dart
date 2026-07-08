import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

enum MailErrorType { sessionExpired, notConfigured, network, notFound, serverError }

class MailboxData {
  const MailboxData({
    required this.path,
    required this.displayName,
    required this.kind,
    required this.unreadCount,
  });

  final String path;
  final String displayName;
  final String kind;
  final int unreadCount;
}

class MessageSummaryData {
  const MessageSummaryData({
    required this.id,
    required this.sender,
    required this.senderEmail,
    required this.subject,
    required this.preview,
    required this.date,
    required this.unread,
    required this.starred,
  });

  final String id;
  final String sender;
  final String senderEmail;
  final String subject;
  final String preview;
  final DateTime? date;
  final bool unread;
  final bool starred;
}

class MessageDetailData {
  const MessageDetailData({
    required this.id,
    required this.sender,
    required this.senderEmail,
    required this.subject,
    required this.date,
    required this.starred,
    required this.bodyText,
  });

  final String id;
  final String sender;
  final String senderEmail;
  final String subject;
  final DateTime? date;
  final bool starred;
  final String bodyText;
}

class MailResult<T> {
  const MailResult.success(this.data)
      : success = true,
        errorType = null,
        message = null;

  const MailResult.failure(this.errorType, this.message)
      : success = false,
        data = null;

  final bool success;
  final T? data;
  final MailErrorType? errorType;
  final String? message;
}

/// Calls the Orbit Mail auth relay's IMAP-backed endpoints (see
/// server/lib/src/mailboxes_handler.dart, messages_handler.dart) using the
/// bearer token issued at sign-in. A `sessionExpired` result is returned as
/// data, not thrown — the caller decides whether to bounce back to login.
class MailService {
  MailService({required this.token, http.Client? client}) : _client = client ?? http.Client();

  final String token;
  final http.Client _client;

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  Future<MailResult<List<MailboxData>>> listMailboxes() async {
    return _get('/api/mailboxes', (body) {
      final mailboxes = (body['mailboxes'] as List<dynamic>)
          .map((m) => MailboxData(
                path: m['path'] as String,
                displayName: m['displayName'] as String,
                kind: m['kind'] as String,
                unreadCount: m['unreadCount'] as int,
              ))
          .toList();
      return mailboxes;
    });
  }

  Future<MailResult<List<MessageSummaryData>>> listMessages({
    required String folder,
    int limit = 30,
  }) async {
    final uri = '/api/messages?folder=${Uri.encodeQueryComponent(folder)}&limit=$limit';
    return _get(uri, (body) {
      final messages = (body['messages'] as List<dynamic>)
          .map((m) => MessageSummaryData(
                id: m['id'] as String,
                sender: m['sender'] as String,
                senderEmail: m['senderEmail'] as String,
                subject: m['subject'] as String,
                preview: m['preview'] as String,
                date: _parseDate(m['date'] as String?),
                unread: m['unread'] as bool,
                starred: m['starred'] as bool,
              ))
          .toList();
      return messages;
    });
  }

  Future<MailResult<MessageDetailData>> getMessage({
    required String folder,
    required String id,
  }) async {
    final uri = '/api/messages/${Uri.encodeComponent(id)}?folder=${Uri.encodeQueryComponent(folder)}';
    return _get(uri, (body) {
      return MessageDetailData(
        id: body['id'] as String,
        sender: body['sender'] as String,
        senderEmail: body['senderEmail'] as String,
        subject: body['subject'] as String,
        date: _parseDate(body['date'] as String?),
        starred: body['starred'] as bool,
        bodyText: body['bodyText'] as String,
      );
    });
  }

  Future<MailResult<bool>> setFlagged({
    required String folder,
    required String id,
    required bool starred,
  }) async {
    final uri = '/api/messages/${Uri.encodeComponent(id)}/flag?folder=${Uri.encodeQueryComponent(folder)}';
    return _send(
      'POST',
      uri,
      body: jsonEncode({'starred': starred}),
      parse: (body) => body['starred'] as bool,
    );
  }

  Future<MailResult<bool>> setRead({
    required String folder,
    required String id,
    required bool unread,
  }) async {
    final uri = '/api/messages/${Uri.encodeComponent(id)}/flag?folder=${Uri.encodeQueryComponent(folder)}';
    return _send(
      'POST',
      uri,
      body: jsonEncode({'unread': unread}),
      parse: (body) => body['unread'] as bool,
    );
  }

  Future<MailResult<bool>> moveMessage({
    required String folder,
    required String id,
    required String targetFolder,
  }) async {
    final uri = '/api/messages/${Uri.encodeComponent(id)}/move?folder=${Uri.encodeQueryComponent(folder)}';
    return _send(
      'POST',
      uri,
      body: jsonEncode({'targetFolder': targetFolder}),
      parse: (body) => body['success'] as bool,
    );
  }

  Future<MailResult<bool>> sendMessage({
    required String to,
    required String subject,
    required String bodyText,
  }) async {
    return _send(
      'POST',
      '/api/send',
      body: jsonEncode({
        'to': to,
        'subject': subject,
        'body': bodyText,
      }),
      parse: (body) => body['success'] as bool,
    );
  }

  Future<MailResult<T>> _get<T>(String path, T Function(Map<String, dynamic>) parse) {
    return _send('GET', path, parse: parse);
  }

  Future<MailResult<T>> _send<T>(
    String method,
    String path, {
    String? body,
    required T Function(Map<String, dynamic>) parse,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {
      'Authorization': 'Bearer $token',
      if (body != null) 'Content-Type': 'application/json',
    };

    http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) {
        request.body = body;
      }
      final streamed = await _client.send(request).timeout(const Duration(seconds: 45));
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      return const MailResult.failure(
        MailErrorType.network,
        'The mail service took too long to respond. Try again.',
      );
    } on http.ClientException {
      return const MailResult.failure(
        MailErrorType.network,
        "Couldn't reach the mail service. Check your connection and try again.",
      );
    }

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode == 200 && decoded?['success'] == true) {
      try {
        return MailResult.success(parse(decoded!));
      } catch (_) {
        return const MailResult.failure(
          MailErrorType.serverError,
          'Received an unexpected response from the mail service.',
        );
      }
    }

    return MailResult.failure(
      _parseErrorType(decoded?['errorType'] as String?),
      decoded?['message'] as String? ?? 'Request failed (HTTP ${response.statusCode}).',
    );
  }

  MailErrorType _parseErrorType(String? wireValue) {
    switch (wireValue) {
      case 'session_expired':
      case 'imap_auth_failed':
        return MailErrorType.sessionExpired;
      case 'imap_not_configured':
        return MailErrorType.notConfigured;
      case 'connection_failed':
        return MailErrorType.network;
      case 'not_found':
        return MailErrorType.notFound;
      default:
        return MailErrorType.serverError;
    }
  }

  DateTime? _parseDate(String? iso) {
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }
}
