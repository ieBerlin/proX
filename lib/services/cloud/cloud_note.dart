// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:projectx/services/cloud/cloud_storage_constants.dart';

// @immutable
// class CloudNote {
//   final String documentId;
//   final String ownerUserId;
//   final String title;
//   final String content;
//   final String importance;
//   const CloudNote({
//     required this.documentId,
//     required this.ownerUserId,
//     required this.title,
//     required this.content,
//     required this.importance,
//   });

//   CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
//       : documentId = snapshot.id,
//         ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
//         title = snapshot.data()[titleFieldName] as String,
//         content = snapshot.data()[contentFieldName] as String,
//         importance = snapshot.data()[importanceFieldName] as String;
// }
