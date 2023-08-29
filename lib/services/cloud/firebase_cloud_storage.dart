import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectx/services/cloud/cloud_exceptions.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updatedCloudNote(
      {required String documentId,
      required String title,
      required String content,
      required String importance}) async {
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

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));

    return allNotes;
  }

  Future<CloudNote> createCloudNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      titleFieldName: "",
      contentFieldName: "",
      importanceFieldName: "",
    });
    final fetchedNote = await document.get();
    return CloudNote(
        userId: ownerUserId,
        noteId: '',
        title: '',
        content: '',
        importance: '',
        documentId: fetchedNote.id);
  }
}
