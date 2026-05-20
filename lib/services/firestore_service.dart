import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../models/progress_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/activity_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────── Users ────────────────────────────

  Future<List<UserModel>> getSupervisors() async {
    var snapshot = await _db.collection('users').where('role', isEqualTo: 'supervisor').get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      var doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    // Firestore whereIn limited to 30 items
    List<UserModel> results = [];
    for (int i = 0; i < uids.length; i += 10) {
      var chunk = uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);
      var snapshot = await _db.collection('users').where(FieldPath.documentId, whereIn: chunk).get();
      results.addAll(snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)));
    }
    return results;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ──────────────────────────── Projects ────────────────────────────

  Future<void> addProject(ProjectModel project) async {
    await _db.collection('projects').doc(project.id).set(project.toMap());
  }

  Future<void> updateProject(ProjectModel project) async {
    await _db.collection('projects').doc(project.id).update(project.toMap());
  }

  Future<void> deleteProject(String projectId) async {
    // Delete project document
    await _db.collection('projects').doc(projectId).delete();
    // Cascade delete: progress
    var progressSnap = await _db.collection('progress').where('projectId', isEqualTo: projectId).get();
    for (var doc in progressSnap.docs) {
      await doc.reference.delete();
    }
    // Cascade delete: feedback
    var feedbackSnap = await _db.collection('feedback').where('projectId', isEqualTo: projectId).get();
    for (var doc in feedbackSnap.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<ProjectModel>> getProjectsForStudent(String studentId) {
    return _db
        .collection('projects')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ProjectModel>> getProjectsForSupervisor(String supervisorId) {
    return _db
        .collection('projects')
        .where('supervisorId', isEqualTo: supervisorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ProjectModel>> getAllProjects() {
    return _db
        .collection('projects')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ──────────────────────────── Progress ────────────────────────────

  Future<void> addProgress(ProgressModel progress) async {
    await _db.collection('progress').doc(progress.id).set(progress.toMap());
  }

  Stream<List<ProgressModel>> getProjectProgress(String projectId) {
    return _db
        .collection('progress')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
          var list = snapshot.docs
              .map((doc) => ProgressModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.dateSubmitted.compareTo(a.dateSubmitted));
          return list;
        });
  }

  // ──────────────────────────── Feedback ────────────────────────────

  Future<void> addFeedback(FeedbackModel feedback) async {
    await _db.collection('feedback').doc(feedback.id).set(feedback.toMap());
  }

  Stream<List<FeedbackModel>> getProjectFeedback(String projectId) {
    return _db
        .collection('feedback')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
          var list = snapshot.docs
              .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
          return list;
        });
  }

  Stream<List<FeedbackModel>> getFeedbackForProjects(List<String> projectIds) {
    if (projectIds.isEmpty) return Stream.value([]);
    return _db
        .collection('feedback')
        .where('projectId', whereIn: projectIds.take(10).toList())
        .snapshots()
        .map((snapshot) {
          var list = snapshot.docs
              .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
          return list;
        });
  }



  // ──────────────────────────── Notifications ────────────────────────────

  Future<void> addNotification(NotificationModel notification) async {
    await _db.collection('notifications').doc(notification.id).set(notification.toMap());
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String userId) async {
    var snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<int> getUnreadNotificationCount(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ──────────────────────────── Activity Feed ────────────────────────────

  Future<void> addActivity(ActivityModel activity) async {
    await _db.collection('activities').doc(activity.id).set(activity.toMap());
  }

  Stream<List<ActivityModel>> getRecentActivity(String userId, {int limit = 20}) {
    return _db
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
