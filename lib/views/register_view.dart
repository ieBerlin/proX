import 'package:flutter/material.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/services/auth/auth_service.dart';
import '../constants/icons/constants.dart';
import '../services/auth/auth_exceptions.dart';
import '../utilities/dialog/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
          'Register',
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
                // return Colors.blue;officielkaytout8@gmail.com
              })),
              onPressed: () async {
                try {
                  await AuthService.firebase().createUser(
                    email: email.text,
                    password: password.text,
                  );

                  await AuthService.firebase().sendEmailVerification();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verificationEmailViewRoute,
                    (route) => false,
                  );
                } on InvalidEmailException {
                  await showErrorDialog(
                      context: context, content: 'Invalid email');
                } on MissingPasswordException {
                  await showErrorDialog(
                      context: context, content: 'Missing password');
                } on WeakPasswordException {
                  await showErrorDialog(
                      context: context, content: 'Weak password');
                } on EmailAlreadyInUseException {
                  await showErrorDialog(
                      context: context, content: 'Email is already in use');
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
                'Register',
                style: TextStyle(color: Colors.white),
              )),
          const SizedBox(
            height: 30,
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginViewRoute,
                  (context) => false,
                );
              },
              child: const Text('Already have an account, login !'))
        ],
      ),
    );
  }
}
