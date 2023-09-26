import 'package:projectx/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogOutDialog( BuildContext context) {
  return showGenericDialog<bool>(
          context: context,
          title: 'Log out',
          content: 'Are you sure you want to log out ?',
          optionBuilder: () => {'Cancel': false, 'Log Out': true})
      .then((value) => value ?? false);
}
