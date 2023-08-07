import 'package:flutter/material.dart';
import 'package:projectx/views/login_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) {
                return const LoginView();
              }), (route) => false);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Reset you password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const TextField(
            decoration: InputDecoration(hintText: 'Enter you emails'),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.red;
                }
                return Colors.blue;
              })),
              onPressed: () {},
              child: const Text(
                'Reset your password',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }
}
