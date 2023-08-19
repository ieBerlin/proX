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
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            loginViewRoute,
                            (route) => false,
                          );
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
                    try {
                      await AuthService.firebase()
                          .forgotPassword(email: email.text);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        resetPasswordViewRoute,
                        (route) => false,
                      );
                    } on InvalidEmailException {
                      showErrorDialog(
                          context: context, content: 'Invalid email');
                    } on UserNotFoundException {
                      showErrorDialog(
                          context: context, content: 'User not found');
                    } on GenericException {
                      showErrorDialog(
                          context: context,
                          content: 'Can\'t send email verification!');
                    }
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
    );
  }
}
