import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  const TextFieldInput({
    super.key,
    required this.controller,
    required this.type,
    this.isShowText = false,
    required this.hintText,
  });
  final TextEditingController controller;
  final TextInputType type;
  final bool isShowText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        hintText: hintText,
        border: inputBorder,
        contentPadding: const EdgeInsets.all(10.0),
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
      ),
      obscureText: isShowText,
      keyboardType: type,
    );
  }
}
