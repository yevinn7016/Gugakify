class MockUser {
  const MockUser({
    required this.userId,
    required this.email,
    required this.nickname,
    this.isGuest = false,
  });

  final String userId;
  final String email;
  final String nickname;
  final bool isGuest;
}

class AuthService {
  Future<MockUser> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const MockUser(
      userId: 'user_001',
      email: 'user001@gmail.com',
      nickname: 'user_001',
    );
  }

  Future<MockUser> continueAsGuest() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return const MockUser(
      userId: 'guest_001',
      email: '',
      nickname: '비회원',
      isGuest: true,
    );
  }
}
