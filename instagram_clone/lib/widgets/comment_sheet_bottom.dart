import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/post_methods.dart';
import 'package:instagram_clone/models/user.dart' as UserModel;
import 'package:instagram_clone/widgets/comments_list.dart';

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet(
      {super.key,
      required this.postId,
      required this.username,
      required this.avatar,
      required this.uid});
  final String postId;
  final String username;
  final String avatar;
  final String uid;

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _commentController = TextEditingController();
  UserModel.User? users;
  void _loadUser() async {
    final result = await AuthMethods()
        .getDetailUser(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      users = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  void _handleAddComment() async {
    try {
      await PostMethods().addComment(
        postId: widget.postId,
        content: _commentController.text,
        userId: users!.uid,
        avatar: users!.photoUrl,
        username: users!.username,
      );
      _commentController.clear();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (users == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Bình luận cho bài viết này',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SizedBox(
                  height: 350,
                  child:
                      CommentList(comments: snapshot.data!.data()?["comments"]),
                );
              }),
          Flexible(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    users!.photoUrl,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: _handleAddComment,
                          icon: const Icon(Icons.send)),
                      hintText: 'Nhập bình luận của bạn...',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
