import 'package:flutter/material.dart';
import 'enums.dart';

Color enumsToColors(NoteImportance noteImportance) {
  switch (noteImportance) {
    case NoteImportance.red:
      return Colors.red;
    case NoteImportance.yellow:
      return Colors.yellow;
    case NoteImportance.green:
      return Colors.green;
    case NoteImportance.orange:
      return Colors.orange;
    default:
      return Colors.red;
  }
}

int enumToIndex({required NoteImportance noteImportance}) {
  switch (noteImportance) {
    case NoteImportance.red:
      return 1;
    case NoteImportance.orange:
      return 2;
    case NoteImportance.yellow:
      return 3;
    case NoteImportance.green:
      return 4;
  }
}
