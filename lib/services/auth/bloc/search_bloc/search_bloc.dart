import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/services/auth/bloc/search_bloc/search_event.dart';
import 'package:projectx/services/auth/bloc/search_bloc/search_state.dart';
import 'package:projectx/services/cloud/cloud_note.dart';
import 'package:projectx/services/cloud/firebase_cloud_storage.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ownerUserId = FirebaseAuth.instance.currentUser!.uid;
  SearchBloc() : super(SearchInitialState()) {
    on<SearchTextChanged>((event, emit) async {
      if (event.query == '') {
        emit(SearchInitialState());
      } else {
        List<CloudNote> fetchedNotes =
            await FirebaseCloudStorage().fetchData(query: event.query);
        if (fetchedNotes.isEmpty) {
          emit(SearchEmptyState(query: event.query));
        } else {
          emit(SearchResultsState(results: fetchedNotes));
        }
      }
    });
  }
}
