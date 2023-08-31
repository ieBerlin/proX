import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/bloc/bloc.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/services/cloud/firebase_cloud_storage.dart';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';
import 'package:projectx/utilities/dialogs/generics/get_arguments.dart';
// import 'package:share_plus/share_plus.dart';

class NoteListView extends StatefulWidget {
  const NoteListView({super.key});

  @override
  State<NoteListView> createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView> {
  NoteImportance _noteImportance = NoteImportance.red;

  NoteDB? _note;
  final Services _services = Services();
  final FirebaseCloudStorage _cloudServices = FirebaseCloudStorage();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late String sharedNoteContent =
      '${_titleController.text} \n ${_bodyController.text}';
  Future<NoteDB> createOrGetExsitingNote(BuildContext context) async {
    final widgetNote = context.getArguments<NoteDB>();
    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _bodyController.text = widgetNote.content;
      _noteImportance = widgetNote.importance;
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    } else {
      final currentUser = AuthService.firebase().currentUser;
      final email = currentUser!.email;
      final owner = await _services.getUser(email: email);
      final newNote = await _services.createNote(
        null,
        title: _titleController.text,
        content: _bodyController.text,
        importance: _noteImportance,
        owner: owner,
      );
      _note = newNote;
      return newNote;
    }
  }

  void _deleteNoteIfTextEmpty() async {
    final note = _note;
    if ((_titleController.text.isEmpty || _bodyController.text.isEmpty) &&
        note != null) {
      await _services.deleteNote(noteId: note.noteId);
      await _cloudServices.deleteNote(
        documentId: note.documentId,
        noteId: note.noteId,
      );
    }
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
        documentId: note.documentId,
      );
    }
  }

  void _textEditingListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _titleController.text;
    final content = _bodyController.text;
    final importance = _noteImportance;
    log(note.toString());
    await _services.updateNote(
      noteId: note.noteId,
      title: title,
      content: content,
      importance: importance,
      documentId: note.documentId,
    );
  }

  void _setupImportanceControllerListener() {}

  void _setupTitleControllerListener() {
    _titleController.removeListener(() {
      _textEditingListener();
    });
    _titleController.addListener(() {
      _textEditingListener();
    });
  }

  void _setupContentControllerListener() {
    _bodyController.removeListener(() {
      _textEditingListener();
    });
    _bodyController.addListener(() {
      _textEditingListener();
    });
  }

  @override
  void initState() {
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
    return BlocProvider<PriorityBloc>(
      create: (context) => PriorityBloc(initNoteImportance: _noteImportance),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: const Color(0xff2a5ebc),
          // elevation: 0,s
          title: const Text(
            'Add note',
            style: TextStyle(
                fontSize: 30, color: Colors.white, fontWeight: FontWeight.w600),
            textAlign: TextAlign.left,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  // Share.share(sharedNoteContent);
                },
                icon: const Icon(Icons.share))
          ],
        ),
        bottomNavigationBar: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your note will be saved automatically ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Icon(
                Icons.report,
                color: Colors.amber,
              )
            ],
          ),
        ),
        backgroundColor: const Color(0xffe6e6e6),
        body: SafeArea(
          child: FutureBuilder(
              future: createOrGetExsitingNote(context),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    _setupTitleControllerListener();
                    _setupContentControllerListener();
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: Column(
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(bottom: 13),
                                    width: double.infinity,
                                    child: const Text(
                                      'Note title',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Color(0xff002240)),
                                      textAlign: TextAlign.left,
                                    )),
                                TextField(
                                  style: const TextStyle(fontSize: 21),
                                  cursorColor: const Color(0xff002240),
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Add a border radius
                                        borderSide:
                                            BorderSide.none, // Hide the border
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                              width: 2,
                                              color: Color(0xff002240)))),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 13, top: 20),
                                    width: double.infinity,
                                    child: const Text(
                                      'Note body',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Color(0xff002240)),
                                      textAlign: TextAlign.left,
                                    )),
                                TextField(
                                  style: const TextStyle(fontSize: 21),
                                  maxLines: 6,
                                  cursorColor: const Color(0xff002240),
                                  controller: _bodyController,
                                  decoration: InputDecoration(
                                      hintText:
                                          'Type your note\'s body here...',
                                      hintStyle: const TextStyle(
                                        color: Color(0xaa002240),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Add a border radius
                                        borderSide:
                                            BorderSide.none, // Hide the border
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                              width: 2,
                                              color: Color(0xff002240)))),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                BlocBuilder<PriorityBloc, PriorityIndex>(
                                  builder: (context, state) {
                                    return Row(
                                      children: [
                                        const Text(
                                          'Priority',
                                          style: TextStyle(
                                              fontSize: 27,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff002240)),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              _noteImportance =
                                                  NoteImportance.red;
                                              context
                                                  .read<PriorityBloc>()
                                                  .indexChanger(1);
                                            },
                                            child: Stack(
                                              alignment:
                                                  AlignmentDirectional.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                      state.index == 1
                                                          ? Colors.black
                                                          : Colors.transparent,
                                                ),
                                                const CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: Colors.red,
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              _noteImportance =
                                                  NoteImportance.orange;
                                              context
                                                  .read<PriorityBloc>()
                                                  .indexChanger(2);
                                            },
                                            child: Stack(
                                              alignment:
                                                  AlignmentDirectional.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                      state.index == 2
                                                          ? Colors.black
                                                          : Colors.transparent,
                                                ),
                                                const CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              _noteImportance =
                                                  NoteImportance.yellow;
                                              context
                                                  .read<PriorityBloc>()
                                                  .indexChanger(3);
                                            },
                                            child: Stack(
                                              alignment:
                                                  AlignmentDirectional.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                      state.index == 3
                                                          ? Colors.black
                                                          : Colors.transparent,
                                                ),
                                                const CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor:
                                                      Colors.yellow,
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              _noteImportance =
                                                  NoteImportance.green;
                                              context
                                                  .read<PriorityBloc>()
                                                  .indexChanger(4);
                                            },
                                            child: Stack(
                                              alignment:
                                                  AlignmentDirectional.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                      state.index == 4
                                                          ? Colors.black
                                                          : Colors.transparent,
                                                ),
                                                const CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: Colors.green,
                                                ),
                                              ],
                                            ))
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  default:
                    return const CircularProgressIndicator();
                }
              }),
        ),
      ),
    );
  }
}
