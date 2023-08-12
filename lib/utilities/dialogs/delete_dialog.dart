import 'package:projectx/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
          context: context,
          title: 'Delete',
          content: 'Are you sure you want to delete this note?',
          optionBuilder: () => {'Cancel': false, 'Delete': true})
      .then((value) => value ?? false);
}
