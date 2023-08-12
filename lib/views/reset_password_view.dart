import 'package:flutter/material.dart';
import 'package:projectx/constants/routes/routes.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff813995),
          centerTitle: true,
          title: const Text(
            'Reset password page',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'We\'ve send you a link,\nfollow it to reset your password',
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginViewRoute,
                      (context) => false,
                    );
                  },
                  child: const Text('Back to login page'))
            ],
          ),
        ));
  }
}
