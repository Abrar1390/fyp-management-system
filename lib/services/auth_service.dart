import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
      return null;
    });
  }

  /// Get the currently signed-in user's UID
  String? get currentUid => _auth.currentUser?.uid;

  /// Fetch the current user model from Firestore
  Future<UserModel?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Error fetching current user: $e');
    }
    return null;
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        // Update last active
        await _firestore.collection('users').doc(user.uid).update({
          'lastActive': DateTime.now().millisecondsSinceEpoch,
        });
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> register(
    String name,
    String email,
    String password,
    String role, {
    String? department,
    String? semester,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final userData = {
          'name': name,
          'email': email,
          'role': role,
          'department': department,
          'semester': semester,
          'skills': <String>[],
          'achievements': <String>[],
          'createdAt': now,
          'lastActive': now,
        };
        await _firestore.collection('users').doc(user.uid).set(userData);
        return UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: role,
          department: department,
          semester: semester,
          createdAt: DateTime.fromMillisecondsSinceEpoch(now),
          lastActive: DateTime.fromMillisecondsSinceEpoch(now),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile fields in Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['lastActive'] = DateTime.now().millisecondsSinceEpoch;
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email — NO extra Firebase config needed
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return;
    }
  }
}
