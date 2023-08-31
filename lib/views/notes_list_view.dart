import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:projectx/enums/methods.dart';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';
import 'package:projectx/utilities/dialogs/delete_dialog.dart';

typedef NoteCallBack = void Function(NoteDB note);

class NotesListView extends StatelessWidget {
  final List<NoteDB> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onTap;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
    required this.services,
  });

  final Services services;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: notes.toList().length,
        itemBuilder: ((context, index) {
          final note = notes[index];
          return InkWell(
              onTap: () {
                onTap(note);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  height: 100,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: Align(
                        alignment: const Alignment(0.9, 0.9),
                        child: CircleAvatar(
                          backgroundColor: const Color(0xff2a5ebc),
                          // enumsToColors(note.importance),
                          child: IconButton(
                              onPressed: () async {
                                final shouldDelete =
                                    await showDeleteDialog(context);
                                if (shouldDelete) {
                                  onDeleteNote(note);
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              )),
                        ),
                      )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: (width / 2) - 70,
                                  child: Text(
                                    note.title,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor:
                                      enumsToColors(note.importance),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: SizedBox(
                                height: (width / 2) - 70 - 40,
                                child: Text(
                                  note.content,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 10,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 144, 144, 144),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        }));
  }
}
