const idColumn = 'id';
const emailColumn = 'email';
const noteIdColumn = 'noteId';
const titleColumn = 'title';
const contentColumn = 'content';
const importanceColumn = 'importance';
const databaseName = 'dbname.db';
const userTable = 'user';
const noteTable = 'note';
const createUserTableSql = '''
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL ,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';

const createNoteTableSql = '''
CREATE TABLE IF NOT EXISTS "note" (
    "id"	INTEGER NOT NULL,
  "noteId"	TEXT NOT NULL,
	"title"	TEXT NOT NULL,
	"content"	TEXT NOT NULL,
  "importance"	TEXT NOT NULL
);
''';
