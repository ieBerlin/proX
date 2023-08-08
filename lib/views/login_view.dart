import 'package:flutter/material.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/services/auth_service.dart';
import 'package:projectx/utilities/dialog/show_error_dialog.dart';
import '../constants/icons/constants.dart';
import '../services/auth_exceptions.dart';

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
            decoration: const InputDecoration(hintText: 'Enter your email'),
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
                // officielkaytout8@gmail.com
                try {
                  await AuthService.firebase().logIn(
                    email: email.text,
                    password: password.text,
                  );
                  final user = AuthService.firebase().currentUser;

                  if (!user!.isEmailVerified) {
                    await AuthService.firebase().sendEmailVerification();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verificationEmailViewRoute,
                      (route) => false,
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      homePageViewRoute,
                      (route) => false,
                    );
                  }
                } on InvalidEmailException {
                  await showErrorDialog(
                      context: context, content: 'Invalid email');
                } on WrongPasswordException {
                  await showErrorDialog(
                      context: context, content: 'Wrong password');
                } on MissingPasswordException {
                  await showErrorDialog(
                      context: context, content: 'Missing password');
                } on WeakPasswordException {
                  await showErrorDialog(
                      context: context, content: 'Weak password');
                } on UserNotFoundException {
                  await showErrorDialog(
                      context: context, content: 'User not found');
                } on GenericException {
                  await showErrorDialog(
                      context: context,
                      content: 'An error occured while authentication');
                } catch (exception) {
                  await showErrorDialog(
                      context: context,
                      content: 'An error occured while authentication');
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
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerViewRoute,
                  (context) => false,
                );
              },
              child: const Text('Don\'t have an account ?, create one !')),
          const SizedBox(
            height: 15,
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  forgotPasswordViewRoute,
                  (context) => false,
                );
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
