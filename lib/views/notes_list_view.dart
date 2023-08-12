import 'package:flutter/material.dart';
import 'package:projectx/enums/enums.dart';
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
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: notes.toList().length,
        itemBuilder: ((context, index) {
          final note = notes[index];
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0, 4), // controls the position of the shadow
                  blurRadius: 8, // controls the blurriness of the shadow
                  spreadRadius: 2, // controls the size of the shadow
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: enumsToColors(note.importance),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 10),
                      child: Text(
                        note.title,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black),
                      ),
                    )),
                const SizedBox(
                  height: 13,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    note.content,
                    maxLines: 5,
                    // softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xffc9c2c9)),
                  ),
                ),
                Expanded(
                    child: Container(
                        alignment: Alignment.bottomRight,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                            right: 10,
                          ),
                          child: CircleAvatar(
                            backgroundColor: enumsToColors(note.importance),
                            child: IconButton(
                                onPressed: () async {
                                  final shouldDelete =
                                      await showDeleteDialog(context);
                                  if (shouldDelete) {
                                    await services.deleteNote(
                                        noteId: note.noteId);
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                )),
                          ),
                        )))
              ],
            ),
          );
        }));
  }
}

Color enumsToColors(NoteImportance noteImportance) {
  switch (noteImportance) {
    case NoteImportance.red:
      return Colors.red;
    case NoteImportance.yellow:
      return Colors.yellow;
    case NoteImportance.green:
      return Colors.green;
    case NoteImportance.orange:
      return Colors.orange;
    default:
      return Colors.red;
  }
}
