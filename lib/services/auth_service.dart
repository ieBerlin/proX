import 'package:projectx/services/auth_provider.dart';
import 'package:projectx/services/auth_user.dart';
import 'package:projectx/services/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);
  factory AuthService.firebase() {
    return AuthService(FirebaseAuthProvider());
  }
  @override
  Future<AuthUser?> createUser(
      {required String email, required String password}) {
    return provider.createUser(email: email, password: password);
  }

  @override
  Future<void> firebaseIntialize() {
    return provider.firebaseIntialize();
  }

  @override
  Future<void> forgotPassword({required String email}) {
    return provider.forgotPassword(email: email);
  }

  @override
  Future<AuthUser?> logIn({required String email, required String password}) {
    return provider.logIn(email: email, password: password);
  }

  @override
  Future<void> sendEmailVerification() {
    return provider.sendEmailVerification();
  }

  @override
  AuthUser? get currentUser => provider.currentUser;
}
