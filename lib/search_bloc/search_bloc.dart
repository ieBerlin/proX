import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/search_bloc/search_event.dart';
import 'package:projectx/search_bloc/search_state.dart';
import 'package:projectx/services/cloud/cloud_note.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ownerUserId = FirebaseAuth.instance.currentUser!.uid;
  SearchBloc() : super(SearchInitialState()) {
    on<SearchTextChanged>((event, emit) async {
      if (event.query == '') {
        emit(SearchInitialState());
      } else {
        List<CloudNote> fetchedNotes = [];
        final allNotes = event.notes;

        for (var note in allNotes) {
          if (note.title.toLowerCase().contains(event.query.toLowerCase())) {
            fetchedNotes.add(note);
          }
        }
        if (fetchedNotes.isEmpty) {
          emit(SearchEmptyState(query: event.query));
        } else {
          emit(SearchResultsState(results: fetchedNotes));
        }
      }
    });
  }
}

// Future<List<CloudNote>> fetchData({required String query}) async {
//     // Fetch data from Firestore and return it as a list of DocumentSnapshot
//     List<CloudNote> fetchedNotes = [];
//     await FirebaseFirestore.instance
//         .collection('notes')
//         .where(
//           ownerUserIdFieldName,
//           isEqualTo: FirebaseAuth.instance.currentUser!.uid,
//         )
//         .get()
//         .then((QuerySnapshot querySnapshot) {
//       querySnapshot.docs.forEach((doc) {
//         String title = doc['title'];
//         if (title.toLowerCase().contains(query.toLowerCase())) {
//           fetchedNotes.add(CloudNote.fromIterable(doc));
//         }
//       });
//     });
//     return fetchedNotes;
//   }