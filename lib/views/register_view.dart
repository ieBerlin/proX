import 'package:flutter/material.dart';
import 'package:projectx/views/login_view.dart';

import '../constants/constants.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool isPressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Register',
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
                'Register',
                style: TextStyle(color: Colors.white),
              )),
          const SizedBox(
            height: 30,
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                  return const LoginView();
                }), (context) => false);
              },
              child: const Text('Already have an account, login !'))
        ],
      ),
    );
  }
}
