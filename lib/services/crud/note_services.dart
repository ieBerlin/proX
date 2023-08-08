// import 'dart:developer';

// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
// import 'package:projectx/services/auth/auth_exceptions.dart';
// import 'package:projectx/services/crud/crud_exceptions.dart';
// import 'package:sqflite/sqflite.dart';
// import 'dart:async';

// class NoteServices {
//   Database? _db;

//   static final NoteServices _shared = NoteServices._sharedInstance();
//   NoteServices._sharedInstance();
//   factory NoteServices() => _shared;
//   Database getDbOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsntOpened();
//     } else {
//       return db;
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsntOpened();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<DatabaseUser> getOrCreateUser({required String email}) async {
//     try {
//       final user = await getUser(email: email);
//       return user;
//     } on UserNotFoundCrudException catch (_) {
//       final user = await createUser(email: email);
//       return user;
//     } on UserAlreadyExistsCrudException catch (_) {
//       log('message');
//       throw UserAlreadyExistsCrudException();
//     } catch (e) {
//       log(e.toString());
//       throw GenericCrudException();
//     }
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await ensureDbIsOpen();
//     final db = getDbOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isEmpty) {
//       throw UserNotFoundCrudException();
//     } else {
//       return DatabaseUser.fromRow(results.last);
//     }
//   }

//   Future<DatabaseNotes> createNote({
//     required DatabaseUser owner,
//     required String title,
//     required String content,
//     required NoteImportance importance,
//   }) async {
//     try {
//       await ensureDbIsOpen();
//       final db = getDbOrThrow();
//       final noteId = await db.insert(noteTable, {
//         idColumn: owner.id,
//         titleColumn: title,
//         contentColumn: content,
//         importanceColumn: importance,
//       });
//       final returnedNote = DatabaseNotes(
//         id: noteId,
//         userId: owner.id,
//         title: title,
//         content: content,
//         importance: importance,
//       );
//       return returnedNote;
//     } catch (_) {
//       throw Exception('dfsf');
//     }
//   }

//   Future<void> ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseIsAlreadyOpenedException catch (_) {
//       log('database is already opened');
//     } catch (_) {
//       throw GenericCrudException();
//     }
//   }



//   Future<DatabaseUser> createUser({required String email}) async {
//     await ensureDbIsOpen();
//     final db = getDbOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExistsCrudException();
//     }
//     final userId =
//         await db.insert(userTable, {emailColumn: email.toLowerCase()});
//     return DatabaseUser(id: userId, email: email);
//   }

//   Future<void> deleteUser({required String email}) async {
//     ensureDbIsOpen();
//     final db = getDbOrThrow();
//     final deletedCount = db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     // ignore: unrelated_type_equality_checks
//     if (deletedCount != 1) {
//       throw UserNotFoundException();
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseIsAlreadyOpenedException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final path = join(docsPath.path, dbName);
//       final db = await openDatabase(path);
//       _db = db;
//       await db.execute(createUserTableSql);
//       await db.execute(createNoteTableSql);
//     } catch (e) {
//       throw GenericCrudException();
//     }
//   }

// // List<>
// }

// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });
//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, id = $id, email = $email';
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// enum NoteImportance {
//   red,
//   green,
//   yellow,
// }

// class DatabaseAlreadyOpenException implements Exception {}

// const dbName = 'database.name';
// const noteTable = 'note';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const titleColumn = 'title';
// const contentColumn = 'content';
// const importanceColumn = 'importance';
// const createNoteTableSql = '''
// CREATE TABLE IF NOT EXISTS "note" (
// 	"id"	INTEGER NOT NULL,
// 	"title"	TEXT NOT NULL,
// 	"content"	TEXT NOT NULL,
// 	"importance"	TEXT NOT NULL,
// 	PRIMARY KEY("id" AUTOINCREMENT)
// );
// ''';
// const createUserTableSql = '''
// CREATE TABLE IF NOT EXISTS "user" (
// 	"user_id"	INTEGER NOT NULL,
// 	"email"	TEXT NOT NULL ,
// 	PRIMARY KEY("user_id" AUTOINCREMENT)
// );
// ''';

// class DatabaseNotes {
//   final int id;
//   final int userId;
//   final String title;
//   final String content;
//   final NoteImportance importance;

//   const DatabaseNotes({
//     required this.id,
//     required this.userId,
//     required this.title,
//     required this.content,
//     required this.importance,
//   });
// }
