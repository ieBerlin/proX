import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/services/auth_service.dart';
import 'package:projectx/views/forgot_password_view.dart';
import 'package:projectx/views/home_page_view.dart';
import 'package:projectx/views/login_view.dart';
import 'package:projectx/views/register_view.dart';
import 'package:projectx/views/reset_password_view.dart';
import 'package:projectx/views/verification_of_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        loginViewRoute: (context) => const LoginView(),
        registerViewRoute: (context) => const RegisterView(),
        forgotPasswordViewRoute: (context) => const ForgotPasswordView(),
        resetPasswordViewRoute: (context) => const ResetPasswordView(),
        homePageViewRoute: (context) => const HomePage(),
        verificationEmailViewRoute: (context) => const VerifieEmailView(),
      },
      home: const Oriented(),
    );
  }
}

class Oriented extends StatefulWidget {
  const Oriented({super.key});

  @override
  State<Oriented> createState() => _OrientedState();
}

class _OrientedState extends State<Oriented> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().firebaseIntialize(),
        builder: ((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                if (user.emailVerified) {
                  return const HomePage();
                } else {
                  return const VerifieEmailView();
                }
              } else {
                return const LoginView();
              }

            default:
              return const CircularProgressIndicator();
          }
        }));
  }
}
