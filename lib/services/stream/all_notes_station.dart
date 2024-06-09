import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/firebase_cloud_storage.dart';
import 'package:projectx/services/crud/current_crud.dart';

class AllNotesStation {
  final ownerUserId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseCloudStorage _firebaseCloudStorage = FirebaseCloudStorage();
  final CRUDServices _crudServices = CRUDServices();
  List<CloudNote> _notes = [];
  late final StreamController<List<CloudNote>> _notesStreamController;
  static final AllNotesStation _shared = AllNotesStation._sharedInstance();
  factory AllNotesStation() => _shared;
  AllNotesStation._sharedInstance() {
    _notesStreamController =
        StreamController<List<CloudNote>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }

  Stream<Iterable<CloudNote>> allNotes() {
    final localNotes = _crudServices.localNotes;
    final cloudNotes = _firebaseCloudStorage.allNotes(ownerUserId: ownerUserId);
    StreamController<Iterable<CloudNote>> controller =
        StreamController<Iterable<CloudNote>>();
    localNotes.listen((event) {
      controller.add(event);
    });
    cloudNotes.listen((event) {
      controller.add(event);
    });
    return controller.stream;
  }
}
