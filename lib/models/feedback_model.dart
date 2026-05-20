// lib/models/feedback_model.dart
class FeedbackModel {
  final String id;
  final String projectId;
  final String supervisorId;
  final String content;
  final DateTime dateGiven;

  FeedbackModel({
    required this.id,
    required this.projectId,
    required this.supervisorId,
    required this.content,
    required this.dateGiven,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> data, String id) {
    return FeedbackModel(
      id: id,
      projectId: data['projectId'] ?? '',
      supervisorId: data['supervisorId'] ?? '',
      content: data['content'] ?? '',
      dateGiven: data['dateGiven'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['dateGiven']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'supervisorId': supervisorId,
      'content': content,
      'dateGiven': dateGiven.millisecondsSinceEpoch,
    };
  }
}
