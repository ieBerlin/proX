import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/UI/tools/circular_progress_inducator_widget.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/helpers/loading/loading_screen.dart';
import 'package:projectx/services/auth/bloc/auth_bloc.dart';
import 'package:projectx/services/auth/bloc/auth_event.dart';
import 'package:projectx/services/auth/bloc/auth_state.dart';
import 'package:projectx/services/auth/bloc/search_bloc/search_bloc.dart';
import 'package:projectx/services/auth/firebase_auth_provider.dart';
import 'package:projectx/views/create_or_update_note.dart';
import 'package:projectx/views/forgot_password_view.dart';
import 'package:projectx/views/home_page_view.dart';
import 'package:projectx/views/login_view.dart';
import 'package:projectx/views/register_view.dart';
import 'package:projectx/views/reset_password_view.dart';
import 'package:projectx/views/verification_of_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => AuthBloc(FirebaseAuthProvider())),
    BlocProvider(create: (_) => SearchBloc()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {
      loginViewRoute: (context) => const LoginView(),
      registerViewRoute: (context) => const RegisterView(),
      forgotPasswordViewRoute: (context) => const ForgotPasswordView(),
      resetPasswordViewRoute: (context) => const ResetPasswordView(),
      homePageViewRoute: (context) => const HomePage(),
      verificationEmailViewRoute: (context) => const VerifieEmailView(),
      createOrUpdateNoteRoute: (context) => const CreateOrUpdateNote(),
    }, home: const Oriented());
  }
}

class Oriented extends StatefulWidget {
  const Oriented({super.key});

  @override
  State<Oriented> createState() => _OrientedState();
}

class _OrientedState extends State<Oriented> {
  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
          context: context,
          text: state.loadingText ?? 'Please wait a moment',
        );
      } else {
        LoadingScreen().hide();
      }
    }, builder: ((context, state) {
      if (state is AuthStateLoggedIn) {
        return const HomePage();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifieEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else {
        return Scaffold(
          body: circularProgressIndicatorWidget(),
        );
      }
    }));
  }
}
