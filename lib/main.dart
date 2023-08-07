import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projectx/firebase_options.dart';
import 'package:projectx/views/home_page.dart';
import 'package:projectx/views/login_view.dart';
import 'package:projectx/views/verification_of_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Oriented(),
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
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
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
