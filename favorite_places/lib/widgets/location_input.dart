import 'dart:convert';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.handlePickLocation});

  final void Function(PlaceLocation location) handlePickLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _placeLocation;
  var _isLoading = false;

  String get imageSource {
    if (_placeLocation == null) {
      return "";
    }
    final lat = _placeLocation?.latitude;
    final long = _placeLocation?.longitude;
    return "https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$long&key=AIzaSyAI9kPkskayYti5ttrZL_UfBlL3OkMEbvs";
  }

  Future<void> _savePlace(PlaceLocation location) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=AIzaSyAI9kPkskayYti5ttrZL_UfBlL3OkMEbvs");
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address'];
    setState(() {
      _placeLocation = PlaceLocation(
          latitude: location.latitude,
          longitude: location.longitude,
          address: address);
      _isLoading = false;
    });
  }

  void _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });
    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final long = locationData.longitude;

    if (lat == null || long == null) {
      return;
    }

    _savePlace(_placeLocation!);

    widget.handlePickLocation(_placeLocation!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Text(
      "No location choosen",
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );

    if (_isLoading) {
      content = const CircularProgressIndicator();
    }

    if (_placeLocation != null) {
      content = Image.network(
        imageSource,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          ),
          child: Center(
            child: content,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text("Get current location"),
            ),
            TextButton.icon(
              onPressed: () async {
                final data = await Navigator.of(context)
                    .push<PlaceLocation>(MaterialPageRoute(
                  builder: (context) => MapScreen(
                    isSelecting: true,
                    placeLocation: _placeLocation ??
                        PlaceLocation(
                            address: "", latitude: -31, longitude: 118),
                  ),
                ));
                await _savePlace(data!);
                widget.handlePickLocation(_placeLocation!);
              },
              icon: const Icon(Icons.map),
              label: const Text("Select on map"),
            )
          ],
        ),
      ],
    );
  }
}
