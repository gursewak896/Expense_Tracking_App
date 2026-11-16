import 'package:expense_app/core/providers/transaction_provider.dart';
import 'package:expense_app/core/providers/theme_provider.dart';
import 'package:expense_app/core/theme/app_colors.dart';
import 'package:expense_app/features/home_expense/presentation/screens/change_pw_screen.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool notifications = true;
  bool darkMode = false;
  User? user;
  bool isCopied = false;
  bool showIcon = false;

  String get maskedUid {
    final id = user?.uid ?? "No UID";
    if (id.length < 10) return id;
    return "${id.substring(0, 4)}****${id.substring(id.length - 4)}";
  }

  String get joinedDate {
    final date = user?.metadata.creationTime;
    if (date == null) return "Unknown";

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  void copyUserIdToClipboard() {
    final uid = user?.uid ?? "";
    if (uid.isEmpty) return;

    Clipboard.setData(ClipboardData(text: uid));

    setState(() {
      isCopied = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isCopied = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 16),
        ],
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ================= PROFILE IMAGE =================
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= NAME =================
            Text(
              user?.displayName ?? "No name",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // ================= EMAIL =================
            Text(
              user?.email ?? "No Email",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            // ================= STATUS CHIP =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.indigo),
                  SizedBox(width: 6),
                  Text(
                    "ACTIVE USER",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= INFO CARD =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _infoRow("Membership", "Joined on $joinedDate", "VERIFIED",
                      Icons.info, false),
                  const Divider(height: 24),
                  _infoRow("User Identification", maskedUid, "COPY", Icons.copy,
                      true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= SETTINGS TITLE =================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "ACCOUNT SETTINGS",
                  style: TextStyle(
                    letterSpacing: 1.2,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            _buildTile(Icons.edit, "Edit Profile"),
            _buildTile(
              Icons.lock,
              "Change Password",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),

            CustomListTile(
                title: const Text("Notifications"),
                darkMode: darkMode,
                icon: Icons.notifications,
                value: notifications,
                onChanged: (val) {
                  setState(() {
                    notifications = val;
                  });
                }),
            // CustomListTile(
            //     title: const Text("Dark Mode"),
            //     darkMode: darkMode,
            //     icon: Icons.dark_mode,
            //     value: darkMode,
            //     onChanged: (val) {
            //       setState(() {
            //         darkMode = val;
            //       });
            //     }),
            const SizedBox(height: 14),

            // ================= LOGOUT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text(
                            'Log Out',
                            style: TextStyle(
                              color: Theme.of(dialogContext)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: Text(
                            'Do you really want to log out?',
                            style: TextStyle(
                              color: Theme.of(dialogContext)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Theme.of(dialogContext)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                final themeProvider =
                                    context.read<ThemeProvider>();
                                final transactionProvider =
                                    context.read<TransactionProvider>();

                                await themeProvider.setDarkMode(false);
                                await transactionProvider
                                    .clearLocalTransactions();

                                await FirebaseAuth.instance.signOut();
                                navigator.pop();
                              },
                              child: const Text(
                                'Log Out',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Log Out"),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // const Text(
            //   "VERSION 4.2.0-INDIGO",
            //   style: TextStyle(color: Colors.grey, fontSize: 12),
            // ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= INFO ROW =================
  Widget _infoRow(
      String title, String value, String badge, IconData? icon, bool showIcon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(width: 4),
                showIcon
                    ? IconButton(
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isCopied ? Icons.check_circle : icon ?? Icons.copy,
                          color: isCopied
                              ? Colors.green
                              : isDark
                                  ? Colors.white54
                                  : Colors.black38,
                          size: 18,
                        ),
                        onPressed: copyUserIdToClipboard,
                        tooltip: "Copy User ID",
                      )
                    : Container(),
              ],
            ),
          ],
        ),
        showIcon
            ? Container()
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              )
      ],
    );
  }

  // ================= TILE =================
  Widget _buildTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    );
  }
}
