import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final dynamic comment;
  final Function(String commentId, String postId) handleDeleteComment;
  const CommentItem(
      {super.key, required this.comment, required this.handleDeleteComment});

  @override
  Widget build(BuildContext context) {
    var createdAtTimestamp = comment["createdAt"] as Timestamp;
    var createdAt = createdAtTimestamp.toDate();
    return ListTile(
      trailing:
          comment['uid'].toString() == FirebaseAuth.instance.currentUser!.uid
              ? IconButton(
                  onPressed: () {
                    showDialog(
                      useRootNavigator: false,
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shrinkWrap: true,
                              children: [
                                'Delete',
                              ]
                                  .map(
                                    (e) => InkWell(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(e),
                                        ),
                                        onTap: () {
                                          handleDeleteComment(
                                              comment["commentId"],
                                              comment["postId"]);
                                          Navigator.of(context).pop();
                                        }),
                                  )
                                  .toList()),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                )
              : null,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(comment["avatar"]),
      ),
      title: Row(
        children: [
          Text(comment["username"]),
          const SizedBox(
            width: 6,
          ),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment["content"]),
        ],
      ),
    );
  }
}
