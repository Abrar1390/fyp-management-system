import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/project_model.dart';
import '../../models/feedback_model.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../models/user_model.dart';
import '../shared/custom_textfield.dart';
import '../shared/feedback_card.dart';

class ReviewProjectScreen extends StatefulWidget {
  final ProjectModel project;
  const ReviewProjectScreen({super.key, required this.project});
  @override
  State<ReviewProjectScreen> createState() => _ReviewProjectScreenState();
}

class _ReviewProjectScreenState extends State<ReviewProjectScreen> {
  final _feedbackController = TextEditingController();

  void _updateStatus(String newStatus) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Confirm ${newStatus == 'in_progress' ? 'Approve' : newStatus == 'completed' ? 'Mark Complete' : 'Set Pending'}'),
      content: Text('Are you sure you want to change the status to "${newStatus.replaceAll('_', ' ')}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
      ],
    ));
    if (ok != true) return;

    final pp = Provider.of<ProjectProvider>(context, listen: false);
    ProjectModel updated = widget.project.copyWith(status: newStatus);
    bool success = await pp.updateProject(updated);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to ${newStatus.replaceAll('_', ' ')}'), backgroundColor: const Color(0xFF10B981)));
      Navigator.pop(context);
    }
  }

  void _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) return;
    final pp = Provider.of<ProjectProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    FeedbackModel feedback = FeedbackModel(id: const Uuid().v4(), projectId: widget.project.id, supervisorId: user!.uid, content: _feedbackController.text.trim(), dateGiven: DateTime.now());
    bool success = await pp.addFeedback(feedback);
    if (success && mounted) { _feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback posted!'), backgroundColor: Color(0xFF10B981)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Review Project')),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Project Header
          Text(widget.project.title, style: Theme.of(context).textTheme.headlineSmall).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(widget.project.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // Action Buttons
          Wrap(spacing: 10, runSpacing: 10, children: [
            _actionBtn(Icons.check_circle_outline, 'Approve', const Color(0xFF3B82F6), () => _updateStatus('in_progress')),
            _actionBtn(Icons.verified, 'Complete', const Color(0xFF10B981), () => _updateStatus('completed')),
            _actionBtn(Icons.undo, 'Set Pending', const Color(0xFFF59E0B), () => _updateStatus('pending')),
          ]).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 28),

          // Feedback form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).dividerColor)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Leave Feedback', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              CustomTextField(label: 'Write feedback here...', controller: _feedbackController, maxLines: 3, prefixIcon: Icons.rate_review_outlined),
              Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(onPressed: _submitFeedback, icon: const Icon(Icons.send, size: 16), label: const Text('Post'))),
            ]),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 28),

          // Feedback History
          Text('Feedback History', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          StreamBuilder<List<FeedbackModel>>(
            stream: Provider.of<ProjectProvider>(context, listen: false).getProjectFeedback(widget.project.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return Text('No feedback posted yet.', style: Theme.of(context).textTheme.bodySmall);
              final feedbackList = snapshot.data!;
              final pp = Provider.of<ProjectProvider>(context, listen: false);
              return Column(children: feedbackList.map((fb) {
                final sup = pp.supervisors.firstWhere((s) => s.uid == fb.supervisorId, orElse: () => UserModel(uid: '', name: 'Supervisor', email: '', role: 'supervisor'));
                return FeedbackCard(feedback: fb, supervisorName: 'Dr. ${sup.name}').animate().fadeIn().slideY(begin: 0.05, end: 0);
              }).toList());
            },
          ),
          const SizedBox(height: 28),

          // Student Progress
          Text('Student Progress', style: Theme.of(context).textTheme.titleLarge),
        ]))),

        StreamBuilder<List<ProgressModel>>(
          stream: Provider.of<ProjectProvider>(context, listen: false).getProjectProgress(widget.project.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
            if (!snapshot.hasData || snapshot.data!.isEmpty) return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('No progress reported yet.', style: Theme.of(context).textTheme.bodySmall)));
            final progressList = snapshot.data!;
            return SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
              final progress = progressList[i];
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(progress.week, style: Theme.of(context).textTheme.titleMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                      child: Text(DateFormat('MMM dd').format(progress.dateSubmitted), style: TextStyle(fontSize: 11, color: primary)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(progress.description, style: Theme.of(context).textTheme.bodyMedium),
                  if (progress.completedTasks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, children: progress.completedTasks.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 11)), padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)).toList()),
                  ],
                ]),
              ));
            }, childCount: progressList.length));
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed, icon: Icon(icon, size: 18), label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
    );
  }

  @override
  void dispose() { _feedbackController.dispose(); super.dispose(); }
}
