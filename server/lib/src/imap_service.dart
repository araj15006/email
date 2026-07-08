import 'dart:async';
import 'dart:io';

import 'package:enough_mail/enough_mail.dart';

import 'session_store.dart';

enum MailFetchErrorType {
  connectionFailed,
  imapAuthFailed,
  notConfigured,
  notFound,
  serverError,
}

class MailFetchException implements Exception {
  MailFetchException(this.errorType, this.message);

  final MailFetchErrorType errorType;
  final String message;

  @override
  String toString() => 'MailFetchException($errorType, $message)';
}

class MailboxSummary {
  const MailboxSummary({
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

class MessageSummary {
  const MessageSummary({
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

class MessageDetail {
  const MessageDetail({
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

/// Verifies IMAP credentials by connecting, logging in, and immediately
/// logging out — used only as a best-effort probe during login, never
/// persists or logs the password.
Future<void> verifyImapCredentials({
  required String host,
  required int port,
  required String email,
  required String password,
}) async {
  final client = ImapClient(isLogEnabled: false);
  try {
    await client.connectToServer(
      host,
      port,
      isSecure: port == 993,
      timeout: const Duration(seconds: 10),
    );
    if (port != 993) {
      await client.capability();
      if (client.serverInfo.supportsStartTls) {
        await client.startTls();
      }
    }
    await client.login(email, password);
  } finally {
    try {
      await client.logout();
    } catch (_) {
      // best-effort cleanup
    }
    try {
      await client.disconnect();
    } catch (_) {
      // best-effort cleanup
    }
  }
}

Future<T> _withImapConnection<T>({
  required Session session,
  required Future<T> Function(ImapClient client) action,
}) async {
  final host = session.imapHost;
  final port = session.imapPort;
  if (host == null || port == null) {
    throw MailFetchException(
      MailFetchErrorType.notConfigured,
      'No IMAP server is configured for this account. Sign in again with IMAP settings filled in.',
    );
  }

  final client = ImapClient(isLogEnabled: false);
  try {
    try {
      await client.connectToServer(
        host,
        port,
        isSecure: port == 993,
        timeout: const Duration(seconds: 10),
      );
      if (port != 993) {
        await client.capability();
        if (client.serverInfo.supportsStartTls) {
          await client.startTls();
        }
      }
    } on SocketException catch (e) {
      throw MailFetchException(
        MailFetchErrorType.connectionFailed,
        'Could not reach $host:$port (${e.osError?.message ?? e.message}).',
      );
    } on TlsException catch (e) {
      throw MailFetchException(
        MailFetchErrorType.connectionFailed,
        'Secure connection to $host:$port failed (${e.message}).',
      );
    } on TimeoutException {
      throw MailFetchException(
        MailFetchErrorType.connectionFailed,
        'Connection to $host:$port timed out.',
      );
    }

    try {
      await client.login(session.email, session.password);
    } on ImapException {
      throw MailFetchException(
        MailFetchErrorType.imapAuthFailed,
        'The mail server rejected the stored credentials. Sign in again.',
      );
    }

    return await action(client);
  } finally {
    try {
      await client.logout();
    } catch (_) {
      // best-effort cleanup
    }
    try {
      await client.disconnect();
    } catch (_) {
      // best-effort cleanup
    }
  }
}

String _kindOf(Mailbox mailbox) {
  if (mailbox.isInbox) return 'inbox';
  if (mailbox.isSent) return 'sent';
  if (mailbox.isDrafts) return 'drafts';
  if (mailbox.isJunk) return 'junk';
  if (mailbox.isTrash) return 'trash';
  if (mailbox.isArchive) return 'archive';
  return 'other';
}

Future<List<MailboxSummary>> listMailboxes(Session session) {
  return _withImapConnection(
    session: session,
    action: (client) async {
      final mailboxes = await client.listMailboxes(recursive: true);
      return mailboxes
          .map(
            (mailbox) => MailboxSummary(
              path: mailbox.path,
              displayName: mailbox.name,
              kind: _kindOf(mailbox),
              unreadCount: mailbox.messagesUnseen,
            ),
          )
          .toList();
    },
  );
}

String _senderName(MimeMessage message) {
  final from = message.from;
  if (from == null || from.isEmpty) return 'Unknown sender';
  final address = from.first;
  return (address.personalName?.isNotEmpty ?? false) ? address.personalName! : address.email;
}

String _senderEmail(MimeMessage message) {
  final from = message.from;
  return (from == null || from.isEmpty) ? '' : from.first.email;
}

String _previewOf(MimeMessage message, String subject) {
  final plain = message.decodeTextPlainPart();
  final source = (plain != null && plain.trim().isNotEmpty) ? plain : _stripHtml(message.decodeTextHtmlPart() ?? '');
  final normalized = source.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) return subject;
  return normalized.length > 140 ? '${normalized.substring(0, 140)}…' : normalized;
}

/// Strips HTML tags and decodes a handful of common entities. Good enough
/// for a plain-text preview/body fallback — not a sanitizer or renderer.
String _stripHtml(String html) {
  // Replace block-level tags and breaks with newlines to preserve paragraph structure
  var text = html.replaceAll(RegExp(r'<(br|/?p|/?div|/?h\d|/?li|/?tr)[^>]*>', caseSensitive: false), '\n');
  // Strip remaining tags
  text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
  // Decode common HTML entities
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
  // Clean up excessive whitespace while preserving newlines
  return text
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n[ \t]+\n'), '\n\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

Future<List<MessageSummary>> listMessages(
  Session session,
  String folderPath, {
  int limit = 30,
}) {
  return _withImapConnection(
    session: session,
    action: (client) async {
      final box = await client.selectMailboxByPath(folderPath);
      final exists = box.messagesExists;
      if (exists == 0) {
        return const [];
      }
      final lower = exists - limit + 1 < 1 ? 1 : exists - limit + 1;
      final sequence = MessageSequence.fromRange(lower, exists);
      final result = await client.fetchMessages(sequence, '(UID FLAGS ENVELOPE BODY.PEEK[])');
      final messages = result.messages;
      return messages.reversed.map((message) {
        final subject = message.decodeSubject() ?? '(No subject)';
        return MessageSummary(
          id: '${message.uid}',
          sender: _senderName(message),
          senderEmail: _senderEmail(message),
          subject: subject,
          preview: _previewOf(message, subject),
          date: message.decodeDate(),
          unread: !message.isSeen,
          starred: message.isFlagged,
        );
      }).toList();
    },
  );
}

Future<MessageDetail> getMessage(Session session, String folderPath, int uid) {
  return _withImapConnection(
    session: session,
    action: (client) async {
      await client.selectMailboxByPath(folderPath);
      final result = await client.uidFetchMessage(uid, 'BODY[]');
      if (result.messages.isEmpty) {
        throw MailFetchException(MailFetchErrorType.notFound, 'Message not found.');
      }
      final message = result.messages.first;
      final subject = message.decodeSubject() ?? '(No subject)';
      final plain = message.decodeTextPlainPart();
      final bodyText = (plain != null && plain.trim().isNotEmpty)
          ? plain.trim()
          : _stripHtml(message.decodeTextHtmlPart() ?? '').trim();
      return MessageDetail(
        id: '${message.uid}',
        sender: _senderName(message),
        senderEmail: _senderEmail(message),
        subject: subject,
        date: message.decodeDate(),
        starred: message.isFlagged,
        bodyText: bodyText.isEmpty ? '(No content)' : bodyText,
      );
    },
  );
}

Future<void> setFlagged(
  Session session,
  String folderPath,
  int uid, {
  bool? starred,
  bool? unread,
}) {
  return _withImapConnection(
    session: session,
    action: (client) async {
      await client.selectMailboxByPath(folderPath);
      final sequence = MessageSequence.fromId(uid, isUid: true);
      if (starred != null) {
        if (starred) {
          await client.uidMarkFlagged(sequence);
        } else {
          await client.uidMarkUnflagged(sequence);
        }
      }
      if (unread != null) {
        if (unread) {
          await client.uidMarkUnseen(sequence);
        } else {
          await client.uidMarkSeen(sequence);
        }
      }
    },
  );
}

Future<void> moveMessage(
  Session session,
  String folderPath,
  int uid,
  String targetFolderPath,
) {
  return _withImapConnection(
    session: session,
    action: (client) async {
      await client.selectMailboxByPath(folderPath);
      final sequence = MessageSequence.fromId(uid, isUid: true);
      await client.selectMailboxByPath(targetFolderPath);
      await client.selectMailboxByPath(folderPath);
      if (client.serverInfo.supportsMove) {
        await client.uidMove(sequence, targetMailboxPath: targetFolderPath);
      } else {
        await client.uidCopy(sequence, targetMailboxPath: targetFolderPath);
        await client.uidMarkDeleted(sequence);
        await client.expunge();
      }
    },
  );
}
