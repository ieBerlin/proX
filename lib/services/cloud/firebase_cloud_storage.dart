import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/cloud/cloud_exceptions.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';

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
        title: '',
        content: '',
        importance: '',
        documentId: fetchedNote.id);
  }

  Future<List<NoteDB>> iterableOfCloudNoteToNoteDB(
      {required Iterable<CloudNote> localNotes}) async {
    List<NoteDB> notes = [];
    for (var i in localNotes) {
      final note = await cloudNoteToNoteDB(cloudNote: i);
      notes.add(note);
    }
    return notes;
  }

  Future<NoteDB> cloudNoteToNoteDB({required CloudNote cloudNote}) async {
    String userEmail = FirebaseAuth.instance.currentUser!.email ?? '';
    final user = await Services().getUser(email: userEmail);
    final allnotes = await Services().getAllNotesOfAllUsers();
    var note;
    bool noteFoundBool = false;

    for (var i in allnotes) {
      if (i.documentId == cloudNote.documentId) {
        noteFoundBool = true;
        note = await Services().updateNote(
            noteId: i.noteId,
            title: cloudNote.title,
            content: cloudNote.content,
            importance: stringToEnums(cloudNote.importance),
            isSynced: 'true',
            isUpdated: 'true',
            documentId: cloudNote.documentId);
      }
    }
    if (noteFoundBool) {
      return note;
    } else {
      note = await Services().createNote(
          title: cloudNote.title,
          content: cloudNote.content,
          importance: stringToEnums(cloudNote.importance),
          owner: user);
      return NoteDB(
          noteId: note.noteId,
          id: note.id,
          title: note.title,
          content: note.content,
          importance: note.importance,
          isSynced: 'true',
          isUpdated: 'true',
          documentId: note.documentId);
    }
  }
}
