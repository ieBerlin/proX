import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/constants/routes/routes.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/services/auth/bloc/auth_bloc.dart';
import 'package:projectx/services/auth/bloc/auth_event.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/cloud_services.dart';
import 'package:projectx/services/cloud/firebase_cloud_storage.dart';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';
import 'package:projectx/utilities/dialogs/logout_dialog.dart';
import 'package:projectx/views/notes_list_view.dart';

class NoteView extends StatefulWidget {
  const NoteView({Key? key}) : super(key: key);

  @override
  _NoteViewState createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late final Services services;
  late final CloudServices cloudServices;
  late final FirebaseCloudStorage _notesService;
  String get emailUser => AuthService.firebase().currentUser!.email;
  String get userId => FirebaseAuth.instance.currentUser!.uid;
  List<NoteDB> allNotes = [];
  // Stream<List<NoteDB>> recoverAllNotes() async* {
  //   final allNotes = _notesService.allNotes as List<NoteDB>;
  //   log('---');
  //   log(allNotes.length.toString());
  //   yield allNotes;
  // }

  @override
  void initState() {
    services = Services();
    cloudServices = CloudServices();
    _notesService = FirebaseCloudStorage();
    // recoverAllNotes();
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
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    FutureBuilder(
                        future: _notesService.allNotes(ownerUserId: userId),
                        builder: ((context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.done:
                              if (snapshot.hasData &&
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
                                var fetchedNotes =
                                    snapshot.data as Iterable<CloudNote>;
                                if (snapshot.hasData &&
                                    fetchedNotes.toList().isNotEmpty) {
                                  // log(fetchedNotes.toList().toString());
                                  return FutureBuilder(
                                      future: _notesService
                                          .iterableOfCloudNoteToNoteDB(
                                              localNotes: fetchedNotes),
                                      builder: ((context, snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.done:
                                            return StreamBuilder(
                                                stream: services.allNotes,
                                                builder: (context, snapshot) {
                                                  switch (snapshot
                                                      .connectionState) {
                                                    case ConnectionState
                                                          .waiting:
                                                    case ConnectionState.active:
                                                      if (snapshot.hasData &&
                                                          snapshot.data!
                                                              .toList()
                                                              .isNotEmpty) {
                                                        final notes =
                                                            snapshot.data
                                                                as List<NoteDB>;
                                                        return Expanded(
                                                          child: NotesListView(
                                                            notes: notes,
                                                            onDeleteNote:
                                                                (note) async {
                                                              await services
                                                                  .deleteNote(
                                                                      noteId: note
                                                                          .noteId);
                                                              await _notesService
                                                                  .deleteNote(
                                                                documentId: note
                                                                    .documentId,
                                                                noteId:
                                                                    note.noteId,
                                                              );
                                                            },
                                                            onTap: (note) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                createOrUpdateNoteRoute,
                                                                arguments: note,
                                                              );
                                                            },
                                                            services: services,
                                                          ),
                                                        );
                                                      } else {
                                                        return const Text(
                                                            'no data to show buddy');
                                                      }
                                                    default:
                                                      return const CircularProgressIndicator();
                                                  }
                                                });
                                          default:
                                            return const Text(
                                                'from berlin itsn\'t done');
                                        }
                                      }));
                                } else {
                                  return StreamBuilder(
                                      stream: services.allNotes,
                                      builder: (context, snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.waiting:
                                          case ConnectionState.active:
                                            if (snapshot.hasData &&
                                                snapshot.data!
                                                    .toList()
                                                    .isNotEmpty) {
                                              final notes =
                                                  snapshot.data as List<NoteDB>;
                                              // log(notes.toList().toString());

                                              return Expanded(
                                                child: NotesListView(
                                                  notes: notes,
                                                  onDeleteNote: (note) async {
                                                    await services.deleteNote(
                                                        noteId: note.noteId);
                                                    await _notesService
                                                        .deleteNote(
                                                      documentId:
                                                          note.documentId,
                                                      noteId: note.noteId,
                                                    );
                                                  },
                                                  onTap: (note) {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                      createOrUpdateNoteRoute,
                                                      arguments: note,
                                                    );
                                                  },
                                                  services: services,
                                                ),
                                              );
                                            } else {
                                              return const Text(
                                                  'no data to show buddy');
                                            }
                                          default:
                                            return const CircularProgressIndicator();
                                        }
                                      });
                                }
                              } else {
                                return const Text('no data to show');
                              }

                            default:
                              return const Text('alaa');
                          }
                        })),
                    FutureBuilder(
                        future: cloudServices.getAllNotesThatShouldUploaded(),
                        builder: ((context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return StreamBuilder(
                                stream:
                                    cloudServices.allCloudNotesShouldUploaded,
                                builder: ((context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                      if (snapshot.hasData) {
                                        log(snapshot.data!
                                            .toList()
                                            .length
                                            .toString());
                                        FutureBuilder(
                                            future: _notesService
                                                .uploadNotesToRemoteServer(
                                                    myList: snapshot.data
                                                        as List<NoteDB>),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                return Container();
                                              } else {
                                                return const CircularProgressIndicator();
                                              }
                                            });
                                        return Container();
                                      } else {
                                        return Container();
                                      }
                                    default:
                                      return const CircularProgressIndicator();
                                  }
                                }));
                          } else {
                            return Container();
                          }
                        }))
                  ],
                );
              } else {
                return const Text('alaa');
              }
            }));
  }
}
