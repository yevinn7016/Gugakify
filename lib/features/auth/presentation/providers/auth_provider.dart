import 'package:flutter/foundation.dart';

import '../../data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  bool isLoggedIn = false;
  bool isGuest = false;
  String? userId;
  String? email;
  String? nickname;

  String get userName => nickname?.isNotEmpty == true ? nickname! : '사용자';
  String get userEmail => email?.isNotEmpty == true ? email! : '이메일 정보 없음';

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
    isGuest = false;
    userId = null;
    email = null;
    nickname = null;
    notifyListeners();
  }

  void _setUser(MockUser user) {
    isLoggedIn = true;
    isGuest = user.isGuest;
    userId = user.userId;
    email = user.email;
    nickname = user.nickname;
    notifyListeners();
  }
}
