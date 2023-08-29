import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/services/auth/bloc/auth_bloc.dart';
import 'package:projectx/services/auth/bloc/auth_event.dart';
import 'package:projectx/services/cloud/firebase_cloud_storage.dart';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';
import 'package:projectx/services/crud/user_notes_databases/userdb.dart';
import 'package:projectx/utilities/dialogs/logout_dialog.dart';
import 'package:projectx/views/notes_list_view.dart';

class NoteView extends StatefulWidget {
  const NoteView({Key? key}) : super(key: key);

  @override
  _NoteViewState createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late final FirebaseCloudStorage _notesService;

  late final Services services;
  String get emailUser => AuthService.firebase().currentUser!.email;
  @override
  void initState() {
    services = Services();
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 186, 186, 186),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xff2a5ebc),
          onPressed: () async {
            Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
          },
          child: const Icon(Icons.library_add),
        ),
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: const Color(0xff2a5ebc),
          // elevation: 0,s
          title: const Text(
            'All notes',
            style: TextStyle(
                fontSize: 30, color: Colors.white, fontWeight: FontWeight.w600),
            textAlign: TextAlign.left,
          ),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      // ignore: use_build_context_synchronously
                      context.read<AuthBloc>().add(const AuthEventLogOut());
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
                      stream: _notesService.allNotes(
                          ownerUserId: (snapshot.data as UserDB).id.toString()),
                      builder: ((context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            if (snapshot.hasData) {
                              final allNotes =
                                  snapshot.data as Iterable<NoteDB>;
                              return NotesListView(
                                notes: allNotes,
                                onDeleteNote: (note) async {
                                  await services.deleteNote(
                                      noteId: note.noteId);
                                  await _notesService.deleteCloudNote(
                                      documentId: note.documentId);
                                },
                                onTap: (note) {
                                  Navigator.of(context).pushNamed(
                                    createOrUpdateNoteRoute,
                                    arguments: note,
                                  );
                                },
                                services: services,
                              );
                              //   default:
                              //     return const CircularProgressIndicator();
                              // }
                              // },
                              // );
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
