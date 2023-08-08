import 'package:flutter/material.dart';

Icon visibility({required bool isPressed}) {
  if (isPressed) {
    return const Icon(Icons.visibility);
  } else {
    return const Icon(Icons.visibility_off);
  }
}
