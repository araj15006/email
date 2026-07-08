import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum AuthErrorType {
  invalidInput,
  invalidCredentials,
  unknownProvider,
  network,
  serverError,
}

class SignInResult {
  const SignInResult.success(this.email, this.token, {this.imapStatus, this.imapWarning})
      : success = true,
        errorType = null,
        message = null;

  const SignInResult.failure(this.errorType, this.message)
      : success = false,
        email = null,
        token = null,
        imapStatus = null,
        imapWarning = null;

  final bool success;
  final String? email;
  final String? token;
  final String? imapStatus;
  final String? imapWarning;
  final AuthErrorType? errorType;
  final String? message;
}

/// A restored session: only ever the email + an opaque session token. The
/// password is never persisted client-side — the backend caches it in
/// memory (see server/lib/src/session_store.dart) so IMAP calls can keep
/// working without the client holding the secret in any form of storage.
typedef RestoredSession = (String email, String token);

/// Talks to the Orbit Mail auth relay (see the `server/` package) to verify
/// SMTP credentials over HTTP, since a browser can never speak SMTP
/// directly. The same service is used on web, Windows, and Android so all
/// three platforms share one authentication code path.
class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String _emailKey = 'orbit_mail_signed_in_email';
  static const String _tokenKey = 'orbit_mail_session_token';

  Future<SignInResult> signIn({
    required String email,
    required String password,
    String? smtpHost,
    int? smtpPort,
    String? imapHost,
    int? imapPort,
  }) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              if (smtpHost != null) 'smtpHost': smtpHost,
              if (smtpPort != null) 'smtpPort': smtpPort,
              if (imapHost != null) 'imapHost': imapHost,
              if (imapPort != null) 'imapPort': imapPort,
            }),
          )
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      return const SignInResult.failure(
        AuthErrorType.network,
        'The sign-in service took too long to respond. Try again.',
      );
    } on http.ClientException {
      return const SignInResult.failure(
        AuthErrorType.network,
        "Couldn't reach the sign-in service. Check your connection and try again.",
      );
    }

    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }

    if (response.statusCode == 200 && body?['success'] == true) {
      final signedInEmail = body?['email'] as String? ?? email;
      final token = body?['token'] as String?;
      if (token == null) {
        return const SignInResult.failure(
          AuthErrorType.serverError,
          'Sign-in succeeded but no session was returned. Try again.',
        );
      }
      await _persistSession(signedInEmail, token);
      return SignInResult.success(
        signedInEmail,
        token,
        imapStatus: body?['imapStatus'] as String?,
        imapWarning: body?['imapWarning'] as String?,
      );
    }

    final errorType = _parseErrorType(body?['errorType'] as String?);
    final message = body?['message'] as String? ??
        'Sign-in failed (HTTP ${response.statusCode}). Try again.';
    return SignInResult.failure(errorType, message);
  }

  Future<RestoredSession?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    final token = prefs.getString(_tokenKey);
    if (email == null || token == null) {
      return null;
    }
    return (email, token);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      try {
        await _client
            .post(
              Uri.parse('$_baseUrl/api/logout'),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Local sign-out must always succeed even if the network call fails.
      }
    }
    await prefs.remove(_emailKey);
    await prefs.remove(_tokenKey);
  }

  Future<void> _persistSession(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_tokenKey, token);
  }

  AuthErrorType _parseErrorType(String? wireValue) {
    switch (wireValue) {
      case 'invalid_credentials':
        return AuthErrorType.invalidCredentials;
      case 'unknown_provider':
        return AuthErrorType.unknownProvider;
      case 'invalid_input':
        return AuthErrorType.invalidInput;
      case 'connection_failed':
        return AuthErrorType.network;
      default:
        return AuthErrorType.serverError;
    }
  }
}
