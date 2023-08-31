
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/services/cloud/cloud_exceptions.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';
import 'package:projectx/services/crud/crud_exceptions.dart';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';
import 'package:projectx/services/crud/user_notes_databases/userdb.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));

    return allNotes;
  }

  Future<NoteDB> createOrGetExistingNote({
    required String documentId,
    required String title,
    required String content,
    required NoteImportance importance,
    required UserDB owner,
  }) async {
    try {
      final noteId =
          await Services().getNoteOnDocumentId(documentId: documentId);
      final note = await Services().getNote(noteId: noteId);
      if (title != note.title ||
          content != note.content ||
          importance != note.importance) {
        await Services().updateNote(
          noteId: noteId,
          title: title,
          content: content,
          importance: importance,
          documentId: documentId,
        );
      }
      return note;
    } on CouldNotFindTheNote {
      final note = await Services().createNote(
        documentId,
        title: title,
        content: content,
        importance: importance,
        owner: owner,
      );
      return note;
    }
  }

  Future<List<NoteDB>> iterableOfCloudNoteToNoteDB(
      {required Iterable<CloudNote> localNotes}) async {
    List<NoteDB> notes = [];
    final email = Services().email;
    final owner = await Services().getUser(email: email);
    final list = localNotes.toList();

    for (var i = 0; i < list.length; i++) {
      final cloudNote = list[i];

      final note = await createOrGetExistingNote(
          documentId: cloudNote.documentId,
          title: cloudNote.title,
          content: cloudNote.content,
          importance: stringToEnums(cloudNote.importance),
          owner: owner);

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
            documentId: cloudNote.documentId);
      }
    }
    if (noteFoundBool) {
      return note;
    } else {
      note = await Services().createNote(null,
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
          documentId: note.documentId);
    }
  }

  Future<void> createCloudNote({
    required String ownerId,
    required String title,
    required String content,
    required String importance,
    required int noteId,
  }) async {
    await notes.add({
      ownerUserIdFieldName: ownerId,
      titleFieldName: title,
      contentFieldName: content,
      importanceFieldName: importance,
    });
    await Services().deleteNoteFromAction(noteId: noteId);
  }

  Future<void> updateCloudNote(
      {required String ownerId,
      required String title,
      required int noteId,
      required String content,
      required String importance,
      required String documentId}) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title,
        contentFieldName: content,
        importanceFieldName: importance,
      });
      await Services().deleteNoteFromAction(noteId: noteId);
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote(
      {required String documentId, required int noteId}) async {
    try {
      await notes.doc(documentId).delete();
      await Services().deleteNoteFromAction(noteId: noteId);
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
