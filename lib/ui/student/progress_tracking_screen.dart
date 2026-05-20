import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/project_model.dart';
import '../../models/progress_model.dart';
import '../../providers/project_provider.dart';
import '../shared/custom_textfield.dart';

class ProgressTrackingScreen extends StatefulWidget {
  final ProjectModel project;
  final bool isEmbedded;
  const ProgressTrackingScreen(
      {super.key, required this.project, this.isEmbedded = false});
  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weekController = TextEditingController();
  final _descController = TextEditingController();
  final _tasksController = TextEditingController();
  late double _progressPercentage;

  @override
  void initState() {
    super.initState();
    _progressPercentage = widget.project.progressPercentage;
  }

  Color _progressColor(double p) {
    if (p < 30) return const Color(0xFFEF4444);
    if (p < 70) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  void _addProgress() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      final tasks = _tasksController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final p = ProgressModel(
        id: const Uuid().v4(),
        projectId: widget.project.id,
        week: _weekController.text.trim(),
        description: _descController.text.trim(),
        completedTasks: tasks,
        dateSubmitted: DateTime.now(),
      );
      final ok = await provider.addProgress(p);
      if (ok) {
        await provider.updateProject(
            widget.project.copyWith(progressPercentage: _progressPercentage));
      }
      if (ok && mounted) {
        _weekController.clear();
        _descController.clear();
        _tasksController.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Progress submitted! ✅'),
          backgroundColor: Color(0xFF10B981),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Submit Form ───────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF0A3D36), const Color(0xFF0C3830)]
                          : [
                              const Color(0xFFE6F7F5),
                              const Color(0xFFF5F3FF)
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9D8A), Color(0xFF14B8A6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF0F9D8A).withOpacity(0.3),
                              blurRadius: 8)
                        ],
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Submit Progress Update',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text('Log your weekly milestone',
                                style: Theme.of(context).textTheme.bodySmall),
                          ]),
                    ),
                  ]),
                ),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'Week (e.g., Week 1)',
                            controller: _weekController,
                            prefixIcon: Icons.calendar_today_rounded,
                            validator: (v) =>
                                v != null && v.isNotEmpty ? null : 'Required',
                          ),
                          CustomTextField(
                            label: 'Description',
                            controller: _descController,
                            prefixIcon: Icons.description_outlined,
                            maxLines: 3,
                            validator: (v) =>
                                v != null && v.isNotEmpty ? null : 'Required',
                          ),
                          CustomTextField(
                            label: 'Completed Tasks (comma-separated)',
                            controller: _tasksController,
                            prefixIcon: Icons.checklist_rounded,
                            validator: (v) =>
                                v != null && v.isNotEmpty ? null : 'Required',
                          ),

                          // Progress Slider
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.speed_rounded,
                                size: 18,
                                color: _progressColor(_progressPercentage)),
                            const SizedBox(width: 8),
                            Text('Overall Progress',
                                style: Theme.of(context).textTheme.titleSmall),
                            const Spacer(),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _progressColor(_progressPercentage)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _progressColor(_progressPercentage)
                                        .withOpacity(0.3)),
                              ),
                              child: Text(
                                '${_progressPercentage.toInt()}%',
                                style: TextStyle(
                                    color: _progressColor(_progressPercentage),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor:
                                  _progressColor(_progressPercentage),
                              thumbColor: _progressColor(_progressPercentage),
                              inactiveTrackColor:
                                  _progressColor(_progressPercentage)
                                      .withOpacity(0.15),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 9),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 18),
                              overlayColor: _progressColor(_progressPercentage)
                                  .withOpacity(0.12),
                            ),
                            child: Slider(
                              value: _progressPercentage,
                              min: 0,
                              max: 100,
                              divisions: 20,
                              onChanged: (v) =>
                                  setState(() => _progressPercentage = v),
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: ['0%', '50%', '100%']
                                  .map((l) => Text(l,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall))
                                  .toList()),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addProgress,
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: const Text('Submit Progress'),
                            ),
                          ),
                        ]),
                  ),
                ),
              ]),
            ).animate().fadeIn(duration: 400.ms),
          ),
        ),

        // ── Timeline Header ───────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F9D8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.timeline_rounded,
                    color: Color(0xFF0F9D8A), size: 16),
              ),
              const SizedBox(width: 10),
              Text('Progress Timeline',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
        ),

        // ── Timeline Stream ───────────────────────────────────
        StreamBuilder<List<ProgressModel>>(
          stream: Provider.of<ProjectProvider>(context, listen: false)
              .getProjectProgress(widget.project.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Center(
                    child:
                        Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(children: [
                      Icon(Icons.timeline_rounded,
                          size: 40,
                          color: const Color(0xFF0F9D8A).withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text('No progress submitted yet',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text('Submit your first weekly update above',
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                ),
              );
            }

            final list = snapshot.data!;
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final progress = list[i];
                  final isLast = i == list.length - 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IntrinsicHeight(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline line + dot
                            SizedBox(
                              width: 30,
                              child: Column(children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0F9D8A),
                                        Color(0xFF14B8A6)
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0xFF0F9D8A)
                                              .withOpacity(0.4),
                                          blurRadius: 8)
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF0F9D8A)
                                                .withOpacity(0.4),
                                            const Color(0xFF0F9D8A)
                                                .withOpacity(0.1),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                              ]),
                            ),
                            const SizedBox(width: 14),

                            // Card
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Theme.of(context).dividerColor),
                                ),
                                child: Column(children: [
                                  // Card header
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        14, 12, 14, 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F9D8A)
                                          .withOpacity(0.06),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Theme.of(context)
                                                  .dividerColor)),
                                    ),
                                    child:
                                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text(progress.week,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  color:
                                                      const Color(0xFF0F9D8A))),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F9D8A)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          DateFormat('MMM dd')
                                              .format(progress.dateSubmitted),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF0F9D8A),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ]),
                                  ),

                                  // Card body
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(progress.description,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(height: 1.5)),
                                          if (progress.completedTasks
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: progress.completedTasks
                                                  .map((t) => Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                                  0xFF10B981)
                                                              .withOpacity(
                                                                  0.08),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          border: Border.all(
                                                              color: const Color(
                                                                      0xFF10B981)
                                                                  .withOpacity(
                                                                      0.25)),
                                                        ),
                                                        child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .check_rounded,
                                                                  size: 11,
                                                                  color: Color(
                                                                      0xFF10B981)),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(t,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Color(
                                                                          0xFF10B981),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                            ]),
                                                      ))
                                                  .toList(),
                                            ),
                                          ],
                                        ]),
                                  ),
                                ]),
                              )
                                  .animate()
                                  .fadeIn(
                                      delay: Duration(milliseconds: 60 * i))
                                  .slideX(begin: 0.05, end: 0),
                            ),
                          ]),
                    ),
                  );
                },
                childCount: list.length,
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );

    if (widget.isEmbedded) return content;
    return Scaffold(
        appBar: AppBar(title: const Text('Progress Tracking')),
        body: content);
  }

  @override
  void dispose() {
    _weekController.dispose();
    _descController.dispose();
    _tasksController.dispose();
    super.dispose();
  }
}
