import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'mail_service.dart';

void main() {
  runApp(const MailApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM THEME SYSTEM — LIGHT & DARK
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  const AppColors._({
    required this.canvas,
    required this.surface,
    required this.surfaceAlt,
    required this.pane,
    required this.menuBar,
    required this.navRail,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.selectedBg,
    required this.hoverBg,
    required this.groupHeaderBg,
    required this.cardShadow,
    required this.accentGlow,
    required this.inputFill,
    required this.loginCard,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceAlt;
  final Color pane;
  final Color menuBar;
  final Color navRail;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color selectedBg;
  final Color hoverBg;
  final Color groupHeaderBg;
  final Color cardShadow;
  final Color accentGlow;
  final Color inputFill;
  final Color loginCard;

  // ── Shared accent colours ──
  static const accent = Color(0xFF3B82F6);
  static const accentLight = Color(0xFF60A5FA);
  static const accentDark = Color(0xFF2563EB);
  static const teal = Color(0xFF06B6D4);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);

  static const accentGradient = LinearGradient(
    colors: [accent, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  // ── LIGHT PALETTE — clean, airy, slate-tinted ──
  static const light = AppColors._(
    canvas: Color(0xFFF1F5F9),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF8FAFC),
    pane: Color(0xFFF8FAFC),
    menuBar: Color(0xFFFFFFFF),
    navRail: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textTertiary: Color(0xFF94A3B8),
    selectedBg: Color(0xFFEFF6FF),
    hoverBg: Color(0xFFF1F5F9),
    groupHeaderBg: Color(0xFFF8FAFC),
    cardShadow: Color(0x18000000),
    accentGlow: Color(0x1A3B82F6),
    inputFill: Color(0xFFF8FAFC),
    loginCard: Color(0xFFFFFFFF),
  );

  // ── DARK PALETTE — deep navy, premium, no boring grays ──
  static const dark = AppColors._(
    canvas: Color(0xFF0B0F1A),
    surface: Color(0xFF111827),
    surfaceAlt: Color(0xFF1E293B),
    pane: Color(0xFF0F172A),
    menuBar: Color(0xFF111827),
    navRail: Color(0xFF0F172A),
    border: Color(0xFF1E293B),
    divider: Color(0xFF1E293B),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    selectedBg: Color(0xFF1E3A5F),
    hoverBg: Color(0xFF1E293B),
    groupHeaderBg: Color(0xFF0F172A),
    cardShadow: Color(0x40000000),
    accentGlow: Color(0x333B82F6),
    inputFill: Color(0xFF1E293B),
    loginCard: Color(0xFF111827),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────────────────────────────────────

class MailApp extends StatefulWidget {
  const MailApp({super.key});

  @override
  State<MailApp> createState() => _MailAppState();
}

class _MailAppState extends State<MailApp> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isSignedIn = false;
  String _signedInEmail = '';
  String _sessionToken = '';
  ThemeMode _themeMode = ThemeMode.dark;

  bool get _isDark => _themeMode == ThemeMode.dark;
  void _toggleTheme() {
    setState(() {
      _themeMode = _isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await _authService.restoreSession();
    if (!mounted) return;
    setState(() {
      _isSignedIn = session != null;
      _signedInEmail = session?.$1 ?? '';
      _sessionToken = session?.$2 ?? '';
      _isLoading = false;
    });
  }

  void _handleSignedIn(String email, String token) {
    setState(() {
      _isSignedIn = true;
      _signedInEmail = email;
      _sessionToken = token;
    });
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
    if (!mounted) return;
    setState(() {
      _isSignedIn = false;
      _signedInEmail = '';
      _sessionToken = '';
    });
  }

  ThemeData _buildTheme(Brightness brightness) {
    final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: brightness,
        surface: c.surface,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: c.canvas,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: c.textSecondary),
        hintStyle: TextStyle(color: c.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (_isLoading) {
      home = const SplashPage();
    } else if (_isSignedIn) {
      home = MailHomePage(
        signedInEmail: _signedInEmail,
        sessionToken: _sessionToken,
        onSignOut: _handleSignOut,
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      );
    } else {
      home = LoginPage(
        onSignedIn: _handleSignedIn,
        authService: _authService,
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orbit Mail',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: home,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPLASH
// ─────────────────────────────────────────────────────────────────────────────

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.canvas,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2.5),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED THEME TOGGLE
// ─────────────────────────────────────────────────────────────────────────────

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.isDark, required this.onToggle});

  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        width: 52,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: isDark
              ? const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)])
              : const LinearGradient(colors: [Color(0xFFBFDBFE), Color(0xFFFDE68A)]),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x403B82F6) : const Color(0x40F59E0B),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Stars (dark mode)
            if (isDark) ...[
              const Positioned(left: 8, top: 5, child: _Star(size: 3)),
              const Positioned(left: 14, top: 10, child: _Star(size: 2)),
              const Positioned(left: 10, top: 16, child: _Star(size: 2.5)),
            ],
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              left: isDark ? 27 : 3,
              top: 3,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? const Color(0x403B82F6) : const Color(0x40F59E0B),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 12,
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xCCFFFFFF)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN PAGE
// ─────────────────────────────────────────────────────────────────────────────

enum EmailProviderPreset {
  autoDetect('Auto-detect (Gmail, Outlook, Yahoo, iCloud)', null, null, null, null),
  gmail('Gmail', 'imap.gmail.com', 993, 'smtp.gmail.com', 587),
  outlook('Outlook / Hotmail / Live', 'outlook.office365.com', 993, 'smtp.office365.com', 587),
  yahoo('Yahoo', 'imap.mail.yahoo.com', 993, 'smtp.mail.yahoo.com', 587),
  icloud('iCloud', 'imap.mail.me.com', 993, 'smtp.mail.me.com', 587),
  hostinger('Hostinger', 'imap.hostinger.com', 993, 'smtp.hostinger.com', 465),
  other('Other (enter manually)', null, null, null, null);

  const EmailProviderPreset(this.label, this.imapHost, this.imapPort, this.smtpHost, this.smtpPort);

  final String label;
  final String? imapHost;
  final int? imapPort;
  final String? smtpHost;
  final int? smtpPort;
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onSignedIn,
    required this.authService,
    required this.isDark,
    required this.onToggleTheme,
  });

  final void Function(String email, String token) onSignedIn;
  final AuthService authService;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _smtpHostController = TextEditingController();
  final TextEditingController _smtpPortController = TextEditingController(text: '587');
  final TextEditingController _imapHostController = TextEditingController();
  final TextEditingController _imapPortController = TextEditingController(text: '993');
  final ExpansibleController _serverSettingsController = ExpansibleController();
  EmailProviderPreset _selectedProvider = EmailProviderPreset.autoDetect;
  bool _isSigningIn = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _smtpHostController.dispose();
    _smtpPortController.dispose();
    _imapHostController.dispose();
    _imapPortController.dispose();
    super.dispose();
  }

  void _onProviderSelected(EmailProviderPreset? preset) {
    if (preset == null) return;
    setState(() {
      _selectedProvider = preset;
      if (preset.imapHost != null) {
        _imapHostController.text = preset.imapHost!;
        _imapPortController.text = '${preset.imapPort}';
        _smtpHostController.text = preset.smtpHost!;
        _smtpPortController.text = '${preset.smtpPort}';
      } else {
        _imapHostController.clear();
        _smtpHostController.clear();
      }
    });
    if (preset.imapHost != null && !_serverSettingsController.isExpanded) {
      _serverSettingsController.expand();
    }
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final smtpHost = _smtpHostController.text.trim();
    final smtpPort = _smtpPortController.text.trim();
    final imapHostInput = _imapHostController.text.trim();
    final imapPortInput = _imapPortController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Enter your email password.');
      return;
    }
    if (smtpHost.isNotEmpty && smtpPort.isNotEmpty && int.tryParse(smtpPort) == null) {
      setState(() => _errorMessage = 'SMTP port must be a number.');
      return;
    }
    if (imapHostInput.isNotEmpty && imapPortInput.isNotEmpty && int.tryParse(imapPortInput) == null) {
      setState(() => _errorMessage = 'IMAP port must be a number.');
      return;
    }

    setState(() { _errorMessage = null; _isSigningIn = true; });

    String? imapHost = imapHostInput.isEmpty ? null : imapHostInput;
    int? imapPort = imapPortInput.isEmpty ? null : int.tryParse(imapPortInput);
    if (imapHost == null && smtpHost.startsWith('smtp.')) {
      imapHost = smtpHost.replaceFirst('smtp.', 'imap.');
      imapPort ??= 993;
    }

    final result = await widget.authService.signIn(
      email: email,
      password: password,
      smtpHost: smtpHost.isEmpty ? null : smtpHost,
      smtpPort: smtpPort.isEmpty ? null : int.tryParse(smtpPort),
      imapHost: imapHost,
      imapPort: imapPort,
    );

    if (!mounted) return;
    setState(() => _isSigningIn = false);

    if (result.success) {
      widget.onSignedIn(result.email!, result.token!);
    } else {
      setState(() => _errorMessage = result.message ?? 'Sign-in failed. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.canvas,
      body: Stack(
        children: [
          // ── Gradient background circles ──
          Positioned(top: -120, right: -80, child: _GlowCircle(color: AppColors.accent, size: 300)),
          Positioned(bottom: -100, left: -60, child: _GlowCircle(color: AppColors.teal, size: 250)),
          // ── Theme toggle ──
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(child: ThemeToggleButton(isDark: widget.isDark, onToggle: widget.onToggleTheme)),
          ),
          // ── Login form ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: c.loginCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.border),
                      boxShadow: [
                        BoxShadow(color: c.cardShadow, blurRadius: 40, offset: const Offset(0, 12)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BrandHeader(),
                        const SizedBox(height: 28),
                        Text(
                          'Welcome back',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: c.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to access your inbox',
                          style: TextStyle(color: c.textSecondary, height: 1.5, fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        ComposerField(controller: _emailController, label: 'Email address', icon: Icons.email_outlined),
                        const SizedBox(height: 14),
                        ComposerField(controller: _passwordController, label: 'Password', obscureText: true, icon: Icons.lock_outline),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<EmailProviderPreset>(
                          initialValue: _selectedProvider,
                          isExpanded: true,
                          dropdownColor: c.surface,
                          style: TextStyle(color: c.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(labelText: 'Email provider'),
                          items: [
                            for (final preset in EmailProviderPreset.values)
                              DropdownMenuItem(value: preset, child: Text(preset.label)),
                          ],
                          onChanged: _onProviderSelected,
                        ),
                        const SizedBox(height: 14),
                        ExpansionTile(
                          controller: _serverSettingsController,
                          tilePadding: EdgeInsets.zero,
                          iconColor: c.textSecondary,
                          collapsedIconColor: c.textSecondary,
                          title: Text('Server settings (optional)', style: TextStyle(color: c.textPrimary, fontSize: 14)),
                          subtitle: Text(
                            'Auto-filled from the provider above.',
                            style: TextStyle(fontSize: 12, color: c.textTertiary),
                          ),
                          childrenPadding: const EdgeInsets.only(bottom: 8),
                          children: [
                            ComposerField(controller: _imapHostController, label: 'IMAP host'),
                            const SizedBox(height: 12),
                            ComposerField(controller: _imapPortController, label: 'IMAP port', keyboardType: TextInputType.number),
                            const SizedBox(height: 12),
                            ComposerField(controller: _smtpHostController, label: 'SMTP host'),
                            const SizedBox(height: 12),
                            ComposerField(controller: _smtpPortController, label: 'SMTP port', keyboardType: TextInputType.number),
                          ],
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _GradientButton(
                          onPressed: _isSigningIn ? null : _signIn,
                          isLoading: _isSigningIn,
                          label: 'Sign in',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIL HOME PAGE
// ─────────────────────────────────────────────────────────────────────────────

class MailHomePage extends StatefulWidget {
  const MailHomePage({
    super.key,
    required this.signedInEmail,
    required this.sessionToken,
    required this.onSignOut,
    required this.isDark,
    required this.onToggleTheme,
  });

  final String signedInEmail;
  final String sessionToken;
  final VoidCallback onSignOut;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<MailHomePage> createState() => _MailHomePageState();
}

class _MailHomePageState extends State<MailHomePage> {
  final TextEditingController _searchController = TextEditingController();
  late final MailService _mailService = MailService(token: widget.sessionToken);

  List<MailFolder> _folders = [];
  List<MailMessage> _messages = [];
  bool _isLoadingFolders = true;
  String? _foldersError;
  bool _isLoadingMessages = false;
  String? _messagesError;
  String _activeFolder = '';
  String? _selectedMessageId;

  int _ribbonTabIndex = 1;
  int _focusedTabIndex = 0;
  bool _sidebarCollapsed = false;

  void _handleSearchChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _loadFolders();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String? get _activeFolderPath =>
      _folders.firstWhereOrNull((f) => f.label == _activeFolder)?.path;

  Future<void> _loadFolders() async {
    setState(() { _isLoadingFolders = true; _foldersError = null; });
    final result = await _mailService.listMailboxes();
    if (!mounted) return;
    if (!result.success) {
      if (result.errorType == MailErrorType.sessionExpired) { widget.onSignOut(); return; }
      setState(() { _isLoadingFolders = false; _foldersError = result.message ?? 'Could not load folders.'; });
      return;
    }
    final mailboxes = result.data!;
    final folders = mailboxes
        .map((m) => MailFolder(label: m.displayName, path: m.path, icon: _iconForKind(m.kind), kind: m.kind, unreadCount: m.unreadCount))
        .toList();
    final inboxMailbox = mailboxes.firstWhereOrNull((m) => m.kind == 'inbox') ?? mailboxes.firstOrNull;
    setState(() { _folders = folders; _isLoadingFolders = false; _activeFolder = inboxMailbox?.displayName ?? ''; });
    if (inboxMailbox != null) _loadMessages(inboxMailbox.path);
  }

  Future<void> _loadMessages(String folderPath) async {
    setState(() { _isLoadingMessages = true; _messagesError = null; });
    final result = await _mailService.listMessages(folder: folderPath);
    if (!mounted) return;
    if (!result.success) {
      if (result.errorType == MailErrorType.sessionExpired) { widget.onSignOut(); return; }
      setState(() { _isLoadingMessages = false; _messagesError = result.message ?? 'Could not load messages.'; });
      return;
    }
    final messages = result.data!.map((m) => _toMailMessage(m, _activeFolder)).toList();
    setState(() { _messages = messages; _isLoadingMessages = false; _selectedMessageId = null; });
  }

  List<MailMessage> get _visibleMessages {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _messages;
    return _messages.where((m) => '${m.sender} ${m.subject} ${m.preview} ${m.body}'.toLowerCase().contains(query)).toList();
  }

  MailMessage? get _selectedMessage {
    final vis = _visibleMessages;
    if (vis.isEmpty) return null;
    return vis.firstWhereOrNull((m) => m.id == _selectedMessageId);
  }

  int _folderCount(String label) => _folders.firstWhereOrNull((f) => f.label == label)?.unreadCount ?? 0;

  int get _totalUnread {
    final inbox = _folders.firstWhereOrNull((f) => f.kind == 'inbox');
    return inbox?.unreadCount ?? _messages.where((m) => m.unread).length;
  }

  void _selectFolder(String label) {
    final folder = _folders.firstWhereOrNull((f) => f.label == label);
    if (folder == null) return;
    setState(() { _activeFolder = label; _selectedMessageId = null; _messages = []; });
    _loadMessages(folder.path);
  }

  void _selectMessage(MailMessage message) {
    setState(() { _selectedMessageId = message.id; message.unread = false; });
    _loadMessageBody(message);
  }

  Future<void> _loadMessageBody(MailMessage message) async {
    final folder = _activeFolderPath;
    if (folder == null) return;
    final result = await _mailService.getMessage(folder: folder, id: message.id);
    if (!mounted) return;
    if (result.errorType == MailErrorType.sessionExpired) { widget.onSignOut(); return; }
    setState(() {
      if (result.success) { message.body = result.data!.bodyText; message.starred = result.data!.starred; }
      else { message.body = "Couldn't load message: ${result.message ?? 'unknown error'}"; }
    });
  }

  void _toggleStar(String messageId) {
    final message = _messages.firstWhereOrNull((m) => m.id == messageId);
    if (message == null) return;
    final prev = message.starred;
    setState(() => message.starred = !prev);
    _persistStar(message, !prev, prev);
  }

  Future<void> _persistStar(MailMessage message, bool starred, bool prev) async {
    final folder = _activeFolderPath;
    if (folder == null) return;
    final result = await _mailService.setFlagged(folder: folder, id: message.id, starred: starred);
    if (!mounted) return;
    if (!result.success) {
      if (result.errorType == MailErrorType.sessionExpired) { widget.onSignOut(); return; }
      setState(() => message.starred = prev);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? "Couldn't update flag.")));
    }
  }

  void _handleDelete() async {
    final folderPath = _activeFolderPath;
    if (_selectedMessageId == null || folderPath == null) return;
    final msgId = _selectedMessageId!;
    final msg = _selectedMessage!;
    final trashFolder = _folders.firstWhere((m) => m.kind == 'trash', orElse: () => _folders.first);
    
    // Optimistic UI update
    setState(() { _messages.removeWhere((m) => m.id == msgId); _selectedMessageId = _messages.firstOrNull?.id; });
    
    final result = await _mailService.moveMessage(folder: folderPath, id: msgId, targetFolder: trashFolder.path);
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message deleted')));
    } else {
      // Revert if failed
      setState(() { _messages.add(msg); });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: ${result.message}')));
    }
  }

  void _handleReport() async {
    final folderPath = _activeFolderPath;
    if (_selectedMessageId == null || folderPath == null) return;
    final msgId = _selectedMessageId!;
    final msg = _selectedMessage!;
    final junkFolder = _folders.firstWhere((m) => m.kind == 'junk', orElse: () => _folders.first);
    
    setState(() { _messages.removeWhere((m) => m.id == msgId); _selectedMessageId = _messages.firstOrNull?.id; });
    
    final result = await _mailService.moveMessage(folder: folderPath, id: msgId, targetFolder: junkFolder.path);
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message reported as Junk')));
    } else {
      setState(() { _messages.add(msg); });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to report: ${result.message}')));
    }
  }

  void _handleMoveTo(GlobalKey buttonKey, BuildContext ctx) {
    final folderPath = _activeFolderPath;
    if (_selectedMessageId == null || folderPath == null) return;
    final RenderBox? renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<MailFolder>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy + renderBox.size.height, offset.dx + renderBox.size.width, 0),
      items: _folders.map((mb) => PopupMenuItem(value: mb, child: Text(mb.label))).toList(),
    ).then((selected) async {
      if (selected == null) return;
      final msgId = _selectedMessageId!;
      final msg = _selectedMessage!;
      
      setState(() { _messages.removeWhere((m) => m.id == msgId); _selectedMessageId = _messages.firstOrNull?.id; });
      
      final result = await _mailService.moveMessage(folder: folderPath, id: msgId, targetFolder: selected.path);
      if (!mounted) return;
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moved to ${selected.label}')));
      } else {
        setState(() { _messages.add(msg); });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to move: ${result.message}')));
      }
    });
  }

  void _toggleReadState() async {
    final msg = _selectedMessage;
    final folderPath = _activeFolderPath;
    if (msg == null || folderPath == null) return;
    
    final newUnread = !msg.unread;
    setState(() => msg.unread = newUnread);
    
    final result = await _mailService.setRead(folder: folderPath, id: msg.id, unread: newUnread);
    if (!mounted) return;
    if (!result.success) {
      setState(() => msg.unread = !newUnread); // revert
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update read status: ${result.message}')));
    }
  }

  Future<void> _openComposeDialog({String? to, String? subject, String? body}) async {
    final c = AppColors.of(context);
    final toCtrl = TextEditingController(text: to ?? '');
    final subCtrl = TextEditingController(text: subject ?? '');
    final bodyCtrl = TextEditingController(text: body ?? '');
    
    bool isSending = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('New message', style: TextStyle(color: c.textPrimary)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ComposerField(controller: toCtrl, label: 'To', icon: Icons.person_outline),
                  const SizedBox(height: 12),
                  ComposerField(controller: subCtrl, label: 'Subject', icon: Icons.subject),
                  const SizedBox(height: 12),
                  ComposerField(controller: bodyCtrl, label: 'Message', maxLines: 6),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx), 
              child: const Text('Cancel')
            ),
            FilledButton(
              onPressed: isSending ? null : () async {
                if (toCtrl.text.isEmpty || bodyCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('To and Message fields are required.')));
                  return;
                }
                
                setDialogState(() => isSending = true);
                final result = await _mailService.sendMessage(
                  to: toCtrl.text,
                  subject: subCtrl.text,
                  bodyText: bodyCtrl.text,
                );
                setDialogState(() => isSending = false);
                
                if (!ctx.mounted) return;
                
                if (result.success) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent successfully!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send: ${result.message}')));
                }
              },
              child: isSending 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
    toCtrl.dispose();
    subCtrl.dispose();
    bodyCtrl.dispose();
  }

  void _handleReply() {
    final msg = _selectedMessage;
    if (msg == null) return;
    _openComposeDialog(to: msg.senderEmail, subject: 'RE: ${msg.subject}');
  }

  void _handleForward() {
    final msg = _selectedMessage;
    if (msg == null) return;
    _openComposeDialog(subject: 'FW: ${msg.subject}', body: '\n\n---------- Forwarded ----------\nFrom: ${msg.sender}\n\n${msg.body}');
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        child: _isLoadingFolders
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2.5),
                  ],
                ),
              )
            : _foldersError != null
                ? _InboxStatusView(message: _foldersError!, onRetry: _loadFolders)
                : Column(
                    children: [
                      if (_isLoadingMessages)
                        Container(
                          height: 2,
                          decoration: const BoxDecoration(gradient: AppColors.accentGradient),
                        ),
                      if (_messagesError != null)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          color: AppColors.error.withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_messagesError!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                              TextButton(
                                onPressed: () { final f = _activeFolderPath; if (f != null) _loadMessages(f); },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 850) {
                              return Column(
                                children: [
                                  // ── Gradient accent bar ──
                                  Container(height: 3, decoration: const BoxDecoration(gradient: AppColors.accentGradient)),
                                  // ── Ribbon ──
                                  OutlookRibbon(
                                    tabIndex: _ribbonTabIndex,
                                    onTabChanged: (i) => setState(() => _ribbonTabIndex = i),
                                    onCompose: () => _openComposeDialog(),
                                    onDelete: _handleDelete,
                                    onReply: _handleReply,
                                    onReplyAll: _handleReply,
                                    onForward: _handleForward,
                                    onReport: _handleReport,
                                    onMoveTo: _handleMoveTo,
                                    onToggleRead: _toggleReadState,
                                    hasSelectedMessage: _selectedMessage != null,
                                    isDark: widget.isDark,
                                    onToggleTheme: widget.onToggleTheme,
                                  ),
                                  Expanded(
                                    child: DesktopMailShell(
                                      folders: _folders, folderCount: _folderCount, activeFolder: _activeFolder,
                                      searchController: _searchController, onSearchChanged: _handleSearchChanged,
                                      visibleMessages: _visibleMessages, selectedMessage: _selectedMessage,
                                      onFolderSelected: _selectFolder, onMessageSelected: _selectMessage,
                                      onToggleStar: _toggleStar, onCompose: () => _openComposeDialog(), onReply: _handleReply,
                                      signedInEmail: widget.signedInEmail, onSignOut: widget.onSignOut,
                                      focusedTabIndex: _focusedTabIndex, onFocusedTabChanged: (i) => setState(() => _focusedTabIndex = i),
                                      sidebarCollapsed: _sidebarCollapsed, onSidebarToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return MobileMailShell(
                              folders: _folders, activeFolder: _activeFolder,
                              searchController: _searchController, onSearchChanged: _handleSearchChanged,
                              visibleMessages: _visibleMessages, onFolderSelected: _selectFolder,
                              onCompose: () => _openComposeDialog(),
                              onOpenMessage: (m) { 
                                _selectMessage(m); 
                                Navigator.of(context).push(MaterialPageRoute<void>(
                                  builder: (_) => MessageDetailPage(
                                    message: m, 
                                    onToggleStar: () => _toggleStar(m.id), 
                                    onReply: _handleReply,
                                    onDelete: () { _handleDelete(); Navigator.pop(context); },
                                    onForward: _handleForward,
                                    onReport: () { _handleReport(); Navigator.pop(context); },
                                    onMoveTo: (key, ctx) => _handleMoveTo(key, ctx),
                                  )
                                )); 
                              },
                              signedInEmail: widget.signedInEmail, onSignOut: widget.onSignOut,
                            );
                          },
                        ),
                      ),
                      StatusBar(totalItems: _messages.length, unreadCount: _totalUnread),
                    ],
                  ),
      ),
    );
  }
}

