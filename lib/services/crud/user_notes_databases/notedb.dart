import 'package:projectx/constants/db_constants/constants.dart';
import 'package:projectx/enums/enums.dart';

class NoteDB {
  final int noteId;
  final int id;
  final String title;
  final String content;
  final NoteImportance importance;
  final String documentId;

  NoteDB({
    required this.noteId,
    required this.id,
    required this.title,
    required this.content,
    required this.importance,
    required this.documentId,
  });

  NoteDB.fromRow(Map<String, Object?> map)
      : noteId = map[noteIdColumn] as int,
        id = map[idColumn] as int,
        title = map[titleColumn] as String,
        content = map[contentColumn] as String,
        importance = map[importanceColumn] as NoteImportance,
        documentId = map[documentIdColumn] as String;

  @override
  String toString() =>
      'noteId : $noteId, id : $id, title : $title, content : $content, importance : $importance, documentId : $documentId';

  @override
  bool operator ==(covariant NoteDB other) => noteId == other.noteId;

  @override
  int get hashCode => noteId.hashCode;
}

NoteDB covertingQueryRowToANoteDbObject(
  Iterable queryRow,
) {
  if (queryRow.runtimeType.toString() == 'QueryResultSet') {
    final note = queryRow.first;
    return NoteDB(
      noteId: note['noteId'],
      id: note['id'],
      title: note['title'],
      content: note['content'],
      importance: stringToEnums(note['importance']),
      documentId: note['documentId'],
    );
  } else {
    final note = queryRow.toList();
    return NoteDB(
      noteId: note[0],
      id: note[1],
      title: note[2],
      content: note[3],
      importance: stringToEnums(note[4]),
      documentId: note[5],
    );
  }
}
