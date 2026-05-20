import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import '../models/progress_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/activity_model.dart';
import '../services/firestore_service.dart';

class ProjectProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProjectModel> _projects = [];
  List<UserModel> _supervisors = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ProjectModel> get projects => _projects;
  List<UserModel> get supervisors => _supervisors;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Real-time listener subscription
  Stream<List<ProjectModel>>? _projectStream;

  void fetchSupervisors() async {
    _setLoading(true);
    try {
      _supervisors = await _firestoreService.getSupervisors();
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  void listenToStudentProjects(String studentId) {
    if (_supervisors.isEmpty) fetchSupervisors();
    _projectStream = _firestoreService.getProjectsForStudent(studentId);
    _projectStream!.listen((projectList) {
      _projects = projectList;
      notifyListeners();
    });
  }

  void listenToSupervisorProjects(String supervisorId) {
    if (_supervisors.isEmpty) fetchSupervisors();
    _projectStream = _firestoreService.getProjectsForSupervisor(supervisorId);
    _projectStream!.listen((projectList) {
      _projects = projectList;
      notifyListeners();
    });
  }

  Future<bool> addProject(ProjectModel project) async {
    _setLoading(true);
    try {
      await _firestoreService.addProject(project);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProject(ProjectModel project) async {
    _setLoading(true);
    try {
      await _firestoreService.updateProject(project);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteProject(projectId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addProgress(ProgressModel progress) async {
    try {
      await _firestoreService.addProgress(progress);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Stream<List<ProgressModel>> getProjectProgress(String projectId) {
    return _firestoreService.getProjectProgress(projectId);
  }

  Future<bool> addFeedback(FeedbackModel feedback) async {
    try {
      await _firestoreService.addFeedback(feedback);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Stream<List<FeedbackModel>> getProjectFeedback(String projectId) {
    return _firestoreService.getProjectFeedback(projectId);
  }

  Stream<List<FeedbackModel>> getFeedbackForProjects(List<String> projectIds) {
    return _firestoreService.getFeedbackForProjects(projectIds);
  }



  // ──────────────────────────── Notifications ────────────────────────────

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? projectId,
  }) async {
    try {
      NotificationModel notification = NotificationModel(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        relatedProjectId: projectId,
      );
      await _firestoreService.addNotification(notification);
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestoreService.getNotifications(userId);
  }

  Stream<int> getUnreadNotificationCount(String userId) {
    return _firestoreService.getUnreadNotificationCount(userId);
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _firestoreService.markNotificationRead(notificationId);
  }

  Future<void> markAllNotificationsRead(String userId) async {
    await _firestoreService.markAllNotificationsRead(userId);
  }

  // ──────────────────────────── Activity ────────────────────────────

  Future<void> logActivity({
    required String userId,
    required String action,
    required String description,
    String? projectId,
    String? projectTitle,
  }) async {
    try {
      ActivityModel activity = ActivityModel(
        id: const Uuid().v4(),
        userId: userId,
        action: action,
        description: description,
        timestamp: DateTime.now(),
        projectId: projectId,
        projectTitle: projectTitle,
      );
      await _firestoreService.addActivity(activity);
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  Stream<List<ActivityModel>> getRecentActivity(String userId) {
    return _firestoreService.getRecentActivity(userId);
  }

  // ──────────────────────────── User Helpers ────────────────────────────

  Future<UserModel?> getUserById(String uid) async {
    return _firestoreService.getUserById(uid);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
