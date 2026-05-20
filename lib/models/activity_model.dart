// lib/models/activity_model.dart
class ActivityModel {
  final String id;
  final String userId;
  final String action; // 'project_created', 'progress_submitted', 'file_uploaded', 'feedback_received', 'status_changed'
  final String description;
  final DateTime timestamp;
  final String? projectId;
  final String? projectTitle;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.description,
    required this.timestamp,
    this.projectId,
    this.projectTitle,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> data, String id) {
    return ActivityModel(
      id: id,
      userId: data['userId'] ?? '',
      action: data['action'] ?? '',
      description: data['description'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
          : DateTime.now(),
      projectId: data['projectId'],
      projectTitle: data['projectTitle'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'action': action,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'projectId': projectId,
      'projectTitle': projectTitle,
    };
  }
}
