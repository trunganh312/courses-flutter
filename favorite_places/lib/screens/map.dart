import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  MapScreen({
    super.key,
    required this.placeLocation,
    this.isSelecting = true,
  });

  PlaceLocation placeLocation;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  void _onSavePosition() {
    Navigator.of(context).pop(
      PlaceLocation(
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        address: widget.placeLocation.address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? "Pick your location" : "Your location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: widget.isSelecting ? _onSavePosition : () {},
          ),
        ],
      ),
      body: GoogleMap(
        onTap: widget.isSelecting
            ? (argument) {
                setState(() {
                  _pickedLocation = argument;
                });
              }
            : null,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.placeLocation.latitude,
            widget.placeLocation.longitude,
          ),
          zoom: 16,
        ),
        markers: (_pickedLocation == null && widget.isSelecting)
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('m1'),
                  position: _pickedLocation != null
                      ? _pickedLocation!
                      : LatLng(
                          widget.placeLocation.latitude,
                          widget.placeLocation.longitude,
                        ),
                ),
              },
      ),
    );
  }
}
