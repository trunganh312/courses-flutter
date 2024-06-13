import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get user => _user!;
  Future<void> getUser() async {
    final user = await _authMethods
        .getDetailUser(auth.FirebaseAuth.instance.currentUser!.uid);
    _user = user;
    notifyListeners();
  }
}
