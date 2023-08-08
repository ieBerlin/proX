import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:projectx/services/crud/note_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NoteServices noteServices;
  late final TextEditingController email;
  @override
  void initState() {
    email = TextEditingController();
    noteServices = NoteServices();
    super.initState();
  }

  @override
  void dispose() {
    noteServices.close();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: email,
            decoration: const InputDecoration(hintText: 'Enter email'),
          ),
          TextButton(
              onPressed: () async {
                log(email.text);
                final state =
                    await noteServices.getOrCreateUser(email: email.text);
                log(state.toString());
              },
              child: const Text('Create user'))
        ],
      ),
    );
  }
}
