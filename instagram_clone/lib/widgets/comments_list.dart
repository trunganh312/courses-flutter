import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/post_methods.dart';
import 'package:instagram_clone/widgets/comment_item.dart';

class CommentList extends StatelessWidget {
  final List<dynamic> comments;

  const CommentList({super.key, required this.comments});

  void _handleDeleteComment(String commentId, String postId) async {
    try {
      final result = await PostMethods()
          .deleteComment(commentId: commentId, postId: postId);
      print(result);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return CommentItem(
          comment: comments[index],
          handleDeleteComment: (commentId, postId) {
            _handleDeleteComment(commentId, postId);
          },
        );
      },
    );
  }
}
