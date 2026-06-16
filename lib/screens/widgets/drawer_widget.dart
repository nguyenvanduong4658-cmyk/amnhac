import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/player_service.dart';
import '../auth/register_screen.dart';
import '../page/profile_screen.dart';
import '../page/recently_played_screen.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  void _showSwitchAccountsSheet(BuildContext context) {
    final player = PlayerService();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: AnimatedBuilder(
              animation: player,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Chuyển tài khoản",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: player.savedAccounts.length,
                        itemBuilder: (context, i) {
                          final accStr = player.savedAccounts[i];
                          final parts = accStr.split('|');
                          final name = parts[0];
                          final email = parts[1];
                          final path = (parts.length >= 5 && parts[3] != "null" && parts[3].isNotEmpty) ? parts[3] : null;

                          final isActive = player.userEmail.toLowerCase() == email.toLowerCase();
                          final initialLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFE84E36),
                              backgroundImage: (path != null && path != 'null')
                                  ? (path.startsWith('http')
                                      ? NetworkImage(path)
                                      : FileImage(File(path)) as ImageProvider)
                                  : null,
                              child: path == null
                                  ? Text(initialLetter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                  : null,
                            ),
                            title: Text(name, style: TextStyle(color: Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                            subtitle: Text(email, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            trailing: isActive
                                ? const Icon(Icons.check, color: Color(0xFF1ED760))
                                : IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () async {
                                      await player.removeAccount(email);
                                    },
                                  ),
                            onTap: () async {
                              await player.switchAccount(email);
                              if (context.mounted) {
                                Navigator.pop(context); // Close sheet
                                Navigator.pop(context); // Close drawer
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Đã chuyển sang tài khoản: $name"),
                                    backgroundColor: const Color(0xFF1ED760),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerService();

    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: player,
          builder: (context, child) {
            final initialLetter = player.userName.isNotEmpty
                ? player.userName[0].toUpperCase()
                : 'D';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drawer Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFFE84E36),
                        backgroundImage: (player.userImagePath != null && player.userImagePath != 'null')
                            ? (player.userImagePath!.startsWith('http')
                                ? NetworkImage(player.userImagePath!)
                                : FileImage(File(player.userImagePath!)) as ImageProvider)
                            : null,
                        child: player.userImagePath == null
                            ? Text(
                                initialLetter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                                );
                              },
                              child: const Text(
                                "Xem hồ sơ",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 16),

                // Menu items
                _buildDrawerItem(
                  icon: Icons.add,
                  title: "Thêm tài khoản",
                  onTap: () {
                    Navigator.pop(context); // Close Drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(isAddingAccount: true),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: "Gần đây",
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RecentlyPlayedPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.campaign_outlined,
                  title: "Tin cập nhật",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: "Cài đặt và quyền riêng tư",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                ),

                const Spacer(),

                // Bottom Left Account Switch Icon
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                  child: GestureDetector(
                    onTap: () => _showSwitchAccountsSheet(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      onTap: onTap,
    );
  }
}