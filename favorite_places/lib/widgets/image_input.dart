import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.handlePickImage});

  final void Function(File image) handlePickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedFile;

  void takePicture() async {
    final imagePicker = ImagePicker();
    final pickerImage =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (pickerImage == null) {
      return;
    }
    setState(() {
      _selectedFile = File(pickerImage.path);
    });

    widget.handlePickImage(_selectedFile!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: TextButton.icon(
        icon: const Icon(Icons.camera),
        label: const Text("Take picture"),
        onPressed: takePicture,
      ),
    );
    if (_selectedFile != null) {
      content = GestureDetector(
          onTap: takePicture,
          child: Image.file(
            _selectedFile!,
            fit: BoxFit.cover,
            width: double.infinity,
          ));
    }

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: content,
    );
  }
}
