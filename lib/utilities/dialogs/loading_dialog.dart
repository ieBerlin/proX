import 'package:flutter/material.dart';
import 'package:projectx/UI/tools/constants.dart';

typedef CloseDialog = void Function();
CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          color: menuBarItemColor(),
        ),
        const SizedBox(height: 10.0),
        Text(text),
      ],
    ),
  );

  showDialog(
    context: context,
    builder: (context) => dialog,
    barrierDismissible: false,
  );

  return () => Navigator.of(context).pop();
}
