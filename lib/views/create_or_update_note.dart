import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/UI/tools/circular_progress_inducator_widget.dart';
import 'package:projectx/UI/tools/constants.dart';
import 'package:projectx/bloc/bloc.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/firebase_cloud_storage.dart';
import 'package:projectx/services/crud/current_crud.dart';
import 'package:projectx/utilities/dialogs/generics/get_arguments.dart';
import 'package:projectx/views/home_page_view.dart';
// import 'package:share_plus/share_plus.dart';

class CreateOrUpdateNote extends StatefulWidget {
  final bool userConnected;
  const CreateOrUpdateNote({
    super.key,
    required this.userConnected,
  });

  @override
  State<CreateOrUpdateNote> createState() => _CreateOrUpdateNoteState();
}

class _CreateOrUpdateNoteState extends State<CreateOrUpdateNote> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  NoteImportance _noteImportance = NoteImportance.red;
  CloudNote? _note;
  final FirebaseCloudStorage _notesService = FirebaseCloudStorage();
  final CRUDServices _services = CRUDServices();
  // late String sharedNoteContent =
  // '${_titleController.text} \n ${_bodyController.text}';
  Future<CloudNote> createOrGetExsitingNote(BuildContext context) async {
    final widgetNote = context.getArguments<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _bodyController.text = widgetNote.content;
      _noteImportance = stringToEnums(widgetNote.importance);
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    } else {
      final currentUser = AuthService.firebase().currentUser!;
      final userId = currentUser.id;
      if (widget.userConnected) {
        final newNote = await _notesService.createNewNote(ownerUserId: userId);
        _note = newNote;
        return newNote;
      } else {
        final newNote =
            await _services.createNote(title: '', content: '', importance: '');
        _note = newNote;
        return newNote;
      }
    }
  }

  void _deleteNoteIfTextEmpty() async {
    final note = _note;
    if (_titleController.text.isEmpty &&
        _bodyController.text.isEmpty &&
        note != null) {
      if (note.documentId != 'DEFAULT-NULL') {
        await _notesService.deleteNote(documentId: note.documentId);
      } else {
        //Based in berlin
        await _services.deleteNote(noteId: note.noteId);
      }
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
      if (note.documentId != 'DEFAULT-NULL') {
        await _notesService.updateCloudNote(
          title: title,
          content: content,
          importance: enumToString(importance),
          documentId: note.documentId,
        );
      } else {
        //Based in berlin
        await _services.updateNote(
          noteId: note.noteId,
          title: title,
          content: content,
          importance: enumToString(importance),
        );
      }
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
    if (note.documentId != 'DEFAULT-NULL') {
      await _notesService.updateCloudNote(
        title: title,
        content: content,
        importance: enumToString(importance),
        documentId: note.documentId,
      );
    } else {
      //Based in berlin
      await _services.updateNote(
        noteId: note.noteId,
        title: title,
        content: content,
        importance: enumToString(importance),
      );
    }
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
      child: SafeArea(
        child: Scaffold(
            backgroundColor: lightBlackColor(),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your note will be saved automatically ',
                    style: TextStyle(
                        color: white(),
                        fontFamily: 'Lato-Regular',
                        fontSize: 13),
                  ),
                  Icon(
                    Icons.report,
                    color: amber(),
                  )
                ],
              ),
            ),
            body: FutureBuilder(
              future: createOrGetExsitingNote(context),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  _setupTitleControllerListener();
                  _setupContentControllerListener();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    IconButton(
                                      splashRadius: 20,
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (context) {
                                            return const HomePage();
                                          }),
                                          (context) => false,
                                        );
                                      },
                                      icon: Icon(
                                        Icons.chevron_left,
                                        color: white(),
                                      ),
                                    ),
                                    Text(
                                      'Add note',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: 'SF-Compact-Display-Bold',
                                        color: white(),
                                        fontSize: 35,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 13.0),
                            child: Column(
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(bottom: 13),
                                    width: double.infinity,
                                    child: Text(
                                      'Note title',
                                      style: TextStyle(
                                          fontFamily: 'SF-Compact-Display-Bold',
                                          fontSize: 23,
                                          color: white()),
                                      textAlign: TextAlign.left,
                                    )),
                                TextField(
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: white(),
                                      fontFamily: 'Lato-Regular',
                                      fontWeight: FontWeight.w800,
                                    ),
                                    cursorColor: white(),
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: fillTextField(),
                                      hintText:
                                          'Type your note\'s title here...',
                                      hintStyle: TextStyle(
                                        color: menuBarItemColor(),
                                        fontFamily:
                                            'SF-Compact-Display-Regular',
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Add a border radius
                                        borderSide:
                                            BorderSide.none, // Hide the border
                                      ),
                                    )),
                                Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 13, top: 20),
                                    width: double.infinity,
                                    child: Text(
                                      'Note body',
                                      style: TextStyle(
                                          fontFamily: 'SF-Compact-Display-Bold',
                                          fontSize: 23,
                                          color: white()),
                                      textAlign: TextAlign.left,
                                    )),
                                TextField(
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontFamily: 'Lato-Regular',
                                      fontWeight: FontWeight.w800,
                                      color: white(),
                                    ),
                                    maxLines: 6,
                                    cursorColor: white(),
                                    controller: _bodyController,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Type your note\'s body here...',
                                      hintStyle: TextStyle(
                                        color: menuBarItemColor(),
                                        fontFamily:
                                            'SF-Compact-Display-Regular',
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      filled: true,
                                      fillColor: fillTextField(),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Add a border radius
                                        borderSide:
                                            BorderSide.none, // Hide the border
                                      ),
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                BlocConsumer<PriorityBloc, PriorityIndex>(
                                  listener: (context, state) {
                                    _textEditingListener();
                                  },
                                  builder: (context, state) {
                                    return Row(
                                      children: [
                                        Text(
                                          'Priority',
                                          style: TextStyle(
                                              fontSize: 28,
                                              fontFamily:
                                                  'SF-Compact-Display-Bold',
                                              color: white()),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        InkWell(
                                            enableFeedback: false,
                                            highlightColor: transparent(),
                                            splashColor: transparent(),
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
                                                          ? white()
                                                          : transparent(),
                                                ),
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: red(),
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        InkWell(
                                            enableFeedback: false,
                                            highlightColor: transparent(),
                                            splashColor: transparent(),
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
                                                          ? white()
                                                          : transparent(),
                                                ),
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: orange(),
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        InkWell(
                                            enableFeedback: false,
                                            highlightColor: transparent(),
                                            splashColor: transparent(),
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
                                                          ? white()
                                                          : transparent(),
                                                ),
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: blue(),
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        InkWell(
                                            enableFeedback: false,
                                            highlightColor: transparent(),
                                            splashColor: transparent(),
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
                                                          ? white()
                                                          : transparent(),
                                                ),
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: green(),
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
                    ),
                  );
                } else {
                  return circularProgressIndicatorWidget();
                }
              }),
            )),
      ),
    );
  }
}
