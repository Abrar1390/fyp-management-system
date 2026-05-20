import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../shared/animated_summary_card.dart';
import '../shared/empty_state_widget.dart';
import '../shared/project_card.dart';
import 'add_project_screen.dart';
import 'project_details_screen.dart';
import '../../models/feedback_model.dart';
import '../../models/user_model.dart';
import '../shared/feedback_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<ProjectProvider>(context, listen: false)
            .listenToStudentProjects(user.uid);
      }
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ProjectProvider>(builder: (context, pp, _) {
        final projects = pp.projects;
        final total = projects.length;
        final completed = projects.where((p) => p.status == 'completed').length;
        final inProgress = projects.where((p) => p.status == 'in_progress').length;
        final pending = projects.where((p) => p.status == 'pending').length;
        final avgProgress = total > 0
            ? projects.map((p) => p.progressPercentage).reduce((a, b) => a + b) / total
            : 0.0;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero Welcome Banner ──────────────────────────────
            SliverToBoxAdapter(
              child: _HeroBanner(
                greeting: _greeting(),
                userName: user.name,
                avgProgress: avgProgress,
                total: total,
                completed: completed,
                isDark: isDark,
              ),
            ),

            // ── KPI Grid ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: LayoutBuilder(builder: (context, constraints) {
                  final cols = constraints.maxWidth > 700 ? 4 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: constraints.maxWidth > 700 ? 1.55 : 1.45,
                    children: [
                      AnimatedSummaryCard(
                        title: 'Total Projects', value: '$total',
                        icon: Icons.folder_rounded,
                        color: const Color(0xFF0F9D8A), delay: 0,
                      ),
                      AnimatedSummaryCard(
                        title: 'Completed', value: '$completed',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981), delay: 80,
                      ),
                      AnimatedSummaryCard(
                        title: 'In Progress', value: '$inProgress',
                        icon: Icons.autorenew_rounded,
                        color: const Color(0xFF14B8A6), delay: 160,
                      ),
                      AnimatedSummaryCard(
                        title: 'Pending', value: '$pending',
                        icon: Icons.hourglass_top_rounded,
                        color: const Color(0xFFF59E0B), delay: 240,
                      ),
                    ],
                  );
                }),
              ),
            ),

            // ── Analytics + Deadlines ────────────────────────────
            if (total > 0) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final wide = constraints.maxWidth > 640;
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _AnalyticsChart(
                              completed: completed,
                              inProgress: inProgress,
                              pending: pending,
                              avgProgress: avgProgress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _DeadlinesCard(projects: projects),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _AnalyticsChart(
                          completed: completed,
                          inProgress: inProgress,
                          pending: pending,
                          avgProgress: avgProgress,
                        ),
                        const SizedBox(height: 16),
                        _DeadlinesCard(projects: projects),
                      ],
                    );
                  }),
                ),
              ),
            ],

            // ── Recent Feedback ──────────────────────────────────
            if (projects.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _SectionLabel(
                    title: 'Recent Feedback',
                    icon: Icons.feedback_rounded,
                    iconColor: const Color(0xFF0F9D8A),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: StreamBuilder<List<FeedbackModel>>(
                    stream: pp.getFeedbackForProjects(
                        projects.map((p) => p.id).toList()),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _NoFeedbackCard();
                      }
                      return Column(
                        children: snapshot.data!.take(2).map((fb) {
                          final sup = pp.supervisors.firstWhere(
                            (s) => s.uid == fb.supervisorId,
                            orElse: () => UserModel(
                                uid: '', name: 'Supervisor', email: '', role: 'supervisor'),
                          );
                          final proj = projects.firstWhere(
                            (p) => p.id == fb.projectId,
                            orElse: () => projects.first,
                          );
                          return FeedbackCard(
                            feedback: fb,
                            supervisorName: sup.name,
                            projectName: proj.title,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],



            // ── Your Projects ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _SectionLabel(
                  title: 'Your Projects',
                  icon: Icons.folder_special_rounded,
                  iconColor: const Color(0xFF0F9D8A),
                  trailing: projects.isNotEmpty
                      ? TextButton(
                          onPressed: () {},
                          child: const Text('View all',
                              style: TextStyle(fontSize: 13)),
                        )
                      : null,
                ),
              ),
            ),

            if (projects.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: EmptyStateWidget(
                    icon: Icons.folder_open_rounded,
                    title: 'No Projects Yet',
                    subtitle: 'Create your first FYP project to get started',
                    actionLabel: 'New Project',
                    onAction: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AddProjectScreen())),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => ProjectCard(
                      project: projects[i],
                      delay: i * 60,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProjectDetailsScreen(project: projects[i])),
                      ),
                    ),
                    childCount: projects.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddProjectScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project'),
      ),
    );
  }
}

