import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/cloud/cloud_exceptions.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
  final notes = FirebaseFirestore.instance.collection('notes');
  Future<NoteDB> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      titleFieldName: '',
      contentFieldName: '',
      importanceFieldName: 'red',
    });
    final fetchedNote = await document.get();

    return NoteDB(
      noteId: fetchedNote.id,
      id: int.parse(ownerUserId),
      title: '',
      content: '',
      importance: stringToEnums('red'),
    );
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String title,
    required String content,
    required String importance,
  }) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title,
        contentFieldName: content,
        importanceFieldName: importance,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<NoteDB>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => NoteDB.fromSnapshot(doc)));
    return allNotes;
  }
}
