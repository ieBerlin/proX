const idColumn = 'id';
const documentIdColumn = 'documentId';
const emailColumn = 'email';
const titleColumn = 'title';
const contentColumn = 'content';
const importanceColumn = 'importance';
const databaseName = 'dbname.db';
const userTable = 'user';
const noteTable = 'note';
const noteActionTable = 'noteAction';
const noteIdActionColumn = 'noteId';
const actionActionColumn = 'action';
const userIdActionColumn = 'userId';

const createUserTableSql = '''
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL ,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';

const createNoteTableSql = '''
CREATE TABLE IF NOT EXISTS "note" (
  "noteId"	INTEGER NOT NULL,
  "id"	INTEGER NOT NULL,
	"title"	TEXT NOT NULL,
	"content"	TEXT NOT NULL,
  "importance"	TEXT NOT NULL,
  "documentId" TEXT NOT NULL,
	PRIMARY KEY("noteId" AUTOINCREMENT)
);
''';
const noteActionTableSql = '''
CREATE TABLE IF NOT EXISTS "noteAction" (
	"noteId"	INTEGER NOT NULL,
	"action"	TEXT NOT NULL ,
  "userId" TEXT NOT NULL 
);
''';
