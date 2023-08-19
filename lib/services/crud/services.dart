import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:projectx/constants/db_constants/constants.dart';
import 'package:projectx/extentions/list/filter.dart';
import 'package:projectx/services/auth/auth_exceptions.dart';
import 'package:projectx/services/auth/auth_service.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' show join;
import '../../enums/enums.dart';
import 'crud_exceptions.dart';
import 'user_notes_databases/notedb.dart';
import 'user_notes_databases/userdb.dart';

class UserShouldBeSetBeforeReadingAllNotes implements Exception {}

class Services {
  static final Services _shared = Services._sharedInstance();
  factory Services() => _shared;
  Database? _db;
  List<NoteDB> _notes = [];
  UserDB? _user;
  Services._sharedInstance() {
    _notesStreamController =
        StreamController<List<NoteDB>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }
  Stream<List<NoteDB>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.id == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  String get email => AuthService.firebase().currentUser!.email;
  late final StreamController<List<NoteDB>> _notesStreamController;

  Future<void> _cacheNotes() async {
    final allNote = await getAllNotesOfAllUsers();
    _notes = allNote.toList();
    _notesStreamController.add(_notes);
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

  Future<NoteDB> createNote({
    required String title,
    required String content,
    required NoteImportance importance,
    required UserDB owner,
  }) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    // final user =
    await getUser(email: owner.email);
    // if (user != owner) {
    //   throw CouldNotFineTheUser();
    // }

    final noteId = await db.insert(noteTable, {
      idColumn: owner.id,
      titleColumn: title,
      contentColumn: content,
      importanceColumn: enumToString(importance),
    });
    final note = NoteDB(
      noteId: noteId,
      id: owner.id,
      title: title,
      content: content,
      importance: importance,
    );
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
    if (result == 0) {
      throw CouldNotDeleteNote();
    } else {
      // final countBefore = _notes.length;

      _notes.removeWhere((note) => note.noteId == noteId);
      // if (_notes.length != countBefore) {
      _notesStreamController.add(_notes);
      ('Note has been deleted successefully');
      // }
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
      _notesStreamController.add(_notes);
      ('All notes of provided user, have been deleted successefully');
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
      _notesStreamController.add(_notes);
      ('All notes have been deleted successefully');
    }
  }

  Future<NoteDB> updateNote({
    required int noteId,
    required String title,
    required String content,
    required NoteImportance importance,
  }) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();

    await getNote(noteId: noteId);
    final note = await db.update(
      noteTable,
      {
        titleColumn: title,
        contentColumn: content,
        importanceColumn: enumToString(importance),
      },
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
    if (note == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(noteId: noteId);
      _notes.removeWhere((note) => updatedNote.noteId == note.noteId);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<List<NoteDB>> getAllNotesOfAllUsers() async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    List<NoteDB> returnedNotes = [];
    final notes = await db.query(noteTable);

    for (final i in notes) {
      returnedNotes.add(covertingQueryRowToANoteDbObject(i.values.toList()));
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
        returnedNotes.add(covertingQueryRowToANoteDbObject(i.values.toList()));
      }
      (returnedNotes.toString());
    }
    return returnedNotes;
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

      /// error
      /// covertingQueryRowToANoteDbObject
      _notes.add(covertingQueryRowToANoteDbObject(fetchedNote.values.toList()));
      _notesStreamController.add(_notes);
      return covertingQueryRowToANoteDbObject(fetchedNote.values.toList());
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