class _InboxStatusView extends StatelessWidget {
  const _InboxStatusView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: c.textTertiary),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIBBON TOOLBAR
// ─────────────────────────────────────────────────────────────────────────────

class OutlookRibbon extends StatelessWidget {
  const OutlookRibbon({
    super.key, required this.tabIndex, required this.onTabChanged,
    required this.onCompose, required this.onDelete, required this.onReply,
    required this.onReplyAll, required this.onForward, required this.onToggleRead,
    required this.onReport, required this.onMoveTo,
    required this.hasSelectedMessage, required this.isDark, required this.onToggleTheme,
  });

  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onCompose, onDelete, onReply, onReplyAll, onForward, onToggleRead, onReport;
  final Function(GlobalKey, BuildContext) onMoveTo;
  final bool hasSelectedMessage, isDark;
  final VoidCallback onToggleTheme;

  static const _tabs = ['File', 'Home', 'Send / Receive', 'View', 'Help'];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Column(
      children: [
        // ── Menu tab bar ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 34,
          color: c.menuBar,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _AnimatedGradientIcon(icon: Icons.mail_rounded, size: 20),
              ),
              for (int i = 0; i < _tabs.length; i++)
                _RibbonTab(label: _tabs[i], isSelected: i == tabIndex, onTap: () => onTabChanged(i)),
              const Spacer(),
              ThemeToggleButton(isDark: isDark, onToggle: onToggleTheme),
              const SizedBox(width: 12),
              SizedBox(
                width: 180, height: 26,
                child: TextField(
                  style: TextStyle(fontSize: 12, color: c.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search People',
                    prefixIcon: Icon(Icons.search, size: 14, color: c.textTertiary),
                    filled: true, fillColor: c.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        // ── Action buttons ──
        if (tabIndex == 1)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 46,
            decoration: BoxDecoration(color: c.surface, border: Border(bottom: BorderSide(color: c.border))),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _RibbonButton(icon: Icons.email_outlined, label: 'New Email', onTap: onCompose, hasDropdown: true, isPrimary: true),
                const _RibbonDivider(),
                _RibbonButton(icon: Icons.delete_outline, label: 'Delete', onTap: hasSelectedMessage ? onDelete : null),
                const _RibbonDivider(),
                _RibbonButton(icon: Icons.flag_outlined, label: 'Report', onTap: hasSelectedMessage ? onReport : null, hasDropdown: true),
                const _RibbonDivider(),
                _RibbonButton(icon: Icons.reply_outlined, label: 'Reply', onTap: hasSelectedMessage ? onReply : null),
                _RibbonButton(icon: Icons.reply_all_outlined, label: 'Reply All', onTap: hasSelectedMessage ? onReplyAll : null),
                _RibbonButton(icon: Icons.shortcut_outlined, label: 'Forward', onTap: hasSelectedMessage ? onForward : null),
                const _RibbonDivider(),
                Builder(
                  builder: (ctx) {
                    final key = GlobalKey();
                    return _RibbonButton(key: key, icon: Icons.drive_file_move_outline, label: 'Move to', onTap: hasSelectedMessage ? () => onMoveTo(key, ctx) : null, hasDropdown: true);
                  },
                ),
                const _RibbonDivider(),
                _RibbonButton(icon: Icons.mark_email_unread_outlined, label: 'Unread/Read', onTap: hasSelectedMessage ? onToggleRead : null),
                const Spacer(),
              ],
            ),
          ),
      ],
    );
  }
}

