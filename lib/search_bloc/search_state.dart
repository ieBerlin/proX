import 'package:projectx/services/cloud/cloud_note.dart';

abstract class SearchState {}

class SearchInitialState extends SearchState {}

class SearchResultsState extends SearchState {
  final Iterable<CloudNote> results;

  SearchResultsState({required this.results});
}

class SearchEmptyState extends SearchState {
  final String query;
  SearchEmptyState({required this.query});
}
