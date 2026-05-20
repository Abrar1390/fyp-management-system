import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/project_model.dart';
import '../../models/feedback_model.dart';
import '../../models/user_model.dart';
import '../../providers/project_provider.dart';
import '../shared/feedback_card.dart';
import '../shared/empty_state_widget.dart';
import 'progress_tracking_screen.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final ProjectModel project;
  const ProjectDetailsScreen({super.key, required this.project});

  Color _statusColor(String s) {
    switch (s) {
      case 'completed': return const Color(0xFF10B981);
      case 'in_progress': return const Color(0xFF0F9D8A);
      default: return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(project.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (v) => _handleAction(context, v),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 18),
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                            dense: true,
                            leading: Icon(Icons.delete_rounded, size: 18, color: Color(0xFFEF4444)),
                            title: Text('Delete', style: TextStyle(color: Color(0xFFEF4444))))),
                  ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(isDark ? 0.6 : 1.0),
                        const Color(0xFF0F9D8A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            _StatusChip(project.status.replaceAll('_', ' ').toUpperCase(),
                                Colors.white.withOpacity(0.25), Colors.white),
                            const SizedBox(width: 8),
                            if (project.category.isNotEmpty)
                              _StatusChip(project.category, Colors.white.withOpacity(0.2), Colors.white70),
                          ]),
                          const SizedBox(height: 8),
                          Text(
                            project.title,
                            style: const TextStyle(
                              color: Colors.white, fontSize: 20,
                              fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.2,
                            ),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: project.progressPercentage / 100,
                                  minHeight: 5,
                                  backgroundColor: Colors.white.withOpacity(0.25),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${project.progressPercentage.toInt()}%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: const TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(icon: Icon(Icons.info_outline_rounded, size: 17), text: 'Overview'),
                      Tab(icon: Icon(Icons.timeline_rounded, size: 17), text: 'Progress'),
                      Tab(icon: Icon(Icons.feedback_outlined, size: 17), text: 'Feedback'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(project: project),
              ProgressTrackingScreen(project: project, isEmbedded: true),
              _FeedbackTab(project: project),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) async {
    if (action == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('This will permanently delete this project and all its data.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                child: const Text('Delete')),
          ],
        ),
      );
      if (ok == true && context.mounted) {
        await Provider.of<ProjectProvider>(context, listen: false).deleteProject(project.id);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;
  const _StatusChip(this.text, this.bg, this.textColor);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final ProjectModel project;
  const _OverviewTab({required this.project});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _InfoCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _RowLabel(Icons.description_outlined, 'Description', const Color(0xFF0F9D8A)),
            const SizedBox(height: 10),
            Text(project.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
          ]),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 12),

        if (project.technologies.isNotEmpty)
          _InfoCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _RowLabel(Icons.code_rounded, 'Technologies', const Color(0xFF0EA5E9)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: project.technologies.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0F9D8A).withOpacity(0.25)),
                  ),
                  child: Text(t, style: const TextStyle(fontSize: 12, color: Color(0xFF0F9D8A), fontWeight: FontWeight.w600)),
                )).toList(),
              ),
            ]),
          ).animate().fadeIn(delay: 180.ms),

        if (project.supervisorName != null) ...[
          const SizedBox(height: 12),
          _InfoCard(
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0F9D8A),
                child: Text(project.supervisorName![0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Supervisor', style: Theme.of(context).textTheme.bodySmall),
                Text(project.supervisorName!, style: Theme.of(context).textTheme.titleMedium),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: const Text('Active',
                    style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
              ),
            ]),
          ).animate().fadeIn(delay: 260.ms),
        ],

        if (project.deadline != null) ...[
          const SizedBox(height: 12),
          _InfoCard(
            child: Row(children: [
              Expanded(child: _InfoTile(
                icon: Icons.calendar_today_outlined,
                label: 'Created',
                value: DateFormat('MMM dd, yyyy').format(project.createdAt),
                color: const Color(0xFF0F9D8A),
              )),
              Container(width: 1, height: 44, color: Theme.of(context).dividerColor),
              Expanded(child: _InfoTile(
                icon: Icons.flag_outlined,
                label: 'Deadline',
                value: DateFormat('MMM dd, yyyy').format(project.deadline!),
                color: const Color(0xFFF59E0B),
              )),
            ]),
          ).animate().fadeIn(delay: 340.ms),
        ],

        const SizedBox(height: 40),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: child,
      );
}

class _RowLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _RowLabel(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
          child: Icon(icon, color: color, size: 13),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleSmall),
      ]);
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoTile({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ]),
      );
}



// ─── Feedback Tab ─────────────────────────────────────────────────────────────

class _FeedbackTab extends StatelessWidget {
  final ProjectModel project;
  const _FeedbackTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<ProjectProvider>(context, listen: false);
    return StreamBuilder<List<FeedbackModel>>(
      stream: pp.getProjectFeedback(project.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.feedback_outlined,
            title: 'No Feedback Yet',
            subtitle: 'Submit progress updates to receive feedback from your supervisor',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (ctx, i) {
            final fb = snapshot.data![i];
            final sup = pp.supervisors.firstWhere(
              (s) => s.uid == fb.supervisorId,
              orElse: () => UserModel(uid: '', name: 'Supervisor', email: '', role: 'supervisor'),
            );
            return FeedbackCard(
              feedback: fb,
              supervisorName: sup.name,
              projectName: project.title,
            ).animate().fadeIn(delay: Duration(milliseconds: 100 * i));
          },
        );
      },
    );
  }
}