// ─── Hero Banner ─────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String greeting;
  final String userName;
  final double avgProgress;
  final int total;
  final int completed;
  final bool isDark;

  const _HeroBanner({
    required this.greeting,
    required this.userName,
    required this.avgProgress,
    required this.total,
    required this.completed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0A3D36), const Color(0xFF0D4A40)]
              : [const Color(0xFF0F9D8A), const Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F9D8A).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting 👋',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    total == 0
                        ? 'Start your first project to track your FYP journey 🚀'
                        : 'You\'ve completed ${avgProgress.toStringAsFixed(0)}% of your project milestones. Keep going! 💪',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                if (total > 0) ...[
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(
                        '$completed/$total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'done',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.05, end: 0);
  }
}

// ─── Analytics Chart ──────────────────────────────────────────────────────────

class _AnalyticsChart extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int pending;
  final double avgProgress;

  const _AnalyticsChart({
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.avgProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barGroups = <BarChartGroupData>[
      _bar(0, completed.toDouble(), const Color(0xFF10B981)),
      _bar(1, inProgress.toDouble(), const Color(0xFF0F9D8A)),
      _bar(2, pending.toDouble(), const Color(0xFFF59E0B)),
    ];
    final maxY = [completed, inProgress, pending]
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('Project Overview',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F9D8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${avgProgress.toStringAsFixed(0)}% avg',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0F9D8A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                maxY: maxY == 0 ? 5 : maxY + 1,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const labels = ['Done', 'Active', 'Pending'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[v.toInt()],
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(enabled: false),
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Legend('Completed', const Color(0xFF10B981)),
              _Legend('In Progress', const Color(0xFF0F9D8A)),
              _Legend('Pending', const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y == 0 ? 0.15 : y,
        color: color,
        width: 36,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      )
    ]);
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
    ]);
  }
}

// ─── Deadlines Card ────────────────────────────────────────────────────────────

class _DeadlinesCard extends StatelessWidget {
  final List projects;
  const _DeadlinesCard({required this.projects});

  @override
  Widget build(BuildContext context) {
    final upcoming = projects
        .where((p) => p.deadline != null && p.deadline!.isAfter(DateTime.now()))
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('📅', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('Deadlines', style: Theme.of(context).textTheme.titleMedium),
          ]),
          const SizedBox(height: 14),
          if (upcoming.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No upcoming deadlines',
                  style: Theme.of(context).textTheme.bodySmall),
            )
          else
            ...upcoming.map((p) {
              final days = p.deadline!.difference(DateTime.now()).inDays;
              final color = days <= 3
                  ? const Color(0xFFEF4444)
                  : days <= 7
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF10B981);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(children: [
                  Icon(Icons.flag_rounded, color: color, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.title,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${days}d left',
                          style: TextStyle(
                              fontSize: 11, color: color, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ]),
              );
            }),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }
}



// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;

  const _SectionLabel({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 16),
      ),
      const SizedBox(width: 10),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700, letterSpacing: -0.2)),
      if (trailing != null) ...[const Spacer(), trailing!],
    ]);
  }
}

class _NoFeedbackCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(children: [
        Icon(Icons.feedback_outlined,
            color: Theme.of(context).textTheme.bodySmall?.color, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(
          'No feedback yet. Submit progress updates to receive feedback from your supervisor.',
          style: Theme.of(context).textTheme.bodySmall,
        )),
      ]),
    );
  }
}
