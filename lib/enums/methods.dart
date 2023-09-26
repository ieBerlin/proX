import 'package:flutter/material.dart';
import 'package:projectx/UI/tools/constants.dart';
import 'enums.dart';

Color enumsToColors(NoteImportance noteImportance) {
  switch (noteImportance) {
    case NoteImportance.red:
      return red();
    case NoteImportance.yellow:
      return blue();
    case NoteImportance.green:
      return green();
    case NoteImportance.orange:
      return orange();
    default:
      return red();
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
