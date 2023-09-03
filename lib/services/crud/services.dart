import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectx/constants/db_constants/constants.dart';
import 'package:projectx/extentions/list/filter.dart';
import 'package:projectx/services/auth/auth_exceptions.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:projectx/services/cloud/cloud_services.dart';
import 'package:projectx/services/cloud/upload_note.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' show join;
import '../../enums/enums.dart';
import 'crud_exceptions.dart';
import 'user_notes_databases/notedb.dart';
import 'user_notes_databases/userdb.dart';

class UserShouldBeSetBeforeReadingAllNotes implements Exception {}

class Services {
  String get email => AuthService.firebase().currentUser!.email;
  String get userUId => FirebaseAuth.instance.currentUser!.uid;

  static final Services _shared = Services._sharedInstance();
  factory Services() => _shared;
  Database? _db;
  List<NoteDB> _notes = [];
  UserDB? _user;
  late final StreamController<List<NoteDB>> _notesStreamController;

  Services._sharedInstance() {
    _notesStreamController =
        StreamController<List<NoteDB>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }

  CloudServices cloudServicesInstance = CloudServices();
  Stream<List<NoteDB>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.id == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<void> _cacheNotes() async {
    final allNote = await getAllNotesOfAllUsers();
    _notes = allNote.toList();
    // cloudServicesInstance.cloudNotes = allNote.toList();
    _notesStreamController.add(_notes);
  }

  Future<void> deleteNoteFromAction({required int noteId}) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final result = await db.delete(
      noteActionTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    log(noteId);
    if (result == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<void> prepareNoteToUploadWhileUserIsOnline({
    required int noteId,
    required String action,
    required String userId,
  }) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    if (action == 'CREATE') {
      await db.insert(noteActionTable, {
        noteIdActionColumn: noteId,
        actionActionColumn: action,
        userIdActionColumn: userId,
      });
    } else if (action == 'UPDATE') {
      await db.update(
        noteActionTable,
        {
          actionActionColumn: action,
        },
        where: 'noteId = ?',
        whereArgs: [noteId],
      );
    } else {
      final note = await getNote(noteId: noteId);
      if (note.documentId == 'DEFAULT_NULL') {
        await db.delete(
          noteActionTable,
          where: 'noteId = ?',
          whereArgs: [noteId],
        );
      } else {
        //prepare to delete from remote server
      }
    }
  }

  Future<Iterable<UploadNote>> getAllNotesThatShoudlUploaded() async {
    // await Future.delayed(const Duration(seconds: 3));
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final notes = await db.query(noteActionTable);
    return notes.map((note) => UploadNote.fromRow(note));
  }

  Future<void> openDb() async {
    if (_db != null) {
      throw DatabaseIsAlreadyOpenedException();
    }
    try {
      final dbPath = await getApplicationDocumentsDirectory();
      final path = join(dbPath.path, databaseName);
      final db = await openDatabase(path);
      _db = db;
      await db.execute(createUserTableSql);
      await db.execute(createNoteTableSql);
      await db.execute(noteActionTableSql);
      await _cacheNotes();
    } catch (e) {
      throw GenericExceptionExceptionForCRUD();
    }
  }

  Future<void> ensureOpeningDb() async {
    try {
      await openDb();
    } on DatabaseIsAlreadyOpenedException {
      ('The Database is already opened, continue');
    } on GenericExceptionExceptionForCRUD catch (e) {
      ('An error occured while opening the database : $e');
    } catch (e) {
      ('An error occured while opening the database : $e');
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsAlreadyClosedException();
    } else {
      db.close();
      _db = null;
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

  Future<UserDB> getOrCreateUser(
      {required String email, bool setAsCurrentUser = true}) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      _user = user;
      return user;
    } on UserNotFoundExceptionForCRUD catch (_) {
      final createdUser = await createAnUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } on DatabaseIsntOpenedExceptionForCRUD catch (_) {
      throw GenericException();
    } on GenericException catch (_) {
      throw GenericException();
    } catch (e) {
      // it was
      // throw GenericException();
      rethrow;
    }
  }

  Future<UserDB> getUser({required String email}) async {
    await ensureOpeningDb();
    try {
      final db = getDbOrThrow();
      final userResults = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      if (userResults.isEmpty) {
        throw UserNotFoundExceptionForCRUD();
      } else {
        return UserDB.fromRow(userResults.last);
      }
    } on UserNotFoundExceptionForCRUD catch (_) {
      throw UserNotFoundExceptionForCRUD();
    } on DatabaseIsntOpenedExceptionForCRUD catch (_) {
      throw DatabaseIsntOpenedExceptionForCRUD();
    } catch (e) {
      throw GenericException();
    }
  }

  Future<NoteDB> createNote(
    String? documentId, {
    required String title,
    required String content,
    required NoteImportance importance,
    required UserDB owner,
  }) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    await getUser(email: owner.email);
    final noteId = await db.insert(noteTable, {
      idColumn: owner.id,
      titleColumn: title,
      contentColumn: content,
      importanceColumn: enumToString(importance),
      documentIdColumn: documentId ?? 'DEFAULT_NULL',
    });
    final note = NoteDB(
      noteId: noteId,
      id: owner.id,
      title: title,
      content: content,
      importance: importance,
      documentId: documentId ?? 'DEFAULT_NULL',
    );
    if (documentId == null) {
      await prepareNoteToUploadWhileUserIsOnline(
        noteId: noteId,
        action: 'CREATE',
        userId: userUId,
      );
    }

    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int noteId}) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();

    final result = await db.delete(
      noteTable,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    await prepareNoteToUploadWhileUserIsOnline(
      noteId: noteId,
      action: 'DELETE',
      userId: userUId,
    );
    if (result == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.noteId == noteId);
      _notesStreamController.add(_notes);
    }
  }
