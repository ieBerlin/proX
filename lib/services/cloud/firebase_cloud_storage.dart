import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectx/services/cloud/cloud_exceptions.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';
import 'package:projectx/services/crud/current_crud.dart';

class FirebaseCloudStorage {
  final CRUDServices _services = CRUDServices();
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
  final notes = FirebaseFirestore.instance.collection('notes');
  Future<List<CloudNote>> fetchData({required String query}) async {
    // Fetch data from Firestore and return it as a list of DocumentSnapshot
    List<CloudNote> fetchedNotes = [];
    await FirebaseFirestore.instance
        .collection('notes')
        .where(
          ownerUserIdFieldName,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        String title = doc['title'];
        if (title.toLowerCase().contains(query.toLowerCase())) {
          fetchedNotes.add(CloudNote.fromIterable(doc));
        }
      });
    });
    return fetchedNotes;
  }

  Stream<List<CloudNote>> allNotes({required String ownerUserId}) =>
      _services.localNotes;

  // Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) async* {
  //   final cloudNotes = notes
  //       .where(
  //         ownerUserIdFieldName,
  //         isEqualTo: ownerUserId,
  //       )
  //       .snapshots()
  //       .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
  //   final localNotes = _services.localNotes;
  //   yield* streamNotes(cloudNotes, localNotes);
  // }

  // Stream<Iterable<CloudNote>> streamNotes(
  //     Stream<Iterable<CloudNote>> cloudNotes,
  //     Stream<Iterable<CloudNote>> localNotes) async* {
  //   await for (var i in cloudNotes) {
  //     yield i;
  //   }
  //   await for (var i in localNotes) {
  //     yield i;
  //   }
  // }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      titleFieldName: "",
      contentFieldName: "",
      importanceFieldName: ""
    });

    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      userId: ownerUserId,
      title: "",
      content: "",
      importance: "",
    );
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
