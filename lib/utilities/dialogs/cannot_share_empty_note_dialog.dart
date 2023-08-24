import 'package:flutter/widgets.dart';
import 'package:projectx/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You can\'t share empty note',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