class _RibbonTab extends StatefulWidget {
  const _RibbonTab({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_RibbonTab> createState() => _RibbonTabState();
}

class _RibbonTabState extends State<_RibbonTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected ? c.surface : (_hovered ? c.hoverBg : Colors.transparent),
            border: Border(bottom: BorderSide(color: widget.isSelected ? AppColors.accent : Colors.transparent, width: 2)),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: widget.isSelected ? c.textPrimary : c.textSecondary,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonButton extends StatefulWidget {
  const _RibbonButton({super.key, required this.icon, required this.label, required this.onTap, this.hasDropdown = false, this.isPrimary = false});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool hasDropdown, isPrimary;

  @override
  State<_RibbonButton> createState() => _RibbonButtonState();
}

class _RibbonButtonState extends State<_RibbonButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final enabled = widget.onTap != null;
    final color = enabled ? (widget.isPrimary ? c.textPrimary : c.textSecondary) : c.textTertiary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _hovered && enabled ? c.hoverBg : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: color),
              const SizedBox(width: 4),
              Text(widget.label, style: TextStyle(fontSize: 11.5, color: color)),
              if (widget.hasDropdown) Icon(Icons.arrow_drop_down, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _RibbonDivider extends StatelessWidget {
  const _RibbonDivider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 4), color: AppColors.of(context).border);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP SHELL
// ─────────────────────────────────────────────────────────────────────────────

class DesktopMailShell extends StatelessWidget {
  const DesktopMailShell({
    super.key,
    required this.folders, required this.folderCount, required this.activeFolder,
    required this.searchController, required this.onSearchChanged,
    required this.visibleMessages, required this.selectedMessage,
    required this.onFolderSelected, required this.onMessageSelected,
    required this.onToggleStar, required this.onCompose, required this.onReply,
    required this.signedInEmail, required this.onSignOut,
    required this.focusedTabIndex, required this.onFocusedTabChanged,
    required this.sidebarCollapsed, required this.onSidebarToggle,
  });

