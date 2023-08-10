import 'package:projectx/constants/db_constants/constants.dart';
import 'package:projectx/enums/enums.dart';

class NoteDB {
  final int noteId;
  final int id;
  final String title;
  final String content;
  final NoteImportance importance;

  NoteDB({
    required this.noteId,
    required this.id,
    required this.title,
    required this.content,
    required this.importance,
  });

  NoteDB.fromRow(Map<String, Object?> map)
      : noteId = map[noteIdColumn] as int,
        id = map[idColumn] as int,
        title = map[titleColumn] as String,
        content = map[contentColumn] as String,
        importance = map[importanceColumn] as NoteImportance;
  @override
  String toString() =>
      'noteId : $noteId, id : $id, title : $title, content : $content, importance : $importance';

  @override
  bool operator ==(covariant NoteDB other) => noteId == other.noteId;

  @override
  int get hashCode => noteId.hashCode;
}

NoteDB covertingQueryRowToANoteDbObject(
  List myValues,
) {
  return NoteDB(
    noteId: myValues[0],
    id: myValues[1],
    title: myValues[2],
    content: myValues[3],
    importance: stringToEnums(myValues[4]),
  );
}
