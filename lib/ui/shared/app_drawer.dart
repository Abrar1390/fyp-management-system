import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import 'profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  void _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primary = Theme.of(context).primaryColor;

    return Drawer(
      child: Column(
        children: [
          // Premium profile header
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 24,
                  bottom: 24,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.05),
                  border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: primary,
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user?.role.toUpperCase() ?? '',
                        style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                _buildDrawerItem(context, icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, title: 'Dashboard', index: 0),
                _buildDrawerItem(context, icon: Icons.folder_outlined, activeIcon: Icons.folder_rounded, title: 'Projects', index: 1),
                _buildDrawerItem(context, icon: Icons.timeline_outlined, activeIcon: Icons.timeline_rounded, title: 'Progress', index: 2),
                _buildDrawerItem(context, icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, title: 'Settings', index: 3),
              ],
            ),
          ),

          // Bottom section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Column(
              children: [
                // Theme toggle
                ListTile(
                  dense: true,
                  leading: Icon(
                    themeProvider.currentTheme == ThemeType.light
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: 20,
                  ),
                  title: Text('Toggle Theme', style: Theme.of(context).textTheme.bodyMedium),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () {
                    if (themeProvider.currentTheme == ThemeType.light) {
                      themeProvider.setTheme(ThemeType.dark);
                    } else {
                      themeProvider.setTheme(ThemeType.light);
                    }
                  },
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFEF4444)),
                  title: Text('Sign Out', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFFEF4444))),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        dense: true,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? primary : Theme.of(context).textTheme.bodySmall?.color,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primary : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        selectedTileColor: primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          onItemSelected(index);
          Navigator.pop(context);
        },
      ),
    );
  }
}