  final List<MailFolder> folders;
  final int Function(String) folderCount;
  final String activeFolder;
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final List<MailMessage> visibleMessages;
  final MailMessage? selectedMessage;
  final ValueChanged<String> onFolderSelected;
  final ValueChanged<MailMessage> onMessageSelected;
  final ValueChanged<String> onToggleStar;
  final VoidCallback onCompose, onReply;
  final String signedInEmail;
  final VoidCallback onSignOut;
  final int focusedTabIndex;
  final ValueChanged<int> onFocusedTabChanged;
  final bool sidebarCollapsed;
  final VoidCallback onSidebarToggle;

  @override
  Widget build(BuildContext context) {
    final msg = selectedMessage;
    return Row(
      children: [
        OutlookNavRail(onSidebarToggle: onSidebarToggle),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          width: sidebarCollapsed ? 0 : 240,
          child: sidebarCollapsed
              ? const SizedBox.shrink()
              : SidebarPanel(
                  folders: folders, folderCount: folderCount, activeFolder: activeFolder,
                  onFolderSelected: onFolderSelected, onCompose: onCompose,
                  signedInEmail: signedInEmail, onSignOut: onSignOut, onCollapse: onSidebarToggle,
                ),
        ),
        SizedBox(
          width: 380,
          child: MessageListPane(
            title: activeFolder, searchController: searchController, onSearchChanged: onSearchChanged,
            visibleMessages: visibleMessages, selectedMessageId: msg?.id,
            onMessageSelected: onMessageSelected, focusedTabIndex: focusedTabIndex, onFocusedTabChanged: onFocusedTabChanged,
          ),
        ),
        Expanded(
          child: DetailPane(message: msg, onToggleStar: msg == null ? null : () => onToggleStar(msg.id), onReply: onReply),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAVIGATION RAIL
// ─────────────────────────────────────────────────────────────────────────────

class OutlookNavRail extends StatefulWidget {
  const OutlookNavRail({super.key, required this.onSidebarToggle});
  final VoidCallback onSidebarToggle;
  @override
  State<OutlookNavRail> createState() => _OutlookNavRailState();
}

class _OutlookNavRailState extends State<OutlookNavRail> {
  int _selectedIndex = 0;
  static const _icons = [
    (Icons.mail_outlined, Icons.mail_rounded, 'Mail'),
    (Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Calendar'),
    (Icons.people_outline_rounded, Icons.people_rounded, 'People'),
    (Icons.check_circle_outline_rounded, Icons.check_circle_rounded, 'Tasks'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 50,
      decoration: BoxDecoration(color: c.navRail, border: Border(right: BorderSide(color: c.border))),
      child: Column(
        children: [
          const SizedBox(height: 8),
          for (int i = 0; i < _icons.length; i++)
            _NavRailIcon(
              icon: i == _selectedIndex ? _icons[i].$2 : _icons[i].$1,
              tooltip: _icons[i].$3,
              isSelected: i == _selectedIndex,
              onTap: () => setState(() => _selectedIndex = i),
            ),
          const Spacer(),
          _NavRailIcon(icon: Icons.settings_outlined, tooltip: 'Settings', isSelected: false, onTap: () {
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.of(context).surface,
                title: Text('Settings', style: TextStyle(color: AppColors.of(context).textPrimary)),
                content: Text('Settings are not implemented yet.', style: TextStyle(color: AppColors.of(context).textSecondary)),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavRailIcon extends StatefulWidget {
  const _NavRailIcon({required this.icon, required this.tooltip, required this.isSelected, required this.onTap});
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  State<_NavRailIcon> createState() => _NavRailIconState();
}

class _NavRailIconState extends State<_NavRailIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 46,
            decoration: BoxDecoration(
              color: widget.isSelected ? c.selectedBg : (_hovered ? c.hoverBg : Colors.transparent),
              border: Border(left: BorderSide(color: widget.isSelected ? AppColors.accent : Colors.transparent, width: 3)),
            ),
            child: Icon(widget.icon, size: 20, color: widget.isSelected ? AppColors.accent : c.textSecondary),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR
// ─────────────────────────────────────────────────────────────────────────────

class SidebarPanel extends StatefulWidget {
  const SidebarPanel({
    super.key, required this.folders, required this.folderCount, required this.activeFolder,
    required this.onFolderSelected, required this.onCompose, required this.signedInEmail,
    required this.onSignOut, required this.onCollapse,
  });
  final List<MailFolder> folders;
  final int Function(String) folderCount;
  final String activeFolder;
  final ValueChanged<String> onFolderSelected;
  final VoidCallback onCompose, onSignOut, onCollapse;
  final String signedInEmail;
  @override
  State<SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends State<SidebarPanel> {
  bool _favoritesExpanded = true;
  bool _accountExpanded = true;
  bool _groupsExpanded = true;

  List<MailFolder> get _favorites {
    const kinds = {'inbox', 'sent', 'drafts', 'trash'};
    final f = widget.folders.where((f) => kinds.contains(f.kind)).toList();
    return f.isEmpty && widget.folders.isNotEmpty ? widget.folders.take(4).toList() : f;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: c.pane,
        border: Border(right: BorderSide(color: c.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Collapse button
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: _HoverIconButton(icon: Icons.chevron_left_rounded, tooltip: 'Collapse', onTap: widget.onCollapse),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              children: [
                _SidebarSectionHeader(title: 'Favorites', isExpanded: _favoritesExpanded, onTap: () => setState(() => _favoritesExpanded = !_favoritesExpanded)),
                if (_favoritesExpanded)
                  for (final f in _favorites)
                    _FolderItem(folder: f, isSelected: f.label == widget.activeFolder, count: widget.folderCount(f.label), onTap: () => widget.onFolderSelected(f.label)),
                const SizedBox(height: 6),
                _SidebarSectionHeader(title: widget.signedInEmail, isExpanded: _accountExpanded, onTap: () => setState(() => _accountExpanded = !_accountExpanded)),
                if (_accountExpanded)
                  for (final f in widget.folders)
                    _FolderItem(folder: f, isSelected: f.label == widget.activeFolder, count: widget.folderCount(f.label), onTap: () => widget.onFolderSelected(f.label), indent: 1),
                const SizedBox(height: 6),
                _SidebarSectionHeader(title: 'Groups', isExpanded: _groupsExpanded, onTap: () => setState(() => _groupsExpanded = !_groupsExpanded)),
                if (_groupsExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 6, 8, 10),
                    child: Text('You have not joined any groups yet', style: TextStyle(fontSize: 12, color: c.textTertiary, fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSectionHeader extends StatefulWidget {
  const _SidebarSectionHeader({required this.title, required this.isExpanded, required this.onTap});
  final String title;
  final bool isExpanded;
  final VoidCallback onTap;
  @override
  State<_SidebarSectionHeader> createState() => _SidebarSectionHeaderState();
}

class _SidebarSectionHeaderState extends State<_SidebarSectionHeader> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered ? c.hoverBg : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              AnimatedRotation(
                turns: widget.isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.chevron_right_rounded, size: 16, color: c.textSecondary),
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(widget.title, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textPrimary))),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderItem extends StatefulWidget {
  const _FolderItem({required this.folder, required this.isSelected, required this.count, required this.onTap, this.indent = 0});
  final MailFolder folder;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;
  final int indent;
  @override
  State<_FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<_FolderItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 34,
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color: widget.isSelected ? c.selectedBg : (_hovered ? c.hoverBg : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border(left: const BorderSide(color: AppColors.accent, width: 3))
                : null,
          ),
          padding: EdgeInsets.only(left: 12.0 + (widget.indent * 16), right: 10),
          child: Row(
            children: [
              Icon(widget.folder.icon, size: 16, color: widget.isSelected ? AppColors.accent : c.textSecondary),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.folder.label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: widget.isSelected ? AppColors.accent : c.textPrimary, fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400))),
              if (widget.count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${widget.count}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE LIST PANE
// ─────────────────────────────────────────────────────────────────────────────

class MessageListPane extends StatelessWidget {
  const MessageListPane({
    super.key, required this.title, required this.searchController, required this.onSearchChanged,
    required this.visibleMessages, required this.selectedMessageId, required this.onMessageSelected,
    required this.focusedTabIndex, required this.onFocusedTabChanged,
  });

  final String title;
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final List<MailMessage> visibleMessages;
  final String? selectedMessageId;
  final ValueChanged<MailMessage> onMessageSelected;
  final int focusedTabIndex;
  final ValueChanged<int> onFocusedTabChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(color: c.canvas, border: Border(right: BorderSide(color: c.border))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Focused / Other tabs
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
            child: Row(
              children: [
                _FocusedTab(label: 'Focused', isSelected: focusedTabIndex == 0, onTap: () => onFocusedTabChanged(0)),
                const SizedBox(width: 18),
                _FocusedTab(label: 'Other', isSelected: focusedTabIndex == 1, onTap: () => onFocusedTabChanged(1)),
                const Spacer(),
                Text('By Date', style: TextStyle(fontSize: 11, color: c.textSecondary)),
                Icon(Icons.expand_more_rounded, size: 14, color: c.textSecondary),
                const SizedBox(width: 4),
                Icon(Icons.arrow_upward_rounded, size: 14, color: c.textSecondary),
              ],
            ),
          ),
          if (focusedTabIndex == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.12), AppColors.teal.withValues(alpha: 0.08)]),
              ),
              child: const Text('Other: New messages', style: TextStyle(fontSize: 12, color: AppColors.accent)),
            ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: SearchBarField(controller: searchController, onChanged: (_) => onSearchChanged()),
          ),
          Expanded(
            child: DateGroupedMessageList(messages: visibleMessages, selectedMessageId: selectedMessageId, onMessageSelected: onMessageSelected),
          ),
        ],
      ),
    );
  }
}

class _FocusedTab extends StatelessWidget {
  const _FocusedTab({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? AppColors.accent : Colors.transparent, width: 2)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 13, color: isSelected ? c.textPrimary : c.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATE-GROUPED MESSAGE LIST
// ─────────────────────────────────────────────────────────────────────────────

class DateGroupedMessageList extends StatefulWidget {
  const DateGroupedMessageList({super.key, required this.messages, this.selectedMessageId, required this.onMessageSelected});
  final List<MailMessage> messages;
  final String? selectedMessageId;
  final ValueChanged<MailMessage> onMessageSelected;
  @override
  State<DateGroupedMessageList> createState() => _DateGroupedMessageListState();
}

class _DateGroupedMessageListState extends State<DateGroupedMessageList> {
  final Set<String> _collapsed = {};

  List<_DateGroupItem> _buildItems() {
    if (widget.messages.isEmpty) return [];
    final items = <_DateGroupItem>[];
    String? currentGroup;
    for (final m in widget.messages) {
      final group = _dateGroupLabel(m.date);
      if (group != currentGroup) {
        currentGroup = group;
        items.add(_DateGroupItem.header(group));
      }
      if (!_collapsed.contains(group)) items.add(_DateGroupItem.message(m));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (widget.messages.isEmpty) {
      return Center(child: Text('No messages found.', style: TextStyle(fontWeight: FontWeight.w600, color: c.textSecondary)));
    }
    final items = _buildItems();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.groupLabel != null) {
          final collapsed = _collapsed.contains(item.groupLabel);
          return _DateGroupHeader(
            label: item.groupLabel!,
            isCollapsed: collapsed,
            onToggle: () => setState(() { if (collapsed) { _collapsed.remove(item.groupLabel); } else { _collapsed.add(item.groupLabel!); } }),
          );
        }
        return MessageTile(message: item.message!, isSelected: item.message!.id == widget.selectedMessageId, onTap: () => widget.onMessageSelected(item.message!));
      },
    );
  }
}

class _DateGroupItem {
  final String? groupLabel;
  final MailMessage? message;
  const _DateGroupItem.header(this.groupLabel) : message = null;
  const _DateGroupItem.message(this.message) : groupLabel = null;
}

class _DateGroupHeader extends StatefulWidget {
  const _DateGroupHeader({required this.label, required this.isCollapsed, required this.onToggle});
  final String label;
  final bool isCollapsed;
  final VoidCallback onToggle;
  @override
  State<_DateGroupHeader> createState() => _DateGroupHeaderState();
}

class _DateGroupHeaderState extends State<_DateGroupHeader> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 30,
          color: _hovered ? c.hoverBg : c.groupHeaderBg,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              AnimatedRotation(
                turns: widget.isCollapsed ? 0 : 0.25,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.chevron_right_rounded, size: 16, color: c.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(widget.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE TILE (with hover animation)
// ─────────────────────────────────────────────────────────────────────────────

class MessageTile extends StatefulWidget {
  const MessageTile({super.key, required this.message, required this.isSelected, required this.onTap});
  final MailMessage message;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final m = widget.message;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: widget.isSelected ? c.selectedBg : (_hovered ? c.hoverBg : Colors.transparent),
            border: Border(
              left: BorderSide(color: m.unread ? AppColors.accent : Colors.transparent, width: 3),
              bottom: BorderSide(color: c.divider, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (m.unread)
                    Container(
                      width: 7, height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.accentGradient,
                        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 4)],
                      ),
                    ),
                  Expanded(child: Text(m.sender, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.textPrimary, fontWeight: m.unread ? FontWeight.w700 : FontWeight.w400))),
                  const SizedBox(width: 8),
                  Text(m.timeLabel, style: TextStyle(fontSize: 11, color: c.textTertiary)),
                ],
              ),
              const SizedBox(height: 3),
              Text(m.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: m.unread ? AppColors.accent : c.textSecondary, fontWeight: m.unread ? FontWeight.w600 : FontWeight.w400)),
              const SizedBox(height: 2),
              Text(m.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL / READING PANE
// ─────────────────────────────────────────────────────────────────────────────

class DetailPane extends StatelessWidget {
  const DetailPane({super.key, required this.message, required this.onToggleStar, required this.onReply});
  final MailMessage? message;
  final VoidCallback? onToggleStar;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final m = message;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: c.surface,
      child: m == null
          ? _EmptyState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
                  child: Row(
                    children: [
                      _HoverIconButton(icon: Icons.reply_outlined, tooltip: 'Reply', onTap: onReply),
                      const SizedBox(width: 4),
                      _HoverIconButton(
                        icon: m.starred ? Icons.star_rounded : Icons.star_outline_rounded,
                        tooltip: m.starred ? 'Unflag' : 'Flag',
                        onTap: onToggleStar,
                        color: m.starred ? AppColors.warning : null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.subject, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: c.textPrimary, letterSpacing: -0.3)),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [m.accent, m.accent.withValues(alpha: 0.7)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text(m.sender.isEmpty ? '?' : m.sender[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.sender, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text(m.senderEmail, style: TextStyle(fontSize: 12, color: c.textTertiary)),
                                ],
                              ),
                            ),
                            Text(m.timeLabel, style: TextStyle(fontSize: 12, color: c.textTertiary)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(height: 1, color: c.divider),
                        const SizedBox(height: 24),
                        SelectableText(m.body, style: TextStyle(fontSize: 14, height: 1.65, color: c.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * 30),
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.teal.withValues(alpha: 0.1)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.mail_outline_rounded, size: 36, color: c.textTertiary),
            ),
            const SizedBox(height: 20),
            Text('Select an item to read', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: c.textSecondary)),
            const SizedBox(height: 8),
            Text('Click here to always preview messages', style: TextStyle(fontSize: 13, color: AppColors.accent)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BAR
// ─────────────────────────────────────────────────────────────────────────────

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.totalItems, required this.unreadCount});
  final int totalItems, unreadCount;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 26,
      decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.border))),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text('Items: $totalItems    Unread: $unreadCount', style: TextStyle(fontSize: 11, color: c.textSecondary)),
          const Spacer(),
          Text('All folders are up to date.', style: TextStyle(fontSize: 11, color: c.textTertiary)),
          const Spacer(),
          Text('Connected via IMAP', style: TextStyle(fontSize: 11, color: c.textSecondary)),
          const SizedBox(width: 10),
          Icon(Icons.view_list_rounded, size: 14, color: c.textTertiary),
          const SizedBox(width: 6),
          Icon(Icons.view_compact_rounded, size: 14, color: c.textTertiary),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE SHELL
// ─────────────────────────────────────────────────────────────────────────────

class MobileMailShell extends StatelessWidget {
  const MobileMailShell({
    super.key, required this.folders, required this.activeFolder,
    required this.searchController, required this.onSearchChanged,
    required this.visibleMessages, required this.onFolderSelected,
    required this.onCompose, required this.onOpenMessage,
    required this.signedInEmail, required this.onSignOut,
  });

  final List<MailFolder> folders;
  final String activeFolder;
  final TextEditingController searchController;
  final VoidCallback onSearchChanged, onCompose;
  final List<MailMessage> visibleMessages;
  final ValueChanged<String> onFolderSelected;
  final ValueChanged<MailMessage> onOpenMessage;
  final String signedInEmail;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: AppBar(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0, scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        title: PopupMenuButton<String>(
          initialValue: activeFolder,
          onSelected: onFolderSelected,
          position: PopupMenuPosition.under,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(activeFolder, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: c.textSecondary),
            ],
          ),
          itemBuilder: (context) => folders.map((f) => PopupMenuItem(
            value: f.label,
            child: Row(
              children: [
                Icon(f.icon, size: 18, color: f.label == activeFolder ? AppColors.accent : c.textSecondary),
                const SizedBox(width: 12),
                Text(f.label, style: TextStyle(color: f.label == activeFolder ? AppColors.accent : c.textPrimary, fontWeight: f.label == activeFolder ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          )).toList(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'logout') onSignOut();
            },
            offset: const Offset(0, 48),
            tooltip: 'Account',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.accent,
                child: Text(signedInEmail.isEmpty ? '?' : signedInEmail[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(signedInEmail, style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12)),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [Icon(Icons.logout_rounded, size: 18), SizedBox(width: 12), Text('Sign out')]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: SearchBarField(controller: searchController, onChanged: (_) => onSearchChanged())),
          const SizedBox(height: 12),
          Expanded(child: DateGroupedMessageList(messages: visibleMessages, onMessageSelected: onOpenMessage)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCompose,
        backgroundColor: AppColors.accent,
        elevation: 4,
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE DETAIL (MOBILE)
// ─────────────────────────────────────────────────────────────────────────────

class MessageDetailPage extends StatelessWidget {
  const MessageDetailPage({
    super.key, 
    required this.message, 
    required this.onToggleStar, 
    required this.onReply,
    required this.onDelete,
    required this.onForward,
    required this.onReport,
    required this.onMoveTo,
  });
  
  final MailMessage message;
  final VoidCallback onToggleStar, onReply, onDelete, onForward, onReport;
  final Function(GlobalKey, BuildContext) onMoveTo;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final moveKey = GlobalKey();
    
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: AppBar(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0, scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        title: const Text('Message', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(onPressed: onReply, icon: const Icon(Icons.reply_outlined), color: c.textSecondary, tooltip: 'Reply'),
          IconButton(onPressed: onForward, icon: const Icon(Icons.shortcut_outlined), color: c.textSecondary, tooltip: 'Forward'),
          IconButton(
            key: moveKey,
            onPressed: () => onMoveTo(moveKey, context),
            icon: const Icon(Icons.drive_file_move_outline), color: c.textSecondary, tooltip: 'Move to',
          ),
          IconButton(
            onPressed: onToggleStar,
            icon: Icon(message.starred ? Icons.star_rounded : Icons.star_outline_rounded, color: message.starred ? AppColors.warning : c.textSecondary),
            tooltip: message.starred ? 'Unflag' : 'Flag',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: c.textSecondary),
            onSelected: (val) {
              if (val == 'delete') {
                onDelete();
              } else if (val == 'report') {
                onReport();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
              const PopupMenuItem(value: 'report', child: Text('Report Junk')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(message.subject, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: c.textPrimary)),
          const SizedBox(height: 10),
          Text('${message.sender} · ${message.timeLabel}', style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(message.senderEmail, style: TextStyle(color: c.textTertiary, fontSize: 12)),
          const SizedBox(height: 20),
          Divider(height: 1, color: c.divider),
          const SizedBox(height: 20),
          SelectableText(message.body, style: TextStyle(fontSize: 14, height: 1.65, color: c.textPrimary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class SearchBarField extends StatelessWidget {
  const SearchBarField({super.key, required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search mail',
        prefixIcon: Icon(Icons.search_rounded, size: 20, color: c.textSecondary),
        filled: true, fillColor: c.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class ComposerField extends StatelessWidget {
  const ComposerField({super.key, required this.controller, required this.label, this.maxLines = 1, this.obscureText = false, this.keyboardType, this.icon});
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: c.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 18, color: c.textTertiary) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Orbit Mail', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary, letterSpacing: -0.3)),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.onPressed, required this.isLoading, required this.label});
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        decoration: BoxDecoration(
          gradient: onPressed != null ? AppColors.accentGradient : null,
          color: onPressed == null ? AppColors.accent.withValues(alpha: 0.4) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed != null
              ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3)),
        ),
      ),
    );
  }
}

class _HoverIconButton extends StatefulWidget {
  const _HoverIconButton({required this.icon, required this.tooltip, required this.onTap, this.color});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? color;
  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: _hovered ? c.hoverBg : Colors.transparent, borderRadius: BorderRadius.circular(8)),
            child: Icon(widget.icon, size: 18, color: widget.color ?? c.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.06)),
    );
  }
}

class _AnimatedGradientIcon extends StatelessWidget {
  const _AnimatedGradientIcon({required this.icon, required this.size});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

class MailFolder {
  const MailFolder({required this.label, required this.path, required this.icon, required this.kind, this.unreadCount = 0});
  final String label, path, kind;
  final IconData icon;
  final int unreadCount;
}

class MailMessage {
  MailMessage({required this.id, required this.folder, required this.sender, required this.senderEmail, required this.subject, required this.preview, required this.body, required this.timeLabel, required this.date, required this.unread, required this.starred, required this.accent});
  final String id, folder, sender, senderEmail, subject, preview, timeLabel;
  String body;
  final DateTime? date;
  bool unread, starred;
  final Color accent;
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

IconData _iconForKind(String kind) {
  return switch (kind) {
    'inbox' => Icons.inbox_rounded,
    'sent' => Icons.send_rounded,
    'drafts' => Icons.drafts_rounded,
    'junk' => Icons.report_gmailerrorred_rounded,
    'trash' => Icons.delete_outline_rounded,
    'archive' => Icons.archive_outlined,
    _ => Icons.folder_outlined,
  };
}

const List<Color> _accentPalette = [Color(0xFF3B82F6), Color(0xFF06B6D4), Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFF64748B), Color(0xFFEC4899), Color(0xFF6366F1)];

Color _accentFor(String sender) => _accentPalette[sender.hashCode.abs() % _accentPalette.length];

String _formatTimeLabel(DateTime? date) {
  if (date == null) return '';
  final local = date.toLocal();
  final now = DateTime.now();
  if (local.year == now.year && local.month == now.month && local.day == now.day) {
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
  final yesterday = now.subtract(const Duration(days: 1));
  if (local.year == yesterday.year && local.month == yesterday.month && local.day == yesterday.day) return 'Yesterday';
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  if (now.difference(local).inDays < 7) return weekdays[local.weekday - 1];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}

String _dateGroupLabel(DateTime? date) {
  if (date == null) return 'Older';
  final now = DateTime.now();
  final local = date.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(local.year, local.month, local.day);
  final diff = today.difference(messageDay).inDays;
  if (diff < 0) return 'Future';
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) { const d = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']; return d[local.weekday - 1]; }
  if (diff < 14) return 'Last Week';
  if (diff < 21) return 'Two Weeks Ago';
  if (diff < 28) return 'Three Weeks Ago';
  if (diff < 60) return 'Last Month';
  return 'Older';
}

MailMessage _toMailMessage(MessageSummaryData data, String folderLabel) {
  return MailMessage(
    id: data.id, folder: folderLabel, sender: data.sender, senderEmail: data.senderEmail,
    subject: data.subject, preview: data.preview, body: data.preview,
    timeLabel: _formatTimeLabel(data.date), date: data.date,
    unread: data.unread, starred: data.starred, accent: _accentFor(data.sender),
  );
}

extension FirstWhereOrNullExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) { if (test(element)) return element; }
    return null;
  }
}
