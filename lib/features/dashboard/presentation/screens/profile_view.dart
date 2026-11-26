import 'package:expense_app/core/providers/theme_provider.dart';
import 'package:expense_app/core/utils/currency_formatter.dart';
import 'package:expense_app/features/dashboard/presentation/widgets/profile_widgets.dart';
import 'package:expense_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:expense_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with WidgetsBindingObserver {
  User? user;
  bool _isCopied = false;
  String? _version;

  // ================= LIFECYCLE =================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    user = FirebaseAuth.instance.currentUser;
    // The user may have verified their email in a browser since last time.
    if (user != null && !user!.emailVerified) {
      _refreshUser();
    }
    _loadVersion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the email app: pick up the new verified state.
    if (state == AppLifecycleState.resumed) {
      _refreshUser();
    }
  }

  Future<void> _refreshUser() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return;
    try {
      await current.reload();
    } catch (_) {
      return; // offline: keep showing what we have
    }
    if (!mounted) return;
    setState(() => user = FirebaseAuth.instance.currentUser);
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = info.version);
    } catch (_) {
      // The version line is optional.
    }
  }

  // ================= DERIVED VALUES =================

  String get _initials {
    final name = user?.displayName?.trim() ?? '';
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      String firstLetter(String s) => String.fromCharCode(s.runes.first);
      final first = firstLetter(parts.first);
      final last = parts.length > 1 ? firstLetter(parts.last) : '';
      return (first + last).toUpperCase();
    }
    final email = user?.email ?? '';
    if (email.isNotEmpty) {
      return String.fromCharCode(email.runes.first).toUpperCase();
    }
    return '?';
  }

  String get _maskedUid {
    final id = user?.uid ?? 'No ID';
    if (id.length < 10) return id;
    return '${id.substring(0, 4)}****${id.substring(id.length - 4)}';
  }

  String get _memberSince {
    final date = user?.metadata.creationTime;
    if (date == null) return '—';
    return DateFormat('MMM yyyy').format(date.toLocal());
  }

  // ================= ACTIONS =================

  void _copyUserId() {
    final uid = user?.uid ?? '';
    if (uid.isEmpty) return;

    Clipboard.setData(ClipboardData(text: uid));
    setState(() => _isCopied = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  Future<void> _editName() async {
    final messenger = ScaffoldMessenger.of(context);
    final current = user?.displayName ?? '';

    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initial: current),
    );
    if (name == null || name == current) return;

    try {
      await user?.updateDisplayName(name);
      await user?.reload();
      if (!mounted) return;
      setState(() => user = FirebaseAuth.instance.currentUser);
      messenger.showSnackBar(const SnackBar(content: Text('Name updated')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't update your name. Try again.")),
      );
    }
  }

  Future<void> _sendVerificationEmail() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await user?.sendEmailVerification();
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Verification email sent to ${user?.email}. Open the link, then come back here.',
        ),
      ));
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(
          e.code == 'too-many-requests'
              ? 'Too many attempts. Try again in a little while.'
              : "Couldn't send the email. Try again.",
        ),
      ));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't send the email. Try again.")),
      );
    }
  }

  Future<void> _toggleReminder(NotificationProvider n, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await n.setEnabled(value);
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
        content: Text(
          'Notification permission is off. Turn it on in system settings.',
        ),
      ));
    }
  }

  Future<void> _pickReminderTime(NotificationProvider n) async {
    final picked = await showTimePicker(context: context, initialTime: n.time);
    if (picked != null) await n.setTime(picked);
  }

  Future<void> _confirmLogout() async {
    // Grab providers before awaiting so we never use context after the dialog.
    final themeProvider = context.read<ThemeProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content:
            const Text("You'll need to sign in again to see your expenses."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Log out',
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await themeProvider.setDarkMode(false);
    await notificationProvider.setEnabled(false);
    await transactionProvider.clearLocalTransactions();
    await FirebaseAuth.instance.signOut(); // the router redirects to /login
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final transactions = context.watch<TransactionProvider>().transactions;
    final now = DateTime.now();
    final spentThisMonth = transactions.where((t) {
      final d = t.date.toLocal();
      return !t.isIncome && d.year == now.year && d.month == now.month;
    }).fold<double>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ProfileStatTile(
                  value: '${transactions.length}',
                  label: 'Transactions',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ProfileStatTile(
                  value: _compactNpr(spentThisMonth),
                  label: 'Spent this month',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ProfileStatTile(
                  value: _memberSince,
                  label: 'Member since',
                ),
              ),
            ],
          ),

          // ---------- Preferences ----------
          const SettingsSectionLabel('Preferences'),
          SettingsCard(
            children: [
              Consumer<NotificationProvider>(
                builder: (context, n, _) => SettingsRow(
                  icon: Icons.notifications_outlined,
                  title: 'Daily reminder',
                  subtitle: n.enabled
                      ? 'Every day at ${n.time.format(context)}'
                      : 'Off',
                  // On: tap the row to change the time. Off: tap to turn on.
                  onTap: n.enabled
                      ? () => _pickReminderTime(n)
                      : () => _toggleReminder(n, true),
                  trailing: ProfileSwitch(
                    value: n.enabled,
                    onChanged: (value) => _toggleReminder(n, value),
                  ),
                ),
              ),
              Consumer<ThemeProvider>(
                builder: (context, theme, _) => SettingsRow(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark mode',
                  onTap: theme.toggleTheme,
                  trailing: ProfileSwitch(
                    value: theme.isDarkMode,
                    onChanged: theme.setDarkMode,
                  ),
                ),
              ),
            ],
          ),

          // ---------- Account ----------
          const SettingsSectionLabel('Account'),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.lock_outline,
                title: 'Change password',
                showChevron: true,
                onTap: () => context.pushNamed('change-password'),
              ),
              SettingsRow(
                icon: Icons.badge_outlined,
                title: 'Account ID',
                subtitle: _maskedUid,
                onTap: _copyUserId,
                trailing: Icon(
                  _isCopied ? Icons.check_circle : Icons.copy_outlined,
                  size: 18,
                  color: _isCopied ? Colors.green : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // ---------- Log out ----------
          const SizedBox(height: 16),
          SettingsCard(
            children: [
              SettingsRow(
                icon: Icons.logout,
                title: 'Log out',
                destructive: true,
                onTap: _confirmLogout,
              ),
            ],
          ),

          if (_version != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  'Version $_version',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = profileAccent(context);
    final name = user?.displayName?.trim() ?? '';
    final hasName = name.isNotEmpty;
    final verified = user?.emailVerified ?? false;

    return ProfileCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: accent.withValues(alpha: 0.14),
            child: Text(
              _initials,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasName ? name : 'Add your name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: hasName ? scheme.onSurface : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'No email',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                if (verified)
                  const StatusChip(
                    icon: Icons.check_circle_outline,
                    label: 'Email verified',
                    color: Colors.green,
                  )
                else
                  StatusChip(
                    icon: Icons.mark_email_unread_outlined,
                    label: 'Verify email',
                    color: Colors.orange,
                    onTap: _sendVerificationEmail,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit name',
            onPressed: _editName,
            icon: const Icon(Icons.edit_outlined, size: 20),
            style: IconButton.styleFrom(
              side: BorderSide(color: scheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "NPR 74.4k" style amount for the small stat tile.
String _compactNpr(double value) {
  String trim(double x) {
    final s = x.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  if (value >= 1000000) return 'NPR ${trim(value / 1000000)}M';
  if (value >= 1000) return 'NPR ${trim(value / 1000)}k';
  return formatNpr(value);
}

/// Owns its TextEditingController so it is disposed after the dialog closes.
class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initial});

  final String initial;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your name');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 50,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(labelText: 'Full name', errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
