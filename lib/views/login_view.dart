import 'package:flutter/material.dart';
import 'package:projectx/views/forgot_password_view.dart';
import 'package:projectx/views/register_view.dart';

import '../constants/constants.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isPressed = false;
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
          const TextField(
            decoration: InputDecoration(hintText: 'Enter your email'),
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
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
              onPressed: () {},
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