// NoteDB.convertingQueryRowToNoteObjecy(Map<String, Object?> map):

  Future<int> getNoteOnDocumentId({required String documentId}) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final notes = await db.query(
      noteTable,
      where: 'documentId = ?',
      whereArgs: [documentId],
    );

    if (notes.isEmpty) {
      throw CouldNotFindTheNote();
    } else {
      final note = covertingQueryRowToANoteDbObject(notes);
      return note.noteId;
    }
  }

  Future<int> deleteAllNoteOfProviderUser({required String email}) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final user = await getUser(email: email);
    final result = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [user.id],
    );
    if (result == 0) {
      throw CouldNotDeleteAllNotesOfProvidedEmailUser();
    } else {
      _notes = [];
      // cloudServicesInstance.cloudNotes = [];
      _notesStreamController.add(_notes);
      // cloudServicesInstance.cloudNotesStreamController.add(_notes);
      return result;
    }
  }

  Future<void> deleteAllNoteOfAllUsers() async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final result = await db.delete(noteTable);
    if (result == 0) {
      throw CouldNotDeleteAllNotesOfAllUsers();
    } else {
      _notes = [];
      // cloudServicesInstance.cloudNotes = [];
      _notesStreamController.add(_notes);
      // cloudServicesInstance.cloudNotesStreamController.add(_notes);
    }
  }

  Future<void> updateNoteDocumentId({
    required String documentId,
    required int noteId,
  }) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    await db.update(
      noteTable,
      {
        documentIdColumn: documentId,
      },
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
  }

  Future<NoteDB> updateNote({
    required int noteId,
    required String title,
    required String content,
    required NoteImportance importance,
    required String documentId,
  }) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final initNote = await getNote(noteId: noteId);
    if (initNote.title != title ||
        initNote.content != content ||
        initNote.importance != importance ||
        initNote.documentId != documentId) {
      await db.update(
        noteTable,
        {
          titleColumn: title,
          contentColumn: content,
          importanceColumn: enumToString(importance),
          documentIdColumn: documentId,
        },
        where: 'noteId = ?',
        whereArgs: [noteId],
      );
    }

    await prepareNoteToUploadWhileUserIsOnline(
      noteId: noteId,
      action: 'UPDATE',
      userId: userUId,
    );

    final updatedNote = await getNote(noteId: noteId);
    _notes.removeWhere((note) => updatedNote.noteId == note.noteId);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<List<NoteDB>> getAllNotesOfAllUsers() async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    List<NoteDB> returnedNotes = [];
    final notes = await db.query(noteTable);

    for (final i in notes) {
      returnedNotes.add(covertingQueryRowToANoteDbObject(i.values));
    }
    return returnedNotes;
  }

  Future<List<NoteDB>> getAllNotes({required int id}) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    List<NoteDB> returnedNotes = [];
    final notes = await db.query(noteTable, where: 'id = ?', whereArgs: [id]);
    if (notes.isEmpty) {
      ////
      throw CouldNotFindTheAtLeastOneNote();
    } else {
      for (final i in notes) {
        returnedNotes.add(covertingQueryRowToANoteDbObject(i.values));
      }
      (returnedNotes.toString());
    }
    return returnedNotes;
  }

  Future<NoteDB> getNoteForCloud({required String documentId}) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final note = await db.query(
      noteTable,
      limit: 1,
      where: 'documentId = ?',
      whereArgs: [documentId],
    );
    if (note.isEmpty) {
      throw CouldNotFindTheNote();
    } else {
      final fetchedNote = note[0];
      _notes.add(covertingQueryRowToANoteDbObject(fetchedNote.values));
      return covertingQueryRowToANoteDbObject(fetchedNote.values);
    }
  }

  Future<NoteDB> getNote({required int noteId}) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final note = await db.query(
      noteTable,
      limit: 1,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    if (note.isEmpty) {
      throw CouldNotFindTheNote();
    } else {
      final fetchedNote = note[0];
      _notes.removeWhere((note) => noteId == note.noteId);

      _notes.add(covertingQueryRowToANoteDbObject(fetchedNote.values));
      _notesStreamController.add(_notes);
      return covertingQueryRowToANoteDbObject(fetchedNote.values);
    }
  }

  Future<UserDB> createAnUser({required String email}) async {
    await ensureOpeningDb();
    try {
      final db = getDbOrThrow();

      final userResults = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email],
      );
      if (userResults.isNotEmpty) {
        throw UserAlreadyExistsBerlin();
      } else {
        final id = await db.insert(userTable, {
          emailColumn: email.toLowerCase(),
        });
        return UserDB(id: id, email: email);
      }
    } on UserAlreadyExistsBerlin catch (e) {
      ('user already exists $e');
      throw UserAlreadyExistsBerlin();
    } on DatabaseIsntOpenedExceptionForCRUD catch (e) {
      ('Database isnt opened $e');
      throw DatabaseIsntOpenedExceptionForCRUD();
    } catch (e) {
      ('Generic exception');
      throw GenericException();
    }
  }

  Future<void> deleteUser({required String email}) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }
}
