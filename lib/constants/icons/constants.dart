import 'package:flutter/material.dart';

Icon visibility({required bool isPressed}) {
  if (!isPressed) {
    return Icon(
      Icons.visibility,
      color: Colors.grey[700],
    );
  } else {
    return Icon(Icons.visibility_off, color: Colors.grey[700]);
  }
}
