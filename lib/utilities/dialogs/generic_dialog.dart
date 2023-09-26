import 'package:flutter/material.dart';
import 'package:projectx/UI/tools/constants.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder();
  return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: lightBlackColor(),
          title: Text(
            title,
            style: TextStyle(
              color: white(),
              fontFamily: "SF-Compact-Display-Bold",
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: white(),
              fontFamily: 'SF-Compact-Rounded-Semibold',
            ),
          ),
          actions: options.keys.map((optionTitle) {
            final value = options[optionTitle];
            return TextButton(
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                optionTitle,
                style: TextStyle(
                  color: amber(),
                  fontFamily: "SF-Compact-Display-Bold",
                ),
              ),
            );
          }).toList(),
        );
      });
}
