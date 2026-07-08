import 'dart:io';

import 'package:outlook_auth_server/src/cors_middleware.dart';
import 'package:outlook_auth_server/src/login_handler.dart';
import 'package:outlook_auth_server/src/logout_handler.dart';
import 'package:outlook_auth_server/src/mailboxes_handler.dart';
import 'package:outlook_auth_server/src/send_handler.dart';
import 'package:outlook_auth_server/src/messages_handler.dart';
import 'package:outlook_auth_server/src/session_store.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  final sessionStore = SessionStore();

  final router = Router()
    ..post('/api/login', loginHandler(sessionStore))
    ..post('/api/logout', logoutHandler(sessionStore))
    ..post('/api/send', withSession(sessionStore, handleSendMail))
    ..get('/api/mailboxes', withSession(sessionStore, handleListMailboxes))
    ..get('/api/messages', withSession(sessionStore, handleListMessages))
    ..get('/api/messages/<id>', withSession(sessionStore, handleGetMessage))
    ..post('/api/messages/<id>/move', withSession(sessionStore, handleMoveMessage))
    ..post('/api/messages/<id>/flag', withSession(sessionStore, handleSetFlag));

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router.call);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('Orbit Mail auth relay listening on http://${server.address.host}:${server.port}');
}
