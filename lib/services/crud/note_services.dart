import 'dart:developer';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:projectx/services/auth/auth_exceptions.dart';
import 'package:projectx/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class NoteServices {
  Database? _db;

  static final NoteServices _shared = NoteServices._sharedInstance();
  NoteServices._sharedInstance();
  factory NoteServices() => _shared;
  Database getDbOrThrow() {
    final db = _db;
    if (db == null) {
      log('database is opened');
      throw DatabaseAlreadyOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = getDbOrThrow();
    try {
      db.close();
    } on DatabaseAlreadyOpenException catch (e) {
      log('db is already opened');
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on UserNotFoundException {
      final user = await createUser(email: email);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await ensureDbIsOpen();
    final db = getDbOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      log('user not found');
      throw UserNotFoundException();
    } else {
      log('user found');
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseNotes> createNote(
      {required DatabaseUser owner, required DatabaseNotes note}) async {
    await ensureDbIsOpen();
    final db = getDbOrThrow();

    // final user =

    await getUser(email: owner.email);
    // if (owner != user) {
    //   log('user isn\'t the owner');
    //   throw UserNotFoundException();
    // }
    final noteId = await db.insert(noteTable, {
      idColumn: note.id,
      titleColumn: note.title,
      contentColumn: note.content,
      importanceColumn: note.importance,
    });
    final returnedNote = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      title: note.title,
      content: note.content,
      importance: note.importance,
    );
    return returnedNote;
  }

  Future<void> ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException catch (e) {
      log(e.toString());
      log('data is already opened');
      throw DatabaseIsAlreadyOpenedException();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await ensureDbIsOpen();
    final db = getDbOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      log('user is already created');
      throw UserIsAlreadyCreated();
    }
    log('fetching data..');
    final userId = await db.insert(userTable, {emailColumn: email});
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    ensureDbIsOpen();
    final db = getDbOrThrow();
    final deletedCount = db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    // ignore: unrelated_type_equality_checks
    if (deletedCount != 1) {
      throw UserNotFoundException();
    }
  }

  Future<void> open() async {
    if (_db != null) {
      log('data base is already opened');
      throw DatabaseIsAlreadyOpenedException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final path = join(docsPath.path, dbName);
      final db = await openDatabase(path);
      _db = db;
      await db.execute(createUserTableSql);
      await db.execute(createNoteTableSql);
    } catch (e) {
      log('An error occured while opening database $e');
      throw DatabaseAlreadyOpenException();
    }
  }

// List<>
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String title;
  final String content;
  final NoteImportance importance;

  const DatabaseNotes({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.importance,
  });
}

class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, Email = $email';
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum NoteImportance {
  red,
  green,
  yellow,
}

class DatabaseAlreadyOpenException implements Exception {}

const dbName = 'database.name';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const titleColumn = 'title';
const contentColumn = 'content';
const importanceColumn = 'importance';
const createNoteTableSql = '''
CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"title"	TEXT NOT NULL,
	"content"	TEXT NOT NULL,
	"importance"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';
const createUserTableSql = '''
CREATE TABLE IF NOT EXISTS "user" (
	"user_id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL ,
	PRIMARY KEY("user_id" AUTOINCREMENT)
);
''';
