import 'package:firebase_auth/firebase_auth.dart' show User;

class AuthUser {
  final String email;
  final bool isEmailVerified;

  AuthUser({
    required this.email,
    required this.isEmailVerified,
  });
  factory AuthUser.currentUser(User user) {
    return AuthUser(
      email: user.email!,
      isEmailVerified: user.emailVerified,
    );
  }
}
