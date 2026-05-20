// lib/models/meeting_model.dart
class MeetingModel {
  final String id;
  final String projectId;
  final String supervisorId;
  final String studentId;
  final String title;
  final DateTime scheduledDate;
  final String status; // 'scheduled', 'completed', 'cancelled'

  MeetingModel({
    required this.id,
    required this.projectId,
    required this.supervisorId,
    required this.studentId,
    required this.title,
    required this.scheduledDate,
    this.status = 'scheduled',
  });

  factory MeetingModel.fromMap(Map<String, dynamic> data, String id) {
    return MeetingModel(
      id: id,
      projectId: data['projectId'] ?? '',
      supervisorId: data['supervisorId'] ?? '',
      studentId: data['studentId'] ?? '',
      title: data['title'] ?? '',
      scheduledDate: data['scheduledDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['scheduledDate']) 
          : DateTime.now(),
      status: data['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'supervisorId': supervisorId,
      'studentId': studentId,
      'title': title,
      'scheduledDate': scheduledDate.millisecondsSinceEpoch,
      'status': status,
    };
  }
}
