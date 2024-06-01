import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'user_places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places(id INTEGER PRIMARY KEY, title TEXT, image TEXT, lat REAL, long REAL, address TEXT)',
      );
    },
    version: 1,
  );

  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await getApplicationDocumentsDirectory();
    print(appDir);
    final filename = path.basename(image.path);
    print(filename);
    final imageSource = await image.copy('${appDir.path}/$filename');
    final newPlace =
        Place(title: title, image: imageSource, location: location);

    final db = await _getDatabase();
    await db.insert("user_places", {
      "id": newPlace.id,
      "title": newPlace.title,
      "address": newPlace.location.address,
      "lat": newPlace.location.latitude,
      "long": newPlace.location.longitude,
      "image": newPlace.image.path,
    });

    state = [newPlace, ...state];
  }

  Future<void> loadListPlace() async {
    final db = await _getDatabase();

    // Query the table for all the dogs.
    final data = await db.query('user_places');
    final places = data
        .map(
          (place) => Place(
            id: place["id"] as String,
            title: place["title"] as String,
            image: File(place["image"] as String),
            location: PlaceLocation(
                latitude: place["lat"] as double,
                longitude: place["long"] as double,
                address: place["address"] as String),
          ),
        )
        .toList();
    state = places;
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
        (ref) => UserPlacesNotifier());
