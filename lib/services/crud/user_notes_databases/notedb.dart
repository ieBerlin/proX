import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectx/constants/db_constants/constants.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';

class NoteDB {
  final int id;
  final String noteId;
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
      : id = map[idColumn] as int,
        noteId = map[noteIdColumn] as String,
        title = map[titleColumn] as String,
        content = map[contentColumn] as String,
        importance = map[importanceColumn] as NoteImportance;

  NoteDB.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = int.parse(snapshot.data()[ownerUserIdFieldName]),
        noteId = snapshot.id,
        title = snapshot.data()[titleFieldName] as String,
        content = snapshot.data()[contentFieldName] as String,
        importance = stringToEnums(snapshot.data()[importanceFieldName]);

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
    id: myValues[0],
    noteId: myValues[1],
    title: myValues[2],
    content: myValues[3],
    importance: stringToEnums(myValues[4]),
  );
}
