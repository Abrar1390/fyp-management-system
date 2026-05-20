// lib/models/progress_model.dart
class ProgressModel {
  final String id;
  final String projectId;
  final String week; // e.g., 'Week 1'
  final String description;
  final List<String> completedTasks;
  final DateTime dateSubmitted;

  ProgressModel({
    required this.id,
    required this.projectId,
    required this.week,
    required this.description,
    required this.completedTasks,
    required this.dateSubmitted,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> data, String id) {
    return ProgressModel(
      id: id,
      projectId: data['projectId'] ?? '',
      week: data['week'] ?? '',
      description: data['description'] ?? '',
      completedTasks: List<String>.from(data['completedTasks'] ?? []),
      dateSubmitted: data['dateSubmitted'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['dateSubmitted']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'week': week,
      'description': description,
      'completedTasks': completedTasks,
      'dateSubmitted': dateSubmitted.millisecondsSinceEpoch,
    };
  }
}
