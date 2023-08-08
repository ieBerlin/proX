import 'package:flutter/material.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String content,
}) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('An error occured'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      });
}
