import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/project_model.dart';
import 'package:intl/intl.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  final int delay;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.delay = 0,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'in_progress':
        return const Color(0xFF0F9D8A);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'IN PROGRESS';
      default:
        return status.toUpperCase().replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(widget.project.status);
    final progress = widget.project.progressPercentage / 100;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 14),
          transform: Matrix4.identity()
            ..translate(0.0, _hovered ? -3.0 : 0.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? statusColor.withOpacity(0.4)
                  : Theme.of(context).dividerColor,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? statusColor.withOpacity(0.12)
                    : (isDark
                        ? Colors.black.withOpacity(0.25)
                        : Colors.black.withOpacity(0.05)),
                blurRadius: _hovered ? 20 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Gradient top accent bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.4)],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(13),
                            border:
                                Border.all(color: statusColor.withOpacity(0.2)),
                          ),
                          child: Icon(_statusIcon(widget.project.status),
                              color: statusColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.project.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: statusColor.withOpacity(0.3),
                                          width: 1),
                                    ),
                                    child: Text(
                                      _statusLabel(widget.project.status),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  if (widget.project.category.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.project.category,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Progress Ring
                        _ProgressRing(
                            progress: progress, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Description
                    Text(
                      widget.project.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),

                    // Technologies
                    if (widget.project.technologies.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            widget.project.technologies.take(4).map((tech) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F9D8A).withOpacity(0.1)
                                  : const Color(0xFFE6F7F5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFF0F9D8A)
                                      .withOpacity(0.2)),
                            ),
                            child: Text(
                              tech,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF0F9D8A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    if (widget.project.technologies.isNotEmpty)
                      const SizedBox(height: 14),

                    // Footer
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('MMM dd, yyyy')
                              .format(widget.project.createdAt),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11),
                        ),
                        if (widget.project.deadline != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.flag_outlined,
                              size: 13,
                              color: _deadlineColor(widget.project.deadline!)),
                          const SizedBox(width: 5),
                          Text(
                            'Due ${DateFormat('MMM dd').format(widget.project.deadline!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: _deadlineColor(widget.project.deadline!),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.5)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: widget.delay))
            .fadeIn(duration: 450.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
      ),
    );
  }

  Color _deadlineColor(DateTime deadline) {
    final days = deadline.difference(DateTime.now()).inDays;
    if (days < 0) return const Color(0xFFEF4444);
    if (days <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final Color color;
  const _ProgressRing({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
