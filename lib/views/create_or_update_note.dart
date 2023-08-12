import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const noteListView());
  }
}

class noteListView extends StatefulWidget {
  const noteListView({super.key});

  @override
  State<noteListView> createState() => _noteListViewState();
}

class _noteListViewState extends State<noteListView> {
  String? title;
  String? content;
  late NoteImportance _noteImportance;

  NoteDB? _note;
  final Services _services = Services();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  int _index = 1;

  Future<NoteDB> createOrGetExsitingNote(BuildContext context) async {
    final existingNote = _note;
    if (existingNote != null) {
      log('updated note');
      return existingNote;
    } else {
      final currentUser = AuthService.firebase().currentUser;
      final email = currentUser!.email;
      final owner = await _services.getUser(email: email);
      final newNote = await _services.createNote(
        title: _titleController.text,
        content: _bodyController.text,
        importance: _noteImportance,
        owner: owner,
      );
      _note = newNote;
      log(_note.toString());
      log('note has been created ');
      return newNote;
    }
  }

  void _deleteNoteIfTextEmpty() {
    final note = _note;
    if ((_titleController.text.isEmpty || _bodyController.text.isEmpty) &&
        note != null) {
      _services.deleteNote(noteId: note.noteId);
    }
    log('note has been deleted ');
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final title = _titleController.text;
    final content = _bodyController.text;
    final importance = _noteImportance;
    if (note != null &&
        _titleController.text.isNotEmpty &&
        _bodyController.text.isNotEmpty) {
      await _services.updateNote(
        noteId: note.noteId,
        title: title,
        content: content,
        importance: importance,
      );
    }
    log('note has been saved ');
  }

  void _textEditingListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _titleController.text;
    final content = _bodyController.text;
    final importance = _noteImportance;
    log('text editing listener ');

    await _services.updateNote(
      noteId: note.noteId,
      title: title,
      content: content,
      importance: importance,
    );
    log('updated note');
  }

  void _setupImportanceControllerListener() {
    log('_setupImportanceControllerListener');
  }

  void _setupTitleControllerListener() {
    log('_setupTitleControllerListener');

    _titleController.removeListener(() {
      _textEditingListener();
    });
    _titleController.addListener(() {
      _textEditingListener();
    });
  }

  void _setupContentControllerListener() {
    log('_setupContentControllerListener ');

    _bodyController.removeListener(() {
      _textEditingListener();
    });
    _bodyController.addListener(() {
      _textEditingListener();
    });
  }

  @override
  void initState() {
    _noteImportance = NoteImportance.red;
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _deleteNoteIfTextEmpty();
    _saveNoteIfTextNotEmpty();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
        ),
        body: FutureBuilder(
            future: createOrGetExsitingNote(context),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  _setupTitleControllerListener();
                  _setupContentControllerListener();

                  return Column(
                    children: [
                      const Text('Note title'),
                      TextField(
                        onChanged: (value) {
                          title = value;
                          createOrGetExsitingNote(context);
                        },
                        controller: _titleController,
                        decoration: const InputDecoration(
                            hintText: 'Enter your note\'s title'),
                      ),
                      const Text('Note body'),
                      TextField(
                        onChanged: (value) {
                          content = value;
                          createOrGetExsitingNote(context);
                        },
                        controller: _bodyController,
                        decoration: const InputDecoration(
                            hintText: 'Enter your note\'s body'),
                      ),
                      Row(
                        children: [
                          const Text('Priority'),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                              onTap: () {
                                _noteImportance = NoteImportance.red;
                                print(_noteImportance);
                                _index = 1;
                              },
                              child: _index == 1
                                  ? const Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Color(0xff545454),
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.red,
                                        ),
                                      ],
                                    )
                                  : const Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.red,
                                        ),
                                      ],
                                    )),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                              onTap: () {
                                _noteImportance = NoteImportance.orange;
                                print(_noteImportance);

                                _index = 2;
                              },
                              child: _index == 2
                                  ? const Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Color(0xff545454),
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.orange,
                                        ),
                                      ],
                                    )
                                  : const Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.orange,
                                        ),
                                      ],
                                    )),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                              onTap: () {
                                _noteImportance = NoteImportance.yellow;
                                print(_noteImportance);

                                _index = 3;
                              },
                              child: _index == 3
                                  ? const Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Color(0xff545454),
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.yellow,
                                        ),
                                      ],
                                    )
                                  : const Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.yellow,
                                        ),
                                      ],
                                    )),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                              onTap: () {
                                _noteImportance = NoteImportance.green;
                                print(_noteImportance);

                                _index = 4;
                              },
                              child: _index == 4
                                  ? const Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Color(0xff545454),
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.green,
                                        ),
                                      ],
                                    )
                                  : const Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.green,
                                        ),
                                      ],
                                    ))
                        ],
                      ),
                    ],
                  );
                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}
