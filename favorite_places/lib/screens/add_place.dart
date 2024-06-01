import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/providers/user_places.dart';
import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    File? pickImage;
    PlaceLocation? placeLocation;
    void savePlace() {
      final title = titleController.text;
      if (title.isEmpty || pickImage == null || placeLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please enter a title and pick image and place location'),
          ),
        );
        return;
      }
      ref
          .read(userPlacesProvider.notifier)
          .addPlace(title, pickImage!, placeLocation!);
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: titleController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            ImageInput(
              handlePickImage: (image) {
                pickImage = image;
              },
            ),
            const SizedBox(height: 12),
            LocationInput(
              handlePickLocation: (location) {
                placeLocation = location;
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: savePlace,
              icon: const Icon(Icons.add),
              label: const Text("Add place"),
            ),
          ],
        ),
      ),
    );
  }
}
