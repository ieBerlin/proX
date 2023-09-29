import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/firebase_cloud_storage.dart';
import 'package:projectx/services/crud/current_crud.dart';

class AllNotesStation {
  final CRUDServices _crudServices = CRUDServices();
  // final FirebaseCloudStorage _firebaseCloudStorage = FirebaseCloudStorage();
  String get userId => FirebaseAuth.instance.currentUser!.uid;
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

  Stream<List<CloudNote>> get allNotes => _crudServices.localNotes;
}
