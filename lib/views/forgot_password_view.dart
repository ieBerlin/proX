import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/services/auth/auth_exceptions.dart';
import 'package:projectx/services/auth/bloc/auth_bloc.dart';
import 'package:projectx/services/auth/bloc/auth_event.dart';
import 'package:projectx/services/auth/bloc/auth_state.dart';
import 'package:projectx/utilities/dialogs/error_dialog.dart';
import 'package:projectx/utilities/dialogs/password_reset_email_sent_dialog.dart';

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
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            email.clear();
            await showPasswordResetSentDialog(context);
          } else if (state.exception is InvalidEmailException) {
            await showErrorDialog(context, 'Invalid email');
          } else if (state.exception is UserNotFoundException) {
            await showErrorDialog(context, 'User Not found exception');
          } else if (state.exception is GenericException) {
            await showErrorDialog(context,
                'We could not process your request. Please make sure that you are a registered user, or if not, register a user now by going back one step.');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      child: IconButton(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventLogOut());
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                            size: 19,
                          )),
                    ),
                    const Text(
                      'Forgot Password',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 23),
                    ),
                    const SizedBox(
                      width: 70,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                  child: Image.asset('assets/images/forgot_password.jpg'),
                ),
                const Text(
                  'Please Enter Your Email Address To\nReceive a Verification Link',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: true,
                    cursorColor: Colors.amber,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.mark_email_read),
                      prefixIconColor: Colors.amber,
                      hintText: 'Enter you email',
                      hintStyle: const TextStyle(color: Color(0xff354758)),
                      filled: true,
                      fillColor: Colors.grey[100], // Set the background color
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Add a border radius
                        borderSide: BorderSide.none, // Hide the border
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Add focused border styling
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            width: 2,
                            color: Colors.amber), // Customize border color
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    onPressed: () async {
                      final _email = email.text;
                      context
                          .read<AuthBloc>()
                          .add(AuthEventForgotPassword(email: _email));
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // Set the border radius here
                      ),
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(color: Colors.white, fontSize: 23),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
