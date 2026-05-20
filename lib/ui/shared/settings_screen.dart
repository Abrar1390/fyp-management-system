import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Header ─────────────────────────────────────────
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F9D8A), Color(0xFF10B981)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: const Color(0xFF0F9D8A).withOpacity(0.3), blurRadius: 12)],
              ),
              child: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              Text('Customize your experience',
                  style: Theme.of(context).textTheme.bodySmall),
            ])),
          ]).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 28),

          // ── Appearance ────────────────────────────────────
          _sectionLabel(context, 'Appearance', Icons.palette_outlined, const Color(0xFF0F9D8A)),
          const SizedBox(height: 12),

          // Two theme cards: Light and Dark (no more three)
          Row(children: [
            _ThemeCard(
              label: 'Light',
              icon: Icons.light_mode_rounded,
              isSelected: themeProvider.currentTheme == ThemeType.light,
              selectedColor: const Color(0xFF0F9D8A),
              bg: const Color(0xFFF8FAFC),
              textColor: const Color(0xFF0F172A),
              onTap: () => themeProvider.setTheme(ThemeType.light),
            ),
            const SizedBox(width: 12),
            // "Dark" now maps to ThemeType.black (AMOLED/true dark)
            _ThemeCard(
              label: 'Dark',
              icon: Icons.dark_mode_rounded,
              isSelected: themeProvider.currentTheme == ThemeType.dark ||
                  themeProvider.currentTheme == ThemeType.black,
              selectedColor: const Color(0xFF14B8A6),
              bg: const Color(0xFF0B0F1A),
              textColor: Colors.white,
              onTap: () => themeProvider.setTheme(ThemeType.dark),
            ),
          ]).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          // ── Account ───────────────────────────────────────
          _sectionLabel(context, 'Account', Icons.manage_accounts_outlined, const Color(0xFF0EA5E9)),
          const SizedBox(height: 12),
          _card(context, [
            _infoTile(context,
                icon: Icons.email_outlined, iconColor: const Color(0xFF0F9D8A),
                title: 'Email Address', value: user?.email ?? ''),
            _divider(context),
            _infoTile(context,
                icon: Icons.badge_outlined, iconColor: const Color(0xFF10B981),
                title: 'Role', value: user?.role.toUpperCase() ?? ''),
            _divider(context),
            _infoTile(context,
                icon: Icons.fingerprint_rounded, iconColor: const Color(0xFF14B8A6),
                title: 'User ID', value: user?.uid.substring(0, 12) ?? '—', mono: true),
          ]).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),

          // ── Notifications ─────────────────────────────────
          _sectionLabel(context, 'Notifications', Icons.notifications_outlined, const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _card(context, [
            _toggleTile(context,
                icon: Icons.feedback_outlined, iconColor: const Color(0xFFEC4899),
                title: 'Supervisor Feedback',
                subtitle: 'Get notified when supervisor adds feedback',
                value: true, onChanged: (_) {}),
            _divider(context),
            _toggleTile(context,
                icon: Icons.event_rounded, iconColor: const Color(0xFFF59E0B),
                title: 'Deadline Reminders',
                subtitle: 'Alerts before project deadlines',
                value: true, onChanged: (_) {}),
            _divider(context),
            _toggleTile(context,
                icon: Icons.check_circle_outline_rounded, iconColor: const Color(0xFF10B981),
                title: 'Progress Updates',
                subtitle: 'Confirmation when progress is submitted',
                value: false, onChanged: (_) {}),
          ]).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),

          // ── About ─────────────────────────────────────────
          _sectionLabel(context, 'About', Icons.info_outline_rounded, const Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          _card(context, [
            _infoTile(context,
                icon: Icons.rocket_launch_rounded, iconColor: const Color(0xFF0F9D8A),
                title: 'Version', value: '1.0.0'),
            _divider(context),
            _infoTile(context,
                icon: Icons.flutter_dash_rounded, iconColor: const Color(0xFF0EA5E9),
                title: 'Built with', value: 'Flutter + Firebase'),
          ]).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),

          // ── Sign Out (no "Danger Zone" label) ─────────────
          _card(context, [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
              ),
              title: const Text('Sign Out',
                  style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
              subtitle: Text('You will be returned to login',
                  style: Theme.of(context).textTheme.bodySmall),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFEF4444), size: 20),
              onTap: () => _confirmLogout(context),
            ),
          ]).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Sign Out')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        );
      }
    }
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _sectionLabel(BuildContext context, String title, IconData icon, Color color) {
  return Row(children: [
    Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 14),
    ),
    const SizedBox(width: 8),
    Text(title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w600)),
  ]);
}

Widget _card(BuildContext context, List<Widget> children) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(children: children),
    ),
  );
}

Widget _infoTile(BuildContext context,
    {required IconData icon, required Color iconColor,
     required String title, required String value, bool mono = false}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor, size: 18),
    ),
    title: Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
    subtitle: Text(value,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontFamily: mono ? 'monospace' : null, fontWeight: FontWeight.w600)),
  );
}

Widget _toggleTile(BuildContext context,
    {required IconData icon, required Color iconColor,
     required String title, required String subtitle,
     required bool value, required ValueChanged<bool> onChanged}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor, size: 18),
    ),
    title: Text(title, style: Theme.of(context).textTheme.titleSmall),
    subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    trailing: Switch(value: value, onChanged: onChanged),
  );
}

Widget _divider(BuildContext context) =>
    Divider(height: 1, color: Theme.of(context).dividerColor);

class _ThemeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final Color bg;
  final Color textColor;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.bg,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? selectedColor : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: selectedColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: isSelected ? selectedColor : textColor, size: 26),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  color: isSelected ? selectedColor : textColor,
                  fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                )),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                width: 20, height: 3,
                decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
