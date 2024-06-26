import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectx/services/cloud/cloud_exceptions.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';
import 'package:projectx/services/crud/current_crud.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(
          ownerUserIdFieldName,
          isEqualTo: ownerUserId,
        )
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));

    return allNotes;
  }

  Future<void> uploadNotes(
      {required Iterable<CloudNote> notes, required String userId}) async {
    for (var note in notes) {
      final currentNote = await createNewNote(ownerUserId: userId);
      final noteId = note.noteId;
      await updateCloudNote(
        documentId: currentNote.documentId,
        title: note.title,
        content: note.content,
        importance: note.importance,
      );
      await CRUDServices().deleteNote(
        noteId: noteId,
      );
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      titleFieldName: "",
      contentFieldName: "",
      importanceFieldName: ""
    });

    final fetchedNote = await document.get();
    return CloudNote(
      noteId: -1,
      documentId: fetchedNote.id,
      userId: ownerUserId,
      title: "",
      content: "",
      importance: "",
    );
  }

  Future<void> updateCloudNote({
    required String documentId,
    required String title,
    required String content,
    required String importance,
  }) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title,
        contentFieldName: content,
        importanceFieldName: importance
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
