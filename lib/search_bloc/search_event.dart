import 'package:projectx/services/cloud/cloud_note.dart';

abstract class SearchEvent {}

class SearchTextChanged extends SearchEvent {
  final String query;
  final Iterable<CloudNote> notes;
  SearchTextChanged({
    required this.query,
    required this.notes,
  });
}
