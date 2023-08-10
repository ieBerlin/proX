import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:projectx/constants/db_constants/constants.dart';
import 'package:projectx/services/auth/auth_exceptions.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' show join;

import '../../enums/enums.dart';
import 'crud_exceptions.dart';
import 'user_notes_databases/notedb.dart';
import 'user_notes_databases/userdb.dart';

class Services {
  Database? _db;

  static final Services _shared = Services._sharedInstance();
  Services._sharedInstance();
  factory Services() => _shared;

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
    } catch (e) {
      throw GenericExceptionExceptionForCRUD();
    }
  }

  Future<void> ensureOpeningDb() async {
    try {
      await openDb();
    } on DatabaseIsAlreadyOpenedException {
      log('The Database is already opened, continue');
    } on GenericExceptionExceptionForCRUD catch (e) {
      log('An error occured while opening the database : $e');
    } catch (e) {
      log('An error occured while opening the database : $e');
    }
  }

  Future<void> close() async {
    if (_db == null) {
      throw DatabaseIsAlreadyClosedException();
    } else {
      _db!.close();
    }
  }

  Database getDbOrThrow() {
    final db = _db;
    if (db == null) {
      log('Could not load the database because it\'s not opened');
      throw DatabaseIsntOpenedExceptionForCRUD();
    } else {
      return db;
    }
  }

  Future<UserDB> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on UserNotFoundExceptionForCRUD catch (_) {
      final user = await createAnUser(email: email);
      return user;
    } on DatabaseIsntOpenedExceptionForCRUD catch (_) {
      log('message');
      throw GenericException();
    } on GenericException catch (_) {
      log('message');
      throw GenericException();
    } catch (e) {
      log('message');
      throw GenericException();
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
    } on UserNotFoundExceptionForCRUD catch (e) {
      log('Database isnt opened $e');
      throw UserNotFoundExceptionForCRUD();
    } on DatabaseIsntOpenedExceptionForCRUD catch (e) {
      log('Database isnt opened $e');
      throw DatabaseIsntOpenedExceptionForCRUD();
    } catch (e) {
      log('Generic exception');

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
    final user = await getUser(email: owner.email);
    if (user != owner) {
      throw CouldNotFineTheUser();
    }

    final noteId = await db.insert(noteTable, {
      idColumn: owner.id,
      titleColumn: title,
      contentColumn: content,
      importanceColumn: enumToString(importance),
    });
    return NoteDB(
      noteId: noteId,
      id: owner.id,
      title: title,
      content: content,
      importance: importance,
    );
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
      log(returnedNotes.toString());
    }
    return returnedNotes;
  }

  Future<NoteDB> getNote({required int id}) async {
    await ensureOpeningDb();
    final db = getDbOrThrow();
    final note = await db.query(
      noteTable,
      limit: 1,
      where: 'noteId = ?',
      whereArgs: [id],
    );
    if (note.isEmpty) {
      throw CouldNotFindTheNote();
    } else {
      return NoteDB.fromRow(note.first);
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
      log('user already exists $e');
      throw UserAlreadyExistsBerlin();
    } on DatabaseIsntOpenedExceptionForCRUD catch (e) {
      log('Database isnt opened $e');
      throw DatabaseIsntOpenedExceptionForCRUD();
    } catch (e) {
      log('Generic exception');
      throw GenericException();
    }
  }
}
