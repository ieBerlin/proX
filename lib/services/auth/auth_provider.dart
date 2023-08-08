import 'package:projectx/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<AuthUser?> createUser(
      {required String email, required String password});
  Future<AuthUser?> logIn({required String email, required String password});
  Future<void> sendEmailVerification();
  Future<void> forgotPassword({required String email});
  Future<void> firebaseIntialize();
  AuthUser? get currentUser;
}
