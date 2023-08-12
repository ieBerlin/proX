import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';
import 'package:projectx/utilities/dialogs/logout_dialog.dart';
import 'package:projectx/views/create_or_update_note.dart';
import 'package:projectx/views/notes_list_view.dart';

class NoteView extends StatefulWidget {
  const NoteView({Key? key}) : super(key: key);

  @override
  _NoteViewState createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xff813995),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: ((context) => const noteListView())));
          },
          child: const Icon(Icons.library_add),
        ),
        appBar: AppBar(
          backgroundColor: const Color(0xff813995),
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              DateTime.now().hour > 12 ? 'Good Afternoon!' : 'Good Morning!',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      await AuthService.firebase().logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginViewRoute,
                        (_) => false,
                      );
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('Log out'),
                  ),
                ];
              },
            ),
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
                              return NotesListView(
                                notes: allNotes,
                                onDeleteNote: (note) async {
                                  await services.deleteNote(
                                      noteId: note.noteId);
                                },
                                onTap: (tap) {
                                  log(tap.toString());
                                  log('tapped');
                                },
                                services: services,
                              );
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
