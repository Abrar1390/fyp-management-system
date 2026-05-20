import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../shared/animated_summary_card.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome, Admin', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(),
        if (user != null) Text(user.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
          children: const [
            AnimatedSummaryCard(title: 'Total Users', value: '—', icon: Icons.people, color: Color(0xFF0F9D8A)),
            AnimatedSummaryCard(title: 'Total Projects', value: '—', icon: Icons.folder_rounded, color: Color(0xFF10B981)),
            AnimatedSummaryCard(title: 'Supervisors', value: '—', icon: Icons.supervisor_account, color: Color(0xFFF59E0B)),
            AnimatedSummaryCard(title: 'Completed', value: '—', icon: Icons.verified, color: Color(0xFF3B82F6)),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).dividerColor)),
          child: Column(children: [
            Icon(Icons.admin_panel_settings, size: 48, color: Theme.of(context).primaryColor.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('Admin Panel', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('User management and system statistics will be available here in a future update.', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ]),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}
