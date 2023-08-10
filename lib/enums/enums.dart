NoteImportance stringToEnums(String myString) {
  switch (myString) {
    case 'orange':
      return NoteImportance.orange;
    case 'red':
      return NoteImportance.red;
    case 'green':
      return NoteImportance.green;
    case 'yellow':
      return NoteImportance.yellow;
    default:
      return NoteImportance.red;
  }
}

enum NoteImportance {
  red,
  orange,
  yellow,
  green,
}

String enumToString(NoteImportance? noteImportance) {
  switch (noteImportance) {
    case NoteImportance.green:
      return 'green';

    case NoteImportance.yellow:
      return 'yellow';
    case NoteImportance.orange:
      return 'orange';
    case NoteImportance.red:
      return 'red';
    default:
      return 'green';
  }
}
