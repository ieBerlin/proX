import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/UI/tools/constants.dart';
import 'package:projectx/services/auth/bloc/auth_bloc.dart';
import 'package:projectx/services/auth/bloc/auth_event.dart';
import 'package:projectx/services/auth/bloc/auth_state.dart';
import 'package:projectx/utilities/dialogs/error_dialog.dart';
import '../constants/icons/constants.dart';
import '../services/auth/auth_exceptions.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isPressed = true;
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundException) {
            await showErrorDialog(context, 'user not found');
          } else if (state.exception is InvalidEmailException) {
            await showErrorDialog(context, 'Invalid email');
          } else if (state.exception is MissingPasswordException) {
            await showErrorDialog(context, 'Missing password');
          } else if (state.exception is WrongPasswordException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
          backgroundColor: lightBlackColor(),
          body: SafeArea(
            child: Container(
              constraints: const BoxConstraints.expand(),
              margin: const EdgeInsets.only(top: 70),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  )),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15,top: 10),
                          child: Image.asset(
                            'assets/images/logoImage.png',
                            width: 70,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                          width: 100,
                          child: Divider(
                            color: Color(0xff354654),
                            thickness: 4,
                          ),
                        ),
                        const SizedBox(
                          width: 85,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Image.asset(
                            'assets/images/login_register_image.png',
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 43),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 23),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 40),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Enter your credentials to access your account.',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                                fontSize: 13),
                          ),
                        ),
                        const SizedBox(
                          height: 21,
                        ),
                        // const SizedBox(height: 100),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            cursorColor: blue(),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.mark_email_read),
                              prefixIconColor: blue(),
                              hintText: 'Enter you email',
                              hintStyle:
                                  const TextStyle(color: Color(0xff354758)),
                              filled: true,
                              fillColor: const Color(
                                  0xffe5eef5), // Set the background color
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Add a border radius
                                borderSide: BorderSide.none, // Hide the border
                              ),
                              focusedBorder: OutlineInputBorder(
                                // Add focused border styling
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    width: 2,
                                    color: blue()), // Customize border color
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextField(
                            controller: password,
                            autocorrect: false,
                            enableSuggestions: false,
                            obscureText: isPressed,
                            cursorColor: blue(),
                            decoration: InputDecoration(
                              hintText: 'Enter you password',
                              hintStyle:
                                  const TextStyle(color: Color(0xff354758)),
                              prefixIcon: const Icon(Icons.lock_clock_rounded),
                              prefixIconColor: blue(),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    isPressed = !isPressed;
                                  });
                                },
                                child: visibility(isPressed: isPressed),
                              ),

                              filled: true,
                              fillColor: const Color(
                                  0xffe5eef5), // Set the background color
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Add a border radius
                                borderSide: BorderSide.none, // Hide the border
                              ),
                              focusedBorder: OutlineInputBorder(
                                // Add focused border styling
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    width: 2,
                                    color: blue()), // Customize border color
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(right: 40),
                          child: TextButton(
                              style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                      Colors.transparent)),
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      const AuthEventForgotPassword(),
                                    );
                              },
                              child: const Text(
                                'forgot password ?',
                                style: TextStyle(
                                  color: Color(0xffff6346),
                                ),
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: ElevatedButton(
                            onPressed: () async {
                              final _email = email.text;
                              final _password = password.text;
                              context
                                  .read<AuthBloc>()
                                  .add(AuthEventLogIn(_email, _password));
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Set the border radius here
                              ),
                              backgroundColor: const Color(0xffff6346),
                              minimumSize: const Size(double.infinity, 55),
                            ),
                            child: const Text(
                              'Login',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 23),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 52,
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 2,
                                color: Color(0xffFFBB4C),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              'OR',
                              style: TextStyle(
                                  color: Color(0xff354654),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 2,
                                color: Color(0xffFFBB4C),
                              ),
                            ),
                            SizedBox(
                              width: 52,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'New user',
                              style: TextStyle(color: Color(0xff324452)),
                            ),
                            TextButton(
                                style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent)),
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(const AuthEventShouldRegister());
                                },
                                child: Text('Create an account',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: blue(),
                                    )))
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
