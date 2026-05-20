// lib/models/project_model.dart
class ProjectModel {
  final String id;
  final String title;
  final String description;
  final List<String> technologies;
  final String studentId;
  final String? supervisorId;
  final String? supervisorName;
  final String status; // 'pending', 'in_progress', 'completed'
  final DateTime createdAt;
  final double progressPercentage;
  final String category;
  final DateTime? deadline;
  final List<String> documentUrls;
  final List<String> teamMembers;
  final List<String> milestones;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.studentId,
    this.supervisorId,
    this.supervisorName,
    required this.status,
    required this.createdAt,
    this.progressPercentage = 0.0,
    this.category = 'General',
    this.deadline,
    this.documentUrls = const [],
    this.teamMembers = const [],
    this.milestones = const [],
  });

  factory ProjectModel.fromMap(Map<String, dynamic> data, String id) {
    return ProjectModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      technologies: List<String>.from(data['technologies'] ?? []),
      studentId: data['studentId'] ?? '',
      supervisorId: data['supervisorId'],
      supervisorName: data['supervisorName'],
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'General',
      deadline: data['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['deadline'])
          : null,
      documentUrls: List<String>.from(data['documentUrls'] ?? []),
      teamMembers: List<String>.from(data['teamMembers'] ?? []),
      milestones: List<String>.from(data['milestones'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'technologies': technologies,
      'studentId': studentId,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'progressPercentage': progressPercentage,
      'category': category,
      'deadline': deadline?.millisecondsSinceEpoch,
      'documentUrls': documentUrls,
      'teamMembers': teamMembers,
      'milestones': milestones,
    };
  }

  ProjectModel copyWith({
    String? title,
    String? description,
    List<String>? technologies,
    String? supervisorId,
    String? supervisorName,
    String? status,
    double? progressPercentage,
    String? category,
    DateTime? deadline,
    List<String>? documentUrls,
    List<String>? teamMembers,
    List<String>? milestones,
  }) {
    return ProjectModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      studentId: studentId,
      supervisorId: supervisorId ?? this.supervisorId,
      supervisorName: supervisorName ?? this.supervisorName,
      status: status ?? this.status,
      createdAt: createdAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      documentUrls: documentUrls ?? this.documentUrls,
      teamMembers: teamMembers ?? this.teamMembers,
      milestones: milestones ?? this.milestones,
    );
  }
}
