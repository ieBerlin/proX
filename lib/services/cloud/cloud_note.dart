import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectx/services/crud/current_crud.dart';
import 'package:projectx/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final int noteId;
  final String userId;
  final String title;
  final String content;
  final String importance;
  final String documentId;
  const CloudNote({
    this.noteId = -1,
    required this.userId,
    required this.title,
    required this.content,
    required this.importance,
    required this.documentId,
  });

  CloudNote.convertingRowToCloudNote({required Map<String, Object?> object})
      : noteId = object[noteIdDB] as int,
        userId = object[userIdLocalDB] as String,
        title = object[titleLocalDB] as String,
        content = object[contentLocalDB] as String,
        importance = object[importanceLocalDB] as String,
        documentId = 'DEFAULT-NULL';

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : noteId = (snapshot.data()[noteIdFieldName] ?? -1) as int,
        userId = FirebaseAuth.instance.currentUser!.uid,
        title = snapshot.data()[titleFieldName] as String,
        content = snapshot.data()[contentFieldName] as String,
        importance = snapshot.data()[importanceFieldName] as String,
        documentId = snapshot.id;
  CloudNote.fromIterable(QueryDocumentSnapshot<Object?> snapshot)
      : noteId = (snapshot[noteIdFieldName] ?? -1) as int,
        userId = snapshot[ownerUserIdFieldName] as String,
        title = snapshot[titleFieldName] as String,
        content = snapshot[contentFieldName] as String,
        importance = snapshot[importanceFieldName] as String,
        documentId = snapshot.id;
  @override
  String toString() {
    return 'userid : $userId, title :  $title,documentid :$documentId content : $content, importance : $importance';
  }
}
