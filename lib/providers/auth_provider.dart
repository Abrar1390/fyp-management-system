import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _authService.user.listen((UserModel? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      UserModel? loggedInUser = await _authService.login(email, password);
      _user = loggedInUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String role, {
    String? department,
    String? semester,
  }) async {
    _setLoading(true);
    try {
      UserModel? registeredUser = await _authService.register(
        name,
        email,
        password,
        role,
        department: department,
        semester: semester,
      );
      _user = registeredUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update user profile fields
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      await _authService.updateUserProfile(_user!.uid, data);
      // Refresh user data
      await refreshUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }



  /// Refresh user data from Firestore
  Future<void> refreshUser() async {
    try {
      UserModel? freshUser = await _authService.getCurrentUser();
      if (freshUser != null) {
        _user = freshUser;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Parse Firebase error messages to user-friendly strings
  String _parseFirebaseError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
