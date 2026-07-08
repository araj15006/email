import 'dart:convert';
import 'package:enough_mail/enough_mail.dart' hide Response;
import 'package:shelf/shelf.dart';
import 'session_store.dart';

Future<Response> handleSendMail(Request request, Session session) async {
  if (session.smtpHost == null || session.smtpPort == null) {
    return Response(400, body: jsonEncode({
      'success': false,
      'errorType': 'smtp_not_configured',
      'message': 'No SMTP server configured. Cannot send email.',
    }));
  }

  Map<String, dynamic> body;
  try {
    final payload = await request.readAsString();
    body = jsonDecode(payload) as Map<String, dynamic>;
  } catch (_) {
    return Response(400, body: jsonEncode({
      'success': false,
      'errorType': 'invalid_input',
      'message': 'Request body must be valid JSON.',
    }));
  }

  final to = body['to'] as String?;
  final subject = body['subject'] as String?;
  final textBody = body['body'] as String?;
  
  if (to == null || to.isEmpty || textBody == null) {
    return Response(400, body: jsonEncode({
      'success': false,
      'errorType': 'invalid_input',
      'message': 'Missing recipient (to) or body.',
    }));
  }

  final builder = MessageBuilder()
    ..from = [MailAddress(session.email.split('@').first, session.email)]
    ..to = [MailAddress(to.split('@').first, to)]
    ..subject = subject ?? ''
    ..text = textBody;
    
  final mimeMessage = builder.buildMimeMessage();

  final client = SmtpClient('orbit_outlook', isLogEnabled: false);
  try {
    await client.connectToServer(
      session.smtpHost!,
      session.smtpPort!,
      isSecure: session.smtpPort == 465,
    );
    await client.ehlo();
    if (client.serverInfo.supportsStartTls) {
      await client.startTls();
      await client.ehlo();
    }
    await client.authenticate(session.email, session.password);
    await client.sendMessage(mimeMessage);
    
    return Response(200, body: jsonEncode({
      'success': true,
    }));
  } catch (e) {
    return Response(500, body: jsonEncode({
      'success': false,
      'errorType': 'send_failed',
      'message': 'Failed to send email: $e',
    }));
  } finally {
    try {
      await client.disconnect();
    } catch (_) {}
  }
}
