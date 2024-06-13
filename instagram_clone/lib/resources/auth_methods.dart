import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/user.dart' as UserModel;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<UserModel.User> getDetailUser(String userId) async {
    final user = await _firestore.collection("users").doc(userId).get();

    return UserModel.User.fromSnap(user);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required File file,
  }) async {
    String res = "Some error occurred.";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final photoImageUrl =
            await StorageMethods().uploadImage("avatar_users", file, false);
        final user = UserModel.User(
            username: username,
            uid: newUser.user!.uid,
            photoUrl: photoImageUrl,
            email: email,
            bio: bio,
            followers: [],
            following: []);
        await _firestore
            .collection("users")
            .doc(newUser.user!.uid)
            .set(user.toJson());
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (e) {
      res.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred.";
    if (email.isNotEmpty || password.isNotEmpty) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } catch (e) {
        res = e.toString();
      }
    }
    return res;
  }

  Future<String> logoutUser() async {
    String message = "...";
    try {
      await _auth.signOut();
      message = "success";
    } catch (e) {
      message = e.toString();
    }
    return message;
  }

  Future<void> follow(
    String userId, // user đang login
    String followerId, // user được follow
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'following': FieldValue.arrayUnion([followerId])
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(followerId)
          .update({
        'followers': FieldValue.arrayUnion([userId])
      });
      print("success");
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> unFollow(
    String userId, // user đang login
    String followerId, // user được unfollow
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'following': FieldValue.arrayRemove([followerId])
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(followerId)
          .update({
        'followers': FieldValue.arrayRemove([userId])
      });
      print("success");
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<UserModel.User>> searchUsers(String searchTerm) async {
    List<UserModel.User> usernames = [];
    String normalizedSearchTerm = searchTerm.toLowerCase();
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('username')
          .startAt([normalizedSearchTerm]).endAt(
              ['$normalizedSearchTerm\uf8ff']).get();
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        usernames.add(UserModel.User.fromSnap(querySnapshot.docs[i]));
      }
    } catch (e) {
      print('Error searching users: $e');
    }

    return usernames;
  }
}
