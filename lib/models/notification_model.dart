// lib/models/notification_model.dart
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'feedback', 'approval', 'upload', 'deadline', 'status_change'
  final bool isRead;
  final DateTime createdAt;
  final String? relatedProjectId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.relatedProjectId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      relatedProjectId: data['relatedProjectId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'relatedProjectId': relatedProjectId,
    };
  }
}
