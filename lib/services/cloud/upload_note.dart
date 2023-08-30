import 'package:projectx/constants/db_constants/constants.dart';

class UploadNote {
  final int noteId;
  final String action;
  final String userId;
  const UploadNote({
    required this.noteId,
    required this.action,
    required this.userId,
  });
  UploadNote.fromRow(Map<String, Object?> map)
      : noteId = map[noteIdActionColumn] as int,
        action = map[actionActionColumn] as String,
        userId = map[userIdActionColumn] as String;
}
