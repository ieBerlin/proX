import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectx/views/forgot_password_view.dart';
import 'package:projectx/views/register_view.dart';
import 'package:projectx/views/verification_of_email.dart';
import '../constants/constants.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isPressed = false;

  late final TextEditingController email;
  late final TextEditingController password;

  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          TextField(
            controller: email,
            decoration: InputDecoration(hintText: 'Enter your email'),
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: password,
            decoration: InputDecoration(
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPressed = !isPressed;
                    });
                  },
                  icon: visibility(isPressed: isPressed),
                )),
            autocorrect: false,
            enableSuggestions: false,
            obscureText: !isPressed,
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.amber;
                }
                return Colors.blue;
              })),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email.text, password: password.text);
                  final user = FirebaseAuth.instance.currentUser;

                  if (!user!.emailVerified) {
                    await user.sendEmailVerification();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return const VerifieEmailView();
                    }), (route) => false);
                  }
                } on FirebaseAuthException catch (error) {
                  switch (error.code) {
                    case 'user-not-found':
                      log('User not found');
                      break;
                    case 'invalid-email':
                      log('invalid-email');
                      break;
                    case 'wrong-password':
                      log('wrong password');
                      break;
                    default:
                      log('Authentication error');
                  }
                } catch (error) {
                  log('An error occured');
                }
              },
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              )),
          const SizedBox(
            height: 30,
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                  return const RegisterView();
                }), (context) => false);
              },
              child: const Text('Don\'t have an account ?, create one !')),
          const SizedBox(
            height: 15,
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                  return const ForgotPasswordView();
                }), (context) => false);
              },
              child: const Text(
                'Forgot you password ?',
                style: TextStyle(color: Colors.red),
              )),
        ],
      ),
    );
  }
}
