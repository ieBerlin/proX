const idColumn = 'id';
const isSyncedColumn = 'isSynced';
const isUpdatedColumn = 'isUpdated';
const documentIdColumn = 'documentId';
const emailColumn = 'email';
const noteIdColumn = 'note_id';
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
  "noteId"	INTEGER NOT NULL,
  "id"	INTEGER NOT NULL,
	"title"	TEXT NOT NULL,
	"content"	TEXT NOT NULL,
  "importance"	TEXT NOT NULL,
  "isSynced" TEXT NOT NULL,
  "isUpdated" TEXT NOT NULL,
  "documentId" TEXT NOT NULL,
	PRIMARY KEY("noteId" AUTOINCREMENT)
);
''';
