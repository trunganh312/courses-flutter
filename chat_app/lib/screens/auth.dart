// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chat_app/widgets/user_picker_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _showPassword = true;
  String _email = '';
  String _password = '';
  String _username = '';
  File? _fileImage;
  bool _isLoading = false;
  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    final valid = _formKey.currentState!.validate();

    if (!valid || _fileImage == null && !_isLogin) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    _formKey.currentState!.save();

    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _email, password: _password);
        setState(() {
          _isLoading = false;
        });
      } else {
        final newUser = await _firebase.createUserWithEmailAndPassword(
            email: _email, password: _password);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${newUser.user!.uid}.jpg");
        await storageRef.putFile(_fileImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("users")
            .doc(newUser.user!.uid)
            .set({
          "username":
              _username != "" ? _username : "username-${newUser.user!.uid}",
          "email": newUser.user!.email,
          "imageUrl": imageUrl,
        });
        setState(() {
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Authentication failed"),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/chat.png",
                  fit: BoxFit.cover,
                  width: 200,
                ),
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  child: Card(
                    color: Colors.white,
                    child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              if (!_isLogin)
                                UserPickerImage(
                                  onSelectImage: (image) {
                                    _fileImage = image;
                                  },
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                onSaved: (newValue) {
                                  _email = newValue!;
                                },
                                decoration: const InputDecoration(
                                    labelText: "Email",
                                    prefixIcon: Icon(Icons.email)),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter your email";
                                  }
                                  final bool emailValid = RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                      .hasMatch(value);
                                  if (!emailValid) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                textCapitalization: TextCapitalization.none,
                              ),
                              if (!_isLogin)
                                TextFormField(
                                  onSaved: (newValue) {
                                    _username = newValue!;
                                  },
                                  decoration: const InputDecoration(
                                      labelText: "Username",
                                      prefixIcon: Icon(Icons.person)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a username';
                                    } else if (value.length < 4) {
                                      return 'Username must be at least 4 characters long';
                                    } else if (!RegExp(r'^[a-zA-Z0-9]+$')
                                        .hasMatch(value)) {
                                      return 'Username can only contain alphanumeric characters';
                                    }
                                    return null;
                                  },
                                ),
                              TextFormField(
                                onSaved: (newValue) {
                                  _password = newValue!;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  const passwordPattern =
                                      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
                                  final regex = RegExp(passwordPattern);
                                  if (!regex.hasMatch(value)) {
                                    return 'Password must be at least 8 characters long, include an uppercase letter, a lowercase letter, a number, and a special character.';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(_showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _showPassword,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                onPressed: _submitForm,
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(_isLogin ? "Login" : "Signup"),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? "Create an account"
                                    : "I already have an account"),
                              )
                            ],
                          ),
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
