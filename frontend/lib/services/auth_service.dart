import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'api_service.dart';

/// Session stays in memory; refreshing the browser requires signing in again.
class AuthService extends ChangeNotifier {
  AuthService(this.api);

  final ApiService api;
  UserModel? _currentUser;
  bool _isAdmin = false;

  UserModel? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _currentUser != null && api.token != null;

  Future<void> login(String email, String password) async {
    final result = await api.login(email, password);
    api.token = result.token;
    _currentUser = result.user;
    _isAdmin = result.isAdmin;
    notifyListeners();
  }

  void logout() {
    api.token = null;
    _currentUser = null;
    _isAdmin = false;
    notifyListeners();
  }

  /// Keep the greeting/avatar current when an administrator edits their profile.
  void updateCurrentUser(UserModel user) {
    if (_currentUser?.id != user.id) return;
    _currentUser = user;
    notifyListeners();
  }
}
