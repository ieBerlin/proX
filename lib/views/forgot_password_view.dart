import 'package:flutter/material.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/utilities/dialog/show_error_dialog.dart';
import '../services/auth/auth_exceptions.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController email;
  @override
  initState() {
    email = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginViewRoute,
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: const Color(0xff813995),
        centerTitle: true,
        title: const Text(
          'Reset you password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          TextField(
            controller: email,
            decoration: const InputDecoration(hintText: 'Enter you email'),
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
                return const Color(0xff813995);
              })),
              onPressed: () async {
                try {
                  await AuthService.firebase()
                      .forgotPassword(email: email.text);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    resetPasswordViewRoute,
                    (route) => false,
                  );
                } on InvalidEmailException {
                  showErrorDialog(context: context, content: 'Invalid email');
                } on UserNotFoundException {
                  showErrorDialog(context: context, content: 'User not found');
                } on GenericException {
                  showErrorDialog(
                      context: context,
                      content: 'Can\'t send email verification!');
                }
              },
              child: const Text(
                'Reset your password',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }
}
