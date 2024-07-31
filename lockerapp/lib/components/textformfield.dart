import 'package:flutter/material.dart';

Widget buildTextFormField(
    TextEditingController controller, String labelText, double inputWidth) {
  return SizedBox(
    width: inputWidth,
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
    ),
  );
}
