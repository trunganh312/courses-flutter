import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String uid;
  final String postId;
  final String content;
  final DateTime createdAt;
  final String commentId;
  final String username;
  final String avatar;

  Comment(
      {required this.uid,
      required this.postId,
      required this.content,
      required this.createdAt,
      required this.commentId,
      required this.username,
      required this.avatar});

  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Comment(
        uid: snapshot["uid"],
        postId: snapshot["postId"],
        content: snapshot["content"],
        commentId: snapshot["commentId"],
        createdAt: snapshot["createdAt"],
        avatar: snapshot["avatar"],
        username: snapshot["username"]);
  }

  Map<String, dynamic> toJson() => {
        "content": content,
        "uid": uid,
        "postId": postId,
        "createdAt": createdAt,
        "commentId": commentId,
        "username": username,
        "avatar": avatar
      };

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      commentId: data['commentId'],
      content: data['content'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      postId: data['postId'],
      uid: data['uid'],
      username: data['username'],
      avatar: data['avatar'],
    );
  }
}
