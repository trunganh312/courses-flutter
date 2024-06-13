import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

pickImage(ImageSource source) async {
  final pickImage = await ImagePicker()
      .pickImage(source: source, imageQuality: 50, maxHeight: 500);
  if (pickImage == null) return;
  return File(pickImage.path);
}

showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).clearSnackBars();
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

String formatDateTime(int millisecondsSinceEpoch) {
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  String formattedDate = DateFormat('h:mm a, MMMM dd, yyyy').format(dateTime);
  return formattedDate;
}
