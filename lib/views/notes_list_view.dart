import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:projectx/enums/enums.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    log(notes.length.toStringAsExponential());
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
              title: Text(
                note.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: true,
              ),
              subtitle: Text(
                note.content,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: true,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: enumsToColors(note.importance),
                  ),
                 IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);

                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete),
            )
                ],
              ));
        });
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
