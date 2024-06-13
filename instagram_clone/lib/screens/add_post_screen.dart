import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_providers.dart';
import 'package:instagram_clone/resources/post_methods.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool _isImagePost = false;
  File? _imageFile;
  final _captionController = TextEditingController();
  bool _isLoading = false;
  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Please select image"),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                final File file = await pickImage(ImageSource.camera);
                setState(() {
                  _imageFile = file;
                  _isImagePost = true;
                });
              },
              child: const Text("Camera"),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                final File file = await pickImage(ImageSource.gallery);
                setState(() {
                  _imageFile = file;
                  _isImagePost = true;
                });
              },
              child: const Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  _handleAddPostDocument(
      String imageUser, String userId, String userName) async {
    if (_captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter caption"),
        ),
      );
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select image"),
        ),
      );
      return;
    }
    if (_isImagePost) {
      setState(() {
        _isLoading = true;
      });
      try {
        final result = await PostMethods().uploadPost(
            description: _captionController.text,
            postImage: _imageFile!,
            userImage: imageUser,
            userName: userName,
            userId: userId);
        if (result == "success") {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Posted")));
        }
        setState(() {
          _isLoading = false;
          _isImagePost = false;
          _captionController.clear();
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _captionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {}, icon: const Icon(Icons.arrow_back_outlined)),
        title: const Text('Post to'),
        actions: [
          TextButton(
            onPressed: () =>
                _handleAddPostDocument(user.photoUrl, user.uid, user.username),
            child: const Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 10,
            left: 10,
            right: 10,
          ),
          child: Column(
            children: [
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: LinearProgressIndicator(),
                    )
                  : const Padding(padding: EdgeInsets.only(top: 10)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Write a caption...",
                      ),
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.amber),
                ),
                height: 300,
                width: double.infinity,
                child: !_isImagePost
                    ? Center(
                        child: IconButton(
                            onPressed: () {
                              _selectImage(context);
                            },
                            icon: const Icon(Icons.upload_outlined)),
                      )
                    : Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
