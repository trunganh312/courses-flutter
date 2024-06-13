import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  _selectImage() async {
    final image = await pickImage(ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  _signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    final res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image!);
    if (res == "success") {
      showSnackBar(context, "Signup successful!");
      setState(() {
        _isLoading = false;
      });
    } else {
      showSnackBar(
          context, "The email address is already in use by another account. ");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Container(),
              ),
              SvgPicture.asset(
                "assets/ic_instagram.svg",
                color: primaryColor,
                height: 64,
              ),
              const SizedBox(
                height: 50,
              ),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 90,
                          backgroundImage: FileImage(_image!),
                        )
                      : const CircleAvatar(
                          radius: 90,
                          backgroundImage:
                              NetworkImage("https://i.sstatic.net/l60Hf.png"),
                        ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: _selectImage,
                        icon: const Icon(
                          Icons.camera_enhance,
                          size: 30,
                        ),
                      )),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              TextFieldInput(
                controller: _emailController,
                hintText: "Enter your email",
                type: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldInput(
                controller: _passwordController,
                hintText: "Enter your password",
                type: TextInputType.text,
                isShowText: true,
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldInput(
                controller: _usernameController,
                hintText: "Enter your username",
                type: TextInputType.text,
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldInput(
                controller: _bioController,
                hintText: "Enter your bio",
                type: TextInputType.text,
              ),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: _signUpUser,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Sign up"),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'I already have a account',
                    ),
                  ),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        ' Login.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
