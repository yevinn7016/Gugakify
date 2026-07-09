import 'package:flutter/foundation.dart';

import '../../data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  bool isLoggedIn = false;
  String? userId;
  String? email;
  String? nickname;

  Future<void> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    _setUser(user);
  }

  Future<void> continueAsGuest() async {
    final user = await _authService.continueAsGuest();
    _setUser(user);
  }

  void logout() {
    isLoggedIn = false;
    userId = null;
    email = null;
    nickname = null;
    notifyListeners();
  }

  void _setUser(MockUser user) {
    isLoggedIn = true;
    userId = user.userId;
    email = user.email;
    nickname = user.nickname;
    notifyListeners();
  }
}
