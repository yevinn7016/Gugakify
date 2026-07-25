import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

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
  AuthService({FirebaseAuth? firebaseAuth, http.Client? httpClient})
    : _firebaseAuthOverride = firebaseAuth,
      _httpClientOverride = httpClient;

  final FirebaseAuth? _firebaseAuthOverride;
  final http.Client? _httpClientOverride;
  http.Client? _defaultHttpClient;
  Future<void>? _googleSignInInitialization;

  FirebaseAuth get _firebaseAuth =>
      _firebaseAuthOverride ?? FirebaseAuth.instance;
  http.Client get _httpClient =>
      _httpClientOverride ?? (_defaultHttpClient ??= http.Client());

  Future<MockUser> signInWithGoogle() async {
    try {
      debugPrint('[Auth] Google Sign-In initialization started.');
      await (_googleSignInInitialization ??= GoogleSignIn.instance
          .initialize());
      debugPrint('[Auth] Google Sign-In account selection started.');

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final googleIdToken = googleAuth.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw const AuthFlowException('Google ID token was not issued.');
      }
      debugPrint('[Auth] Google ID token issued.');

      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthFlowException(
          'Firebase user is missing after sign-in.',
        );
      }

      final firebaseIdToken = await firebaseUser.getIdToken(true);
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw const AuthFlowException('Firebase ID token was not issued.');
      }
      debugPrint('[Auth] Firebase authentication succeeded.');

      await authenticateWithBackend(firebaseIdToken);
      debugPrint('[Auth] Backend authentication succeeded.');

      return MockUser(
        userId: firebaseUser.uid,
        email: firebaseUser.email ?? googleUser.email,
        nickname:
            firebaseUser.displayName ??
            googleUser.displayName ??
            googleUser.email,
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      debugPrint(
        '[Auth] FirebaseAuthException(${error.code}): ${error.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } on GoogleSignInException catch (error, stackTrace) {
      debugPrint('[Auth] GoogleSignInException(${error.code}): $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } on Object catch (error, stackTrace) {
      debugPrint('[Auth] Google login failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> authenticateWithBackend(String idToken) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/google');
    debugPrint('[Auth] POST ${uri.origin}${uri.path}');

    try {
      final response = await _httpClient
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      throw AuthFlowException(
        'Backend authentication failed with HTTP ${response.statusCode}.',
      );
    } on AuthFlowException {
      rethrow;
    } on Object catch (error, stackTrace) {
      debugPrint('[Auth] Backend authentication unavailable: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw AuthFlowException('Backend authentication failed: $error');
    }
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

class AuthFlowException implements Exception {
  const AuthFlowException(this.message);

  final String message;

  @override
  String toString() => 'AuthFlowException: $message';
}
