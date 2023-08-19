import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectx/enums/enums.dart';
import 'package:projectx/enums/methods.dart';

class PriorityIndex {
  int index;
  PriorityIndex({required this.index});
}

class PriorityBloc extends Cubit<PriorityIndex> {
  final NoteImportance initNoteImportance;
  PriorityBloc({required this.initNoteImportance})
      : super(PriorityIndex(
            index: enumToIndex(noteImportance: initNoteImportance)));
  void indexChanger(int index) => emit(PriorityIndex(index: index));
}
