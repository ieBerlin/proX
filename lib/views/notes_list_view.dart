import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/UI/tools/constants.dart';
import 'package:projectx/UI/tools/grid_view_widget.dart';
import 'package:projectx/services/auth/bloc/search_bloc/search_bloc.dart';
import 'package:projectx/services/auth/bloc/search_bloc/search_state.dart';
import 'package:projectx/services/cloud/cloud_note.dart';

typedef NoteCallBack = void Function(CloudNote note);

class GridViewClass extends StatelessWidget {
  final Iterable<CloudNote> notes;
  // final NoteCallBack onDeleteNote;
  final NoteCallBack onTap;
  const GridViewClass({
    super.key,
    required this.notes,
    // required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2 - 16;
    final double itemHeight = size.width / 3.5;
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchInitialState) {
          return gridViewBuilder(itemWidth, itemHeight, notes, onTap);
        } else if (state is SearchEmptyState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Could not find\n"${state.query}"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: white(),
                    fontFamily: "SF-Compact-Display-Bold",
                    fontSize: 27,
                  ),
                ),
                const Text(
                  'Try Searching again using a different\nspelling or keyword.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(255, 96, 96, 96),
                      fontFamily: "SF-Compact-Display-Regular",
                      fontSize: 16),
                )
              ],
            ),
          );
        } else if (state is SearchResultsState) {
          return gridViewBuilder(itemWidth, itemHeight, state.results, onTap);
        } else {
          return Container();
        }
      },
    );
  }
}
