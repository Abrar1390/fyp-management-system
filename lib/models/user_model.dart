// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student', 'supervisor', or 'admin'
  final String? profilePictureUrl;
  final String? department;
  final String? semester;
  final List<String> skills;
  final List<String> achievements;
  final String? bio;
  final String? github;
  final String? linkedin;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profilePictureUrl,
    this.department,
    this.semester,
    this.skills = const [],
    this.achievements = const [],
    this.bio,
    this.github,
    this.linkedin,
    this.phone,
    this.createdAt,
    this.lastActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      profilePictureUrl: data['profilePictureUrl'],
      department: data['department'],
      semester: data['semester'],
      skills: List<String>.from(data['skills'] ?? []),
      achievements: List<String>.from(data['achievements'] ?? []),
      bio: data['bio'],
      github: data['github'],
      linkedin: data['linkedin'],
      phone: data['phone'],
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : null,
      lastActive: data['lastActive'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastActive'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'department': department,
      'semester': semester,
      'skills': skills,
      'achievements': achievements,
      'bio': bio,
      'github': github,
      'linkedin': linkedin,
      'phone': phone,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'lastActive': lastActive?.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? profilePictureUrl,
    String? department,
    String? semester,
    List<String>? skills,
    List<String>? achievements,
    String? bio,
    String? github,
    String? linkedin,
    String? phone,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      skills: skills ?? this.skills,
      achievements: achievements ?? this.achievements,
      bio: bio ?? this.bio,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
