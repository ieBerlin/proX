import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:projectx/services/auth/auth_exceptions.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

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
    } catch (e) {
      throw GenericExceptionExceptionForCRUD();
    }
  }

  Future<void> ensureOpeningDb() async {
    try {
      await openDb();
    } on DatabaseIsAlreadyOpenedException {
      log('Db is already opened');
    } on GenericExceptionExceptionForCRUD catch (e) {
      log('Generic exception $e');
    } catch (e) {
      log('Generic exception $e');
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

class UserDB {
  final int id;
  final String email;
  const UserDB({
    required this.id,
    required this.email,
  });
  UserDB.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;
}

//constants :

const idColumn = 'id';
const emailColumn = 'email';
const databaseName = 'dbname.db';
const userTable = 'user';
const createUserTableSql = '''
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL ,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';

//exceptions

class DatabaseIsntOpenedCrudBerlin implements Exception {}

class ProblemOccuredException implements Exception {}

class DatabaseIsOpenedException implements Exception {}

class UserAlreadyExistsBerlin implements Exception {}

class DatabaseIsAlreadyClosedException implements Exception {}

class GenericExption12 implements Exception {}
