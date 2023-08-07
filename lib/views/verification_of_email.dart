import 'package:flutter/material.dart';

class VerifieEmailView extends StatefulWidget {
  const VerifieEmailView({super.key});

  @override
  State<VerifieEmailView> createState() => _VerifieEmailViewState();
}

class _VerifieEmailViewState extends State<VerifieEmailView> {
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
        body: const Center(
            child: Text(
          'We\'ve send you an email verification,\n check you email!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        )));
  }
}
