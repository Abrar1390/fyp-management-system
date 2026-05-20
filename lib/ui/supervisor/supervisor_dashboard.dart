import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../shared/animated_summary_card.dart';
import '../shared/section_header.dart';
import '../shared/project_card.dart';
import '../shared/empty_state_widget.dart';
import 'review_project_screen.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});
  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) Provider.of<ProjectProvider>(context, listen: false).listenToSupervisorProjects(user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ProjectProvider>(builder: (context, pp, _) {
        final projects = pp.projects;
        int pending = projects.where((p) => p.status == 'pending').length;
        int inProgress = projects.where((p) => p.status == 'in_progress').length;
        int completed = projects.where((p) => p.status == 'completed').length;
        int total = projects.length;

        return LayoutBuilder(builder: (context, constraints) {
          int cols = constraints.maxWidth > 800 ? 4 : 2;
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Welcome back,', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                  Text('Dr. ${user.name}', style: Theme.of(context).textTheme.displaySmall),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: Text(DateFormat('MMM dd, yyyy').format(DateTime.now()), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 8),
              Text('You have $total assigned projects', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
              const SizedBox(height: 24),

              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
                children: [
                  AnimatedSummaryCard(title: 'Assigned', value: '$total', icon: Icons.folder_shared, color: const Color(0xFF0F9D8A)),
                  AnimatedSummaryCard(title: 'In Review', value: '$pending', icon: Icons.mark_email_unread_outlined, color: const Color(0xFFEF4444)),
                  AnimatedSummaryCard(title: 'Approved', value: '$inProgress', icon: Icons.check_circle_outline, color: const Color(0xFFF59E0B)),
                  AnimatedSummaryCard(title: 'Completed', value: '$completed', icon: Icons.verified_outlined, color: const Color(0xFF10B981)),
                ],
              ),
              const SizedBox(height: 28),
              const SectionHeader(title: 'Assigned Projects'),
            ]))),

            if (projects.isEmpty)
              SliverToBoxAdapter(child: const EmptyStateWidget(icon: Icons.assignment_ind, title: 'No Students Assigned', subtitle: 'Students will appear here when they assign you as supervisor'))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (ctx, i) => ProjectCard(project: projects[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewProjectScreen(project: projects[i])))),
                  childCount: projects.length,
                )),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ]);
        });
      }),
    );
  }
}
