import 'dart:async';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';

class CloudServices {
  List<NoteDB> cloudNotes = [];
  late StreamController<List<NoteDB>> cloudNotesStreamController;
  CloudServices._sharedInstance() {
    cloudNotesStreamController =
        StreamController<List<NoteDB>>.broadcast(onListen: () {
      cloudNotesStreamController.sink.add(cloudNotes);
    });
  }
  static final CloudServices _shared = CloudServices._sharedInstance();
  factory CloudServices() => _shared;
  Stream<List<NoteDB>> get allCloudNotesShouldUploaded =>
      cloudNotesStreamController.stream;
  Future<List<NoteDB>> getAllNotesThatShouldUploaded() async {
    final notesFromActionDB = await Services().getAllNotesThatShoudlUploaded();

    for (var i in notesFromActionDB) {
      final note = await Services().getNote(noteId: i.noteId);
      if (cloudNotes.any((element) => element.noteId == note.noteId)) {
        cloudNotes.removeWhere((element) => note.noteId == element.noteId);
        cloudNotes.add(note);
      } else {
        cloudNotes.add(note);
      }
    }
    return cloudNotes;
  }
}

// List<UploadNote> cloudNotes = [];
// FirebaseCloudStorage firebaseCloudStorage = FirebaseCloudStorage();
//   Stream<List<NoteDB>> get allCloudNotesShouldUploaded =>
//       cloudNotesStreamController.stream;
//   CloudServices._sharedInstance() {
//     cloudNotesStreamController =
//         StreamController<List<NoteDB>>.broadcast(onListen: () {
//       cloudNotesStreamController.sink.add(cloudNotes);
//     });
//   }
//   static final CloudServices _shared = CloudServices._sharedInstance();
//   factory CloudServices() => _shared;



//  Future<List<NoteDB>> getAllUnSyncedNotes() async {
//     List<NoteDB> unSyncedNotes = [];
//     log(unSyncedNotes.length.toString());
//     cloudNotes = await Services().getAllNotesOfAllUsers();
//     for (var i in cloudNotes) {
//       if (i.isSynced == 'false' || i.isUpdated == 'false') {
//         unSyncedNotes.add(i);
//       }
//     }
//     cloudNotes = [];
//     cloudNotes = unSyncedNotes;
//     cloudNotesStreamController.add(cloudNotes);
//     print(cloudNotes.length.toString());
//     return cloudNotes;
//   }

  // Future<void> createOrUpdatedCloudNote() async {
  //   final notes = await getAllUnSyncedNotes();
  //   final owner = FirebaseAuth.instance.currentUser;
  //   for (var i in notes) {
  //     if (i.isSynced == 'false') {
  //       final note =
  //           await firebaseCloudStorage.createCloudNote(ownerUserId: owner!.uid);
  //       await Services().updateNote(
  //         noteId: i.noteId,
  //         title: i.title,
  //         content: i.content,
  //         importance: i.importance,
  //         isSynced: 'true',
  //         isUpdated: 'false',
  //         documentId: note.documentId,
  //       );
  //     }

  //     if (i.isUpdated == 'false') {
  //       final fetchedNote = await Services().getNote(noteId: i.noteId);
  //       await firebaseCloudStorage.updatedCloudNote(
  //         documentId: fetchedNote.documentId,
  //         title: i.title,
  //         content: i.content,
  //         importance: enumToString(i.importance),
  //       );
  //       await Services().updateNote(
  //         noteId: i.noteId,
  //         title: i.title,
  //         content: i.content,
  //         importance: i.importance,
  //         isSynced: 'true',
  //         isUpdated: 'true',
  //         documentId: fetchedNote.documentId,
  //       );
  //     }
  //     // cloudNotes.removeWhere((note) => note.noteId == i.noteId);
  //   }
  // }