import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/crud/services.dart';

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
  final Services _services = Services();
  NoteImportance _noteImportance = NoteImportance.red;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _requiredField = false;
  int _index = 1;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Visibility(
            visible: _requiredField,
            child: const Text('please enter text'),
          ),
          const Text('Note title'),
          TextField(
            controller: _titleController,
            decoration:
                const InputDecoration(hintText: 'Enter your note\'s title'),
          ),
          const Text('Note body'),
          TextField(
            controller: _bodyController,
            decoration:
                const InputDecoration(hintText: 'Enter your note\'s body'),
          ),
          Row(
            children: [
              const Text('Priority'),
              const SizedBox(
                width: 20,
              ),
              InkWell(
                  onTap: () {
                    setState(() {
                      _noteImportance = NoteImportance.red;
                      _index = 1;
                    });
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
                    setState(() {
                      _noteImportance = NoteImportance.orange;
                      _index = 2;
                    });
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
                    setState(() {
                      _noteImportance = NoteImportance.yellow;
                      _index = 3;
                    });
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
                    setState(() {
                      _noteImportance = NoteImportance.green;
                      _index = 4;
                    });
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
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () async {
                if (_titleController.text == '' || _bodyController.text == '') {
                  setState(() {
                    _requiredField = true;
                    log('error');
                  });
                } else {
                  setState(() {
                    _requiredField = false;
                  });

                  final user =
                      await _services.getUser(email: 'aeourmassi@gmail.com');
                  final note = await _services.createNote(
                    title: _titleController.text,
                    content: _bodyController.text,
                    importance: _noteImportance,
                    owner: user,
                  );
                  log(note.toString());
                }
              },
              child: const Text('Create'))
        ],
      ),
    );
  }
}
