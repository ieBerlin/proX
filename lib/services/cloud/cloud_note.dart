import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectx/constants/db_constants/constants.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String userId;
  final String noteId;
  final String title;
  final String content;
  final String importance;
  final String documentId;
  const CloudNote({
    required this.userId,
    required this.noteId,
    required this.title,
    required this.content,
    required this.importance,
    required this.documentId,
  });
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : userId = snapshot.data()[ownerUserIdFieldName] as String,
        noteId = snapshot.id,
        title = snapshot.data()[titleFieldName] as String,
        content = snapshot.data()[contentFieldName] as String,
        importance = snapshot.data()[importanceFieldName] as String,
        documentId = snapshot.data()[documentIdColumn] as String;
}
