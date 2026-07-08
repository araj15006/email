import 'dart:async';
import 'dart:io';

import 'package:enough_mail/enough_mail.dart';

enum SmtpVerifyErrorType { invalidCredentials, connectionFailed, serverError }

class SmtpVerifyResult {
  const SmtpVerifyResult.success()
      : isSuccess = true,
        errorType = null,
        message = null;

  const SmtpVerifyResult.failure(this.errorType, this.message) : isSuccess = false;

  final bool isSuccess;
  final SmtpVerifyErrorType? errorType;
  final String? message;
}

/// Verifies [email]/[password] by performing a real SMTP AUTH handshake
/// against [host]:[port]. Never persists or logs the password. The
/// connection is discarded immediately after auth succeeds or fails — this
/// never sends mail.
Future<SmtpVerifyResult> verifySmtpCredentials({
  required String host,
  required int port,
  required String email,
  required String password,
}) async {
  final client = SmtpClient('orbit-mail-auth-relay');
  final isSecure = port == 465;

  try {
    await client.connectToServer(
      host,
      port,
      isSecure: isSecure,
      timeout: const Duration(seconds: 10),
    );
  } on SocketException catch (e) {
    return SmtpVerifyResult.failure(
      SmtpVerifyErrorType.connectionFailed,
      'Could not reach $host:$port (${e.osError?.message ?? e.message}).',
    );
  } on TlsException catch (e) {
    return SmtpVerifyResult.failure(
      SmtpVerifyErrorType.connectionFailed,
      'Secure connection to $host:$port failed (${e.message}).',
    );
  } on TimeoutException {
    return SmtpVerifyResult.failure(
      SmtpVerifyErrorType.connectionFailed,
      'Connection to $host:$port timed out.',
    );
  }

  try {
    try {
      await client.ehlo();

      if (!isSecure) {
        if (client.serverInfo.supportsStartTls) {
          await client.startTls();
        } else {
          return SmtpVerifyResult.failure(
            SmtpVerifyErrorType.connectionFailed,
            'Server at $host:$port does not support a secure connection.',
          );
        }
      }
    } on SmtpException catch (e) {
      return SmtpVerifyResult.failure(
        SmtpVerifyErrorType.connectionFailed,
        e.message ?? 'The mail server rejected the connection setup.',
      );
    } on SocketException {
      return SmtpVerifyResult.failure(
        SmtpVerifyErrorType.connectionFailed,
        'Connection to $host:$port was lost during setup.',
      );
    }

    final authMechanism = client.serverInfo.supportsAuth(AuthMechanism.plain)
        ? AuthMechanism.plain
        : client.serverInfo.supportsAuth(AuthMechanism.login)
            ? AuthMechanism.login
            : AuthMechanism.plain;

    try {
      await client.authenticate(email, password, authMechanism);
      return const SmtpVerifyResult.success();
    } on SmtpException {
      return const SmtpVerifyResult.failure(
        SmtpVerifyErrorType.invalidCredentials,
        'The email or password was rejected by the mail server.',
      );
    } on SocketException {
      return SmtpVerifyResult.failure(
        SmtpVerifyErrorType.connectionFailed,
        'Connection to $host:$port was lost during authentication.',
      );
    } on TimeoutException {
      return SmtpVerifyResult.failure(
        SmtpVerifyErrorType.connectionFailed,
        'The mail server did not respond in time.',
      );
    }
  } finally {
    try {
      await client.disconnect();
    } catch (_) {
      // Best-effort cleanup only — the verification result is already decided.
    }
  }
}
