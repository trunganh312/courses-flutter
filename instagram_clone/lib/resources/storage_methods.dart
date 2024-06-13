import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final _auth = FirebaseAuth.instance;
  final _storageRef = FirebaseStorage.instance;
  Future<String> uploadImage(
    String fileName,
    File file,
    bool isPost,
  ) async {
    final ref = _storageRef
        .ref()
        .child(fileName)
        .child("${_auth.currentUser!.uid}.jpg");
    await ref.putFile(file);
    final imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  Future<String> uploadImagePost(
      String fileName, File file, String postId) async {
    final ref = _storageRef.ref().child(fileName).child("$postId.jpg");
    await ref.putFile(file);
    final imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }
}
