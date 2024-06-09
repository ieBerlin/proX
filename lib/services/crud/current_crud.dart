import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectx/extentions/list/filter.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class CRUDServices {
  String get userId => FirebaseAuth.instance.currentUser!.uid;
  List<CloudNote> _notes = [];
  late final StreamController<List<CloudNote>> _notesStreamController;
  static final CRUDServices _shared = CRUDServices._sharedInstance();
  factory CRUDServices() => _shared;
  Database? _db;
  CRUDServices._sharedInstance() {
    _notesStreamController =
        StreamController<List<CloudNote>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }

  Stream<List<CloudNote>> get localNotes =>
      _notesStreamController.stream.filter((note) => note.userId == userId);

  //method :

  Future<void> openDB() async {
    if (_db != null) {
    } else {
      try {
        final dbPath = await getApplicationDocumentsDirectory();
        final path = join(dbPath.path, localDB);
        final db = await openDatabase(path);
        _db = db;
        await db.execute(sql);
        await _cacheNotes();
      } catch (e) {
        log(e.toString());
        throw GenericExceptionExceptionForCRUD();
      }
    }
  }

  Future<void> closeDB() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsAlreadyClosedException();
    } else {
      db.close();
      _db = null;
    }
  }

  Future<void> ensureOpeningDb() async {
    try {
      await openDB();
    } catch (err) {
      print(err);
    }
  }

  Database getDbOrThrow() {
    final db = _db;
    if (db == null) {
      ('Could not load the database because it\'s not opened');
      throw DatabaseIsntOpenedExceptionForCRUD();
    } else {
      return db;
    }
  }

  Future<CloudNote> createNote({
    required String title,
    required String content,
    required String importance,
  }) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final noteId = await db.insert(noteTable, {
      userIdLocalDB: userId,
      titleLocalDB: title,
      contentLocalDB: content,
      importanceLocalDB: 'red',
    });

    final note = CloudNote(
      noteId: noteId,
      userId: userId,
      title: title,
      content: content,
      importance: importance,
      documentId: 'DEFAULT-NULL',
    );
    log('created note');
    log(note.toString());
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<CloudNote> updateNote({
    required int noteId,
    required String title,
    required String content,
    required String importance,
  }) async {
    log('from update notet');
    log(noteId.toString());
    await ensureOpeningDb();
    final db = getDbOrThrow();
    await getNote(noteId: noteId);
    final updatedCount = await db.update(
      noteTable,
      {
        titleLocalDB: title,
        contentLocalDB: content,
        importanceLocalDB: importance,
      },
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    if (updatedCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(noteId: noteId);
      _notes.removeWhere(
        (note) =>
            updatedNote.title == note.title &&
            updatedNote.content == note.content &&
            updatedNote.importance == note.importance,
      );
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<CloudNote> getNote({required int noteId}) async {
    log('from get note');
    log(noteId.toString());
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final notes = await db.query(
      noteTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    final note = CloudNote.convertingRowToCloudNote(object: notes.first);
    log(note.toString());
    _notes.removeWhere((fetchedNote) => fetchedNote.noteId == note.noteId);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({
    required int noteId,
  }) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final fetchedNote = await getNote(noteId: noteId);
    final resultOfDeleting = await db.delete(
      noteTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    if (resultOfDeleting == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.noteId == fetchedNote.noteId);
      _notesStreamController.add(_notes);
    }
  }

  Future<Iterable<CloudNote>> allNotesOfCurrentUser({
    required String userId,
  }) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final notes = await db.query(
      noteTable,
      // where: 'userId = ',
      // whereArgs: [userId],
    );

    return notes
        .map((object) => CloudNote.convertingRowToCloudNote(object: object));
  }

  Future<Iterable<CloudNote>> allNotes() async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final notes = await db.query(noteTable);
    return notes
        .map((object) => CloudNote.convertingRowToCloudNote(object: object));
  }

  Future<void> _cacheNotes() async {
    final allNote = await allNotesOfCurrentUser(userId: userId);
    _notes = allNote.toList();
    _notesStreamController.add(_notes);
  }
}

// constants
const localDB = 'projectX.db';
const noteIdDB = 'noteId';
const userIdLocalDB = 'userId';
const titleLocalDB = 'title';
const contentLocalDB = 'content';
const importanceLocalDB = 'importance';
const noteTable = 'notes';
const sql = '''
CREATE TABLE IF NOT EXISTS "notes"(
  "noteId" INTEGER NOT NULL,
  "userId" Text NOT NULL,
	"title"	TEXT NOT NULL,
	"content"	TEXT NOT NULL,
  "importance"	TEXT NOT NULL,
 	PRIMARY KEY("noteId" AUTOINCREMENT)
  );
''';
