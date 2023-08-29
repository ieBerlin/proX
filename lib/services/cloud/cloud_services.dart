import 'dart:async';
import 'package:projectx/services/crud/services.dart';
import 'package:projectx/services/crud/user_notes_databases/notedb.dart';

class CloudServices {
  final Services _services = Services();
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
  // Future<void> getAllUnSyncedNotes() async {
  //   final notes = await _services.getAllNotesOfAllUsers();
  //   List<NoteDB> unSyncedNotes = [];
  //   for (var i in notes) {
  //     if (i.isSynced == 'false') {
  //       unSyncedNotes.add(i);
  //     }
  //   }
  //   final finalNotes = unSyncedNotes.toList();
  //   cloudNotesStreamController.add(finalNotes);
  // }
}
