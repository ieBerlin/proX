import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectx/views/login_view.dart';

class VerifieEmailView extends StatefulWidget {
  const VerifieEmailView({super.key});

  @override
  State<VerifieEmailView> createState() => _VerifieEmailViewState();
}

class _VerifieEmailViewState extends State<VerifieEmailView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text(
            'Verification email',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'We\'ve send you an email verification,\n check you email!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const LoginView();
                  }));
                },
                child: const Text('Back to login page'))
          ],
        )));
  }
}