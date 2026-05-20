// lib/models/task_model.dart
class TaskModel {
  final String id;
  final String projectId;
  final String title;
  final bool isCompleted;
  final double weight; // Percentage this task contributes to the whole project (e.g., 10.0 for 10%)

  TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.isCompleted = false,
    this.weight = 10.0,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String id) {
    return TaskModel(
      id: id,
      projectId: data['projectId'] ?? '',
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      weight: (data['weight'] ?? 10.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'title': title,
      'isCompleted': isCompleted,
      'weight': weight,
    };
  }
}
