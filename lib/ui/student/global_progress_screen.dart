import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/project_provider.dart';
import '../../models/project_model.dart';
import 'progress_tracking_screen.dart';

class GlobalProgressScreen extends StatefulWidget {
  const GlobalProgressScreen({super.key});
  @override
  State<GlobalProgressScreen> createState() => _GlobalProgressScreenState();
}

class _GlobalProgressScreenState extends State<GlobalProgressScreen> {
  String? _selectedProjectId;

  Color _progressColor(double p) {
    if (p < 30) return const Color(0xFFEF4444);
    if (p < 70) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(builder: (context, pp, _) {
      final projects = pp.projects;

      if (projects.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F9D8A), Color(0xFF14B8A6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF0F9D8A).withOpacity(0.3),
                        blurRadius: 20)
                  ],
                ),
                child: const Icon(Icons.timeline_rounded,
                    size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text('No Projects Yet',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Create a project to track your progress',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ).animate().fadeIn(),
        );
      }

      // Single project
      if (projects.length == 1) {
        return ProgressTrackingScreen(
          key: ValueKey('progress_${projects.first.id}_${projects.first.progressPercentage}'),
          project: projects.first,
          isEmbedded: true,
        );
      }

      // Multi-project: find selected
      ProjectModel? selectedProject;
      if (_selectedProjectId != null) {
        try {
          selectedProject =
              projects.firstWhere((p) => p.id == _selectedProjectId);
        } catch (_) {
          _selectedProjectId = null;
        }
      }

      return Column(children: [
        // ── Premium Project Selector ──────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text('Select Project',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color:
                            Theme.of(context).textTheme.bodySmall?.color)),
              ),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  itemCount: projects.length,
                  itemBuilder: (ctx, i) {
                    final p = projects[i];
                    final sel = _selectedProjectId == p.id;
                    final color = _progressColor(p.progressPercentage);

                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedProjectId = p.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFF0F9D8A).withOpacity(0.1)
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sel
                                ? const Color(0xFF0F9D8A)
                                : Theme.of(context).dividerColor,
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 38,
                                height: 38,
                                child: CircularProgressIndicator(
                                  value: p.progressPercentage / 100,
                                  strokeWidth: 3,
                                  backgroundColor: color.withOpacity(0.15),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Text(
                                '${p.progressPercentage.toInt()}%',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: color),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          color: sel
                                              ? const Color(0xFF0F9D8A)
                                              : null),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text(
                                  p.status.replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: color,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.05, end: 0),

        // ── Progress Content ──────────────────────────────────
        Expanded(
          child: selectedProject == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 48,
                          color: const Color(0xFF0F9D8A).withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('Select a project above',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color)),
                    ],
                  ).animate().fadeIn(),
                )
              : ProgressTrackingScreen(
                  key: ValueKey(
                      'progress_${selectedProject.id}_${selectedProject.progressPercentage}'),
                  project: selectedProject,
                  isEmbedded: true,
                ),
        ),
      ]);
    });
  }
}
