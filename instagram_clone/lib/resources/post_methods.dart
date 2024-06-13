import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/comment.dart' as CommentModel;
import 'package:instagram_clone/models/post.dart' as PostModel;
import 'package:instagram_clone/models/user.dart' as UserModel;
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class PostMethods {
  final _firestore = FirebaseFirestore.instance;
  var uuid = const Uuid();

  Future<String> uploadPost(
      {required String description,
      required File postImage,
      required String userImage,
      required String userName,
      required String userId}) async {
    String message = "...";

    try {
      final postId = uuid.v4();
      final postFileImage = await StorageMethods()
          .uploadImagePost("post_images", postImage, postId);
      final post = PostModel.Post(
        datePublished: DateTime.now(),
        description: description,
        likes: [],
        postId: postId,
        postUrl: postFileImage,
        profImage: userImage,
        username: userName,
        uid: userId,
        comments: [],
      );
      await _firestore.collection('posts').doc(postId).set(post.toJson());
      message = "success";
    } catch (e) {
      message = e.toString();
    }
    return message;
  }

  Future<String> likePost(String userId, String postId) async {
    String message = "...";
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([userId])
      });
      message = "success";
    } catch (e) {
      message = e.toString();
    }

    return message;
  }

  Future<String> unLikePost(String userId, String postId) async {
    String message = "...";
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([userId])
      });
      message = "success";
    } catch (e) {
      message = e.toString();
    }

    return message;
  }

  Future<String> deletePost(String postId) async {
    String message = "...";
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      message = "success";
    } catch (e) {
      message = e.toString();
    }
    return message;
  }

  Future<String> addComment({
    required String postId,
    required String content,
    required String userId,
    required String avatar,
    required String username,
  }) async {
    String message = "...";
    try {
      final commentId = uuid.v4();
      final comment = CommentModel.Comment(
        commentId: commentId,
        content: content,
        createdAt: DateTime.now(),
        postId: postId,
        uid: userId,
        username: username,
        avatar: avatar,
      );
      final postRef = _firestore.collection("posts").doc(postId);
      final postSnapshot = await postRef.get();
      final postComments = postSnapshot.data()?['comments'] ?? [];
      postComments.add(comment.toJson());
      await postRef.update({'comments': postComments});
      message = "success";
    } catch (e) {
      print(e.toString());
      message = e.toString();
    }

    return message;
  }

  Future<List<PostModel.Post>> getPostByUser({
    required String userId,
  }) async {
    List<PostModel.Post> userPosts = [];
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: userId)
          .get();
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        userPosts.add(PostModel.Post.fromSnap(querySnapshot.docs[i]));
      }
    } catch (e) {
      print(e);
    }
    return userPosts;
  }

  Future<List<UserModel.User>> getFollowingUsers(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      List<dynamic> following = userDoc['following'];

      List<UserModel.User> followingUsers = [];
      for (String userId in following) {
        DocumentSnapshot userSnap =
            await _firestore.collection('users').doc(userId).get();
        followingUsers.add(UserModel.User.fromSnap(userSnap));
      }
      return followingUsers;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<UserModel.User>> getFollowerUsers(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      List<dynamic> followers = userDoc['followers'];

      List<UserModel.User> followersUsers = [];
      for (String userId in followers) {
        DocumentSnapshot userSnap =
            await _firestore.collection('users').doc(userId).get();
        followersUsers.add(UserModel.User.fromSnap(userSnap));
      }
      return followersUsers;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<String> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    String message = "...";
    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();
      if (postSnapshot.exists) {
        final comments =
            List<Map<String, dynamic>>.from(postSnapshot['comments']);
        final commentToRemove =
            comments.firstWhere((comment) => comment['commentId'] == commentId);

        await postRef.update({
          'comments': FieldValue.arrayRemove([commentToRemove]),
        });
      }
      message = "success";
    } catch (e) {
      message = e.toString();
    }
    return message;
  }
}
