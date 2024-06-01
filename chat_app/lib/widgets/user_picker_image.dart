import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserPickerImage extends StatefulWidget {
  const UserPickerImage({super.key, required this.onSelectImage});

  final void Function(File image) onSelectImage;

  @override
  State<UserPickerImage> createState() => _UserPickerImageState();
}

class _UserPickerImageState extends State<UserPickerImage> {
  File? _image;
  void _pickImage() async {
    final pickImage = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 50, maxHeight: 150);
    if (pickImage == null) return;
    setState(() {
      _image = File(pickImage.path);
    });

    widget.onSelectImage(File(pickImage.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black54,
          foregroundImage: _image != null ? FileImage(_image!) : null,
        ),
        const SizedBox(
          height: 10,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            "Pick Image",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
