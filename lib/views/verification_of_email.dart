import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/UI/tools/constants.dart';
import 'package:projectx/services/auth/bloc/auth_bloc.dart';
import 'package:projectx/services/auth/bloc/auth_event.dart';

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
        backgroundColor: lightBlackColor(),
        appBar: AppBar(
          backgroundColor: blackColor(),
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
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 4.0)),
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(255, 51, 51, 54)),
                ),
                child: const Text(
                  'Back to login page',
                  style: TextStyle(
                      backgroundColor: Color.fromARGB(255, 51, 51, 54),
                      color: Colors.white),
                ))
          ],
        )));
  }
}
