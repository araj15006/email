class SmtpEndpoint {
  const SmtpEndpoint(this.host, this.port);

  final String host;
  final int port;
}

const Map<String, SmtpEndpoint> _domainEndpoints = {
  'gmail.com': SmtpEndpoint('smtp.gmail.com', 587),
  'googlemail.com': SmtpEndpoint('smtp.gmail.com', 587),
  'outlook.com': SmtpEndpoint('smtp.office365.com', 587),
  'hotmail.com': SmtpEndpoint('smtp.office365.com', 587),
  'live.com': SmtpEndpoint('smtp.office365.com', 587),
  'msn.com': SmtpEndpoint('smtp.office365.com', 587),
  'yahoo.com': SmtpEndpoint('smtp.mail.yahoo.com', 587),
  'yahoo.co.uk': SmtpEndpoint('smtp.mail.yahoo.com', 587),
  'ymail.com': SmtpEndpoint('smtp.mail.yahoo.com', 587),
  'rocketmail.com': SmtpEndpoint('smtp.mail.yahoo.com', 587),
  'icloud.com': SmtpEndpoint('smtp.mail.me.com', 587),
  'me.com': SmtpEndpoint('smtp.mail.me.com', 587),
  'mac.com': SmtpEndpoint('smtp.mail.me.com', 587),
};

/// Looks up a well-known SMTP host/port for [email]'s domain, or `null` if
/// the domain isn't recognized and the caller must supply one explicitly.
SmtpEndpoint? detectSmtpEndpoint(String email) {
  final domain = _domainOf(email);
  return domain == null ? null : _domainEndpoints[domain];
}

class ImapEndpoint {
  const ImapEndpoint(this.host, this.port);

  final String host;
  final int port;
}

const Map<String, ImapEndpoint> _domainImapEndpoints = {
  'gmail.com': ImapEndpoint('imap.gmail.com', 993),
  'googlemail.com': ImapEndpoint('imap.gmail.com', 993),
  'outlook.com': ImapEndpoint('outlook.office365.com', 993),
  'hotmail.com': ImapEndpoint('outlook.office365.com', 993),
  'live.com': ImapEndpoint('outlook.office365.com', 993),
  'msn.com': ImapEndpoint('outlook.office365.com', 993),
  'yahoo.com': ImapEndpoint('imap.mail.yahoo.com', 993),
  'yahoo.co.uk': ImapEndpoint('imap.mail.yahoo.com', 993),
  'ymail.com': ImapEndpoint('imap.mail.yahoo.com', 993),
  'rocketmail.com': ImapEndpoint('imap.mail.yahoo.com', 993),
  'icloud.com': ImapEndpoint('imap.mail.me.com', 993),
  'me.com': ImapEndpoint('imap.mail.me.com', 993),
  'mac.com': ImapEndpoint('imap.mail.me.com', 993),
};

/// Looks up a well-known IMAP host/port for [email]'s domain, or `null` if
/// the domain isn't recognized and the caller must supply one explicitly.
ImapEndpoint? detectImapEndpoint(String email) {
  final domain = _domainOf(email);
  return domain == null ? null : _domainImapEndpoints[domain];
}

String? _domainOf(String email) {
  final atIndex = email.lastIndexOf('@');
  if (atIndex == -1 || atIndex == email.length - 1) {
    return null;
  }
  return email.substring(atIndex + 1).toLowerCase();
}
