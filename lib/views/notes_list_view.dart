import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';

class NotesListView extends StatelessWidget {
  const NotesListView({super.key, required this.notes});
  final List<NoteDB> notes;
  @override
  Widget build(BuildContext context) {
    log(notes.length.toStringAsExponential());
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.title
                //  note.title,
                //  maxLines: 1,
                //overflow: TextOverflow.ellipsis,
                ),
            subtitle: Text(note.content),
            trailing: CircleAvatar(
              backgroundColor: enumsToColors(note.importance),
            ),
          );
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
