import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shelf/shelf.dart';

class Session {
  Session({
    required this.email,
    required this.password,
    required this.imapHost,
    required this.imapPort,
    required this.smtpHost,
    required this.smtpPort,
  })  : createdAt = DateTime.now(),
        lastUsedAt = DateTime.now();

  final String email;
  final String password;
  final String? imapHost;
  final int? imapPort;
  final String? smtpHost;
  final int? smtpPort;
  final DateTime createdAt;
  DateTime lastUsedAt;
}

/// Caches verified mail credentials in memory only (never written to disk),
/// keyed by a random opaque token, so the client never has to persist a
/// password to keep IMAP calls working across a reload/restart.
class SessionStore {
  SessionStore({Duration? idleTimeout})
      : idleTimeout = idleTimeout ?? const Duration(minutes: 60) {
    _sweepTimer = Timer.periodic(const Duration(minutes: 10), (_) => _sweep());
  }

  final Duration idleTimeout;
  final Map<String, Session> _sessions = {};
  final Random _random = Random.secure();
  late final Timer _sweepTimer;

  String create({
    required String email,
    required String password,
    String? imapHost,
    int? imapPort,
    String? smtpHost,
    int? smtpPort,
  }) {
    final tokenBytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final token = base64Url.encode(tokenBytes);
    _sessions[token] = Session(
      email: email,
      password: password,
      imapHost: imapHost,
      imapPort: imapPort,
      smtpHost: smtpHost,
      smtpPort: smtpPort,
    );
    return token;
  }

  Session? lookup(String token) {
    final session = _sessions[token];
    if (session == null) {
      return null;
    }
    if (DateTime.now().difference(session.lastUsedAt) > idleTimeout) {
      _sessions.remove(token);
      return null;
    }
    session.lastUsedAt = DateTime.now();
    return session;
  }

  void revoke(String token) {
    _sessions.remove(token);
  }

  void _sweep() {
    final now = DateTime.now();
    _sessions.removeWhere((_, session) => now.difference(session.lastUsedAt) > idleTimeout);
  }

  void dispose() {
    _sweepTimer.cancel();
  }
}

typedef SessionHandler = FutureOr<Response> Function(Request request, Session session);

/// Wraps a handler so it only runs with a resolved [Session], reading the
/// `Authorization: Bearer <token>` header. Every protected route uses this
/// instead of re-parsing the header itself.
Handler withSession(SessionStore store, SessionHandler handler) {
  return (Request request) async {
    final header = request.headers['authorization'];
    final token = (header != null && header.startsWith('Bearer '))
        ? header.substring('Bearer '.length)
        : null;
    final session = token == null ? null : store.lookup(token);
    if (session == null) {
      return Response(
        401,
        body: jsonEncode({
          'success': false,
          'errorType': 'session_expired',
          'message': 'Your session has expired. Sign in again.',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
    return handler(request, session);
  };
}
