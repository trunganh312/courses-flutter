import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart' as UserModel;
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/post_methods.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/comment_sheet_bottom.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool _isLike = false;
  late bool _isLiked;
  late AnimationController _controller;
  final String currentUserId = FirebaseAuth
      .instance.currentUser!.uid; // Replace with actual current user ID
  UserModel.User? users;
  void _loadUser() async {
    final result = await AuthMethods().getDetailUser(currentUserId);
    setState(() {
      users = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _isLiked = widget.data['likes'].contains(currentUserId);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Duration of the animation
    );
    _loadUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLikePost() async {
    setState(() {
      _isLiked = !_isLiked;
    });

    // Update the liked state in Firestore
    if (_isLiked) {
      // Add current user ID to likes array
      await PostMethods().likePost(currentUserId, widget.data['postId']);
    } else {
      // Remove current user ID from likes array
      await PostMethods().unLikePost(currentUserId, widget.data['postId']);
    }
  }

  void _onDoubleTap() {
    setState(() {
      _isLike = true;
      _isLiked = true;
    });
    _controller.forward();
    Future.delayed(const Duration(seconds: 1), () {
      _controller.reverse().then((value) {
        if (mounted) {
          setState(() {
            _isLike = false;
          });
        }
      });
    });

    // Add current user ID to likes array in Firestore
    PostMethods().likePost(currentUserId, widget.data['postId']);
  }

  void _handleDeletePost(String postId) async {
    try {
      final result = await PostMethods().deletePost(postId);
      if (result == "success") {
        showSnackBar(context, "Delete post successfully");
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void _showBottomSheetComment({
    required String postId,
    required String username,
    required String avatar,
    required List<dynamic> comments,
    required String uid,
  }) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Wrap(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.8, // Thiết lập chiều cao gần full
                  child: CommentBottomSheet(
                    avatar: avatar,
                    postId: postId,
                    username: username,
                    uid: uid,
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(userId: widget.data["uid"]),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.data["profImage"]),
              ),
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(userId: widget.data["uid"]),
                ));
              },
              child: Text(
                widget.data["username"],
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing: widget.data['uid'].toString() == currentUserId
                ? IconButton(
                    onPressed: () {
                      showDialog(
                        useRootNavigator: false,
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                            _handleDeletePost(widget
                                                .data['postId']
                                                .toString());
                                            // remove the dialog box
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
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onDoubleTap: _onDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.network(
                  widget.data["postUrl"],
                  fit: BoxFit.cover,
                  height: 300,
                  width: double.infinity,
                ),
                AnimatedOpacity(
                  opacity: _isLike ? 1.0 : 0.0,
                  duration:
                      const Duration(milliseconds: 300), // Animation duration
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _handleLikePost,
                            icon: _isLiked
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.redAccent,
                                  )
                                : const Icon(Icons.favorite_outline),
                          ),
                          IconButton(
                            onPressed: () {
                              _showBottomSheetComment(
                                comments: widget.data["comments"],
                                postId: widget.data["postId"].toString(),
                                username: users!.username,
                                avatar: users!.photoUrl,
                                uid: currentUserId,
                              );
                            },
                            icon: const Icon(Icons.comment),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_border_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("${widget.data['likes'].length} likes"),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: primaryColor),
                          children: [
                            TextSpan(
                              text: "${widget.data["username"]} ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: widget.data["description"]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          _showBottomSheetComment(
                            comments: widget.data["comments"],
                            postId: widget.data["postId"].toString(),
                            username: widget.data["username"],
                            avatar: widget.data["profImage"],
                            uid: widget.data["uid"],
                          );
                        },
                        child: Text(
                          "View all ${widget.data['comments'].length} comments",
                          style: const TextStyle(
                            fontSize: 16,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat.yMMMd()
                            .format(widget.data['datePublished'].toDate()),
                        style: const TextStyle(
                          fontSize: 16,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
