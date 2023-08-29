import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectx/constants/db_constants/constants.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';

class NoteDB {
  final int id;
  final int noteId;
  final String ? documentId;
  final String title;
  final String content;
  final NoteImportance importance;
  final bool isSyncedInFirestoreDb;

  NoteDB(
      {required this.id,
      required this.noteId,
      required this.documentId,
      required this.title,
      required this.content,
      required this.importance,
      required this.isSyncedInFirestoreDb});

  NoteDB.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        noteId = map[noteIdColumn] as int,
        documentId = map[documentIdColumn] as String,
        title = map[titleColumn] as String,
        content = map[contentColumn] as String,
        importance = map[importanceColumn] as NoteImportance,
        isSyncedInFirestoreDb = map[isSyncedColumn] as bool;

  NoteDB.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = int.parse(snapshot.data()[ownerUserIdFieldName]),
        noteId = int.parse(snapshot.data()[noteIdFieldName]),
        documentId = snapshot.id,
        title = snapshot.data()[titleFieldName] as String,
        content = snapshot.data()[contentFieldName] as String,
        importance = stringToEnums(snapshot.data()[importanceFieldName]),
        isSyncedInFirestoreDb = snapshot.data()[isSyncedColumn] as bool;

  @override
  String toString() =>
      'noteId : $noteId, id : $id, document id : $documentId ,title : $title, content : $content, importance : $importance, isSyncedInFirestoreDb: $isSyncedInFirestoreDb ';

  @override
  bool operator ==(covariant NoteDB other) => noteId == other.noteId;

  @override
  int get hashCode => noteId.hashCode;
}

NoteDB covertingQueryRowToANoteDbObject(
  List myValues,
) {
  log(myValues.toString());
  return NoteDB(
    id: myValues[0],
    noteId: myValues[1],
    documentId: myValues[2],
    title: myValues[3],
    content: myValues[4],
    importance: stringToEnums(myValues[5]),
    isSyncedInFirestoreDb: myValues[6],
  );
}
