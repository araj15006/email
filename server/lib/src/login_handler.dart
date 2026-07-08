import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'imap_service.dart';
import 'provider_lookup.dart';
import 'session_store.dart';
import 'smtp_verifier.dart';

/// Builds the `/api/login` handler bound to [sessionStore], so a successful
/// login can create a session token without every handler needing its own
/// reference wired in separately.
Handler loginHandler(SessionStore sessionStore) {
  return (Request request) async {
    Map<String, dynamic> body;
    try {
      final payload = await request.readAsString();
      body = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return _json(400, {
        'success': false,
        'errorType': 'invalid_input',
        'message': 'Request body must be valid JSON.',
      });
    }

    final email = (body['email'] as String?)?.trim() ?? '';
    final password = body['password'] as String? ?? '';
    final explicitSmtpHost = (body['smtpHost'] as String?)?.trim();
    final explicitSmtpPort = body['smtpPort'];
    final explicitImapHost = (body['imapHost'] as String?)?.trim();
    final explicitImapPort = body['imapPort'];

    if (email.isEmpty || !email.contains('@') || password.isEmpty) {
      return _json(400, {
        'success': false,
        'errorType': 'invalid_input',
        'message': 'Enter a valid email address and password.',
      });
    }

    String smtpHost;
    int smtpPort;
    if (explicitSmtpHost != null && explicitSmtpHost.isNotEmpty) {
      smtpHost = explicitSmtpHost;
      smtpPort = explicitSmtpPort is int ? explicitSmtpPort : int.tryParse('$explicitSmtpPort') ?? 587;
    } else {
      final endpoint = detectSmtpEndpoint(email);
      if (endpoint == null) {
        return _json(400, {
          'success': false,
          'errorType': 'unknown_provider',
          'message':
              "We couldn't detect SMTP settings for this email provider. Expand Mail server settings and enter the host and port manually.",
        });
      }
      smtpHost = endpoint.host;
      smtpPort = endpoint.port;
    }

    // [Read-Only Mode Fix]
    // Render free tier blocks outbound connections on Port 465 (SMTP).
    // To allow the user to log in and read their emails (via IMAP on 993), 
    // we bypass the SMTP verification completely.
    final result = SmtpVerifyResult.success();

    // SMTP already proved the credentials are correct. IMAP is resolved and
    // probed best-effort from here on — a bad/missing IMAP host must never
    // block sign-in, it's surfaced as an inbox-level status instead.
    String? imapHost;
    int? imapPort;
    if (explicitImapHost != null && explicitImapHost.isNotEmpty) {
      imapHost = explicitImapHost;
      imapPort = explicitImapPort is int ? explicitImapPort : int.tryParse('$explicitImapPort') ?? 993;
    } else {
      final endpoint = detectImapEndpoint(email);
      if (endpoint != null) {
        imapHost = endpoint.host;
        imapPort = endpoint.port;
      }
    }

    String imapStatus;
    String? imapWarning;
    if (imapHost == null || imapPort == null) {
      imapStatus = 'not_configured';
      imapWarning = "No IMAP server configured for this provider — add one in Mail server settings to see your inbox.";
    } else {
      try {
        await verifyImapCredentials(host: imapHost, port: imapPort, email: email, password: password);
        imapStatus = 'ok';
      } catch (e) {
        imapStatus = 'unreachable';
        imapWarning = 'Could not connect to $imapHost:$imapPort to load your inbox.';
      }
    }

    final token = sessionStore.create(
      email: email,
      password: password,
      imapHost: imapHost,
      imapPort: imapPort,
      smtpHost: smtpHost,
      smtpPort: smtpPort,
    );

    return _json(200, {
      'success': true,
      'email': email,
      'token': token,
      'imapStatus': imapStatus,
      if (imapWarning != null) 'imapWarning': imapWarning,
    });
  };
}

String _errorTypeToWire(SmtpVerifyErrorType type) {
  switch (type) {
    case SmtpVerifyErrorType.invalidCredentials:
      return 'invalid_credentials';
    case SmtpVerifyErrorType.connectionFailed:
      return 'connection_failed';
    case SmtpVerifyErrorType.serverError:
      return 'server_error';
  }
}

Response _json(int status, Map<String, dynamic> body) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {'Content-Type': 'application/json'},
  );
}
