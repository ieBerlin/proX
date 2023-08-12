import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/services/crud/crud_exceptions.dart';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';
import 'package:projectx/views/create_or_update_note.dart';
import 'package:projectx/views/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final Services services;
  String get emailUser => AuthService.firebase().currentUser!.email;
  @override
  void initState() {
    services = Services();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Your Notes',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => const noteListView())));
                },
                icon: const Icon(Icons.add)),
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      loginViewRoute, (route) => false);
                },
                icon: const Icon(Icons.exit_to_app))
          ],
        ),
        body: FutureBuilder(
            future: services.getOrCreateUser(email: emailUser),
            builder: ((context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return StreamBuilder(
                      stream: services.allNotes,
                      builder: ((context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            if (snapshot.hasData &&
                                snapshot.data!.toList().isNotEmpty) {
                              final allNotes = snapshot.data as List<NoteDB>;
                              return NotesListView(notes: allNotes);
                            } else {
                              return const Text('No data to display');
                            }
                          default:
                            return const CircularProgressIndicator();
                        }
                      }));
                default:
                  return const CircularProgressIndicator();
              }
            })));
  }
}
