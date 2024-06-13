import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/chat_methods.dart';
import 'package:instagram_clone/resources/post_methods.dart';
import 'package:instagram_clone/screens/chat_screen.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/widgets/follower_bottom_sheet.dart';
import 'package:instagram_clone/widgets/following_bottom_sheet.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  List<Post>? userPosts;
  bool isMe = false;
  String? idUserLogin = FirebaseAuth.FirebaseAuth.instance.currentUser?.uid;
  bool isFollow = false;
  int followers = 0;
  int following = 0;
  var uuid = const Uuid();
  void _loadUserAndPost() async {
    final result = await AuthMethods().getDetailUser(widget.userId);
    final resultPost = await PostMethods().getPostByUser(userId: widget.userId);
    setState(() {
      user = result;
      userPosts = resultPost;
      isMe = widget.userId == idUserLogin;
      isFollow = user!.followers.contains(idUserLogin);
      followers = user!.followers.length;
      following = user!.following.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserAndPost();
  }

  void _handleUnfollow() async {
    try {
      await AuthMethods().unFollow(idUserLogin!, widget.userId);
      setState(() {
        isFollow = false;
        followers--;
      });
    } catch (e) {
      print(e);
    }
  }

  void _handleUnfollowUserProfilleLogin(String followingId) async {
    try {
      await AuthMethods().unFollow(idUserLogin!, followingId);
      setState(() {
        isFollow = false;
        following--;
      });
    } catch (e) {
      print(e);
    }
  }

  void _handleFollow() async {
    try {
      await AuthMethods().follow(idUserLogin!, widget.userId);
      setState(() {
        isFollow = true;
        followers++;
      });
    } catch (e) {
      print(e);
    }
  }

  void _hanldeOpenConversation() async {
    String conversationId = uuid.v4();
    // Kiểm tra xem cuộc trò chuyện đã tồn tại hay chưa
    final result = await FirebaseFirestore.instance
        .collection("conversations")
        .where("userSendId", isEqualTo: idUserLogin)
        .where("userSendId", isEqualTo: widget.userId)
        .get();

    if (result.docs.isEmpty) {
      // Nếu cuộc trò chuyện chưa tồn tại, tạo mới
      await ChatMethods().createConversation(
          conversationId: conversationId,
          userReceiveId: widget.userId,
          userSendId: idUserLogin!);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConversationScreen(
          conversationId: "994fa226-7243-4b9b-9dec-d3f482553beb",
          userReceiveId: widget.userId,
        ),
      ));
      print("Conversation created successfully!");
    } else {
      final id = result.docs.first.id;
      // Nếu cuộc trò chuyện đã tồn tại, chuyển sang cuộc trò chuyện đó
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConversationScreen(
          conversationId: "994fa226-7243-4b9b-9dec-d3f482553beb",
          userReceiveId: widget.userId,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || userPosts == null || idUserLogin == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user!.username),
        actions: [
          isMe
              ? IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await AuthMethods().logoutUser();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                )
              : const Text(""),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user!.photoUrl),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(userPosts!.length, "Posts"),
                          _buildStatColumn(followers, "Followers"),
                          _buildStatColumn(following, "Following"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user!.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(user!.bio),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  isMe
                      ? Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Edit Profile'),
                          ),
                        )
                      : Expanded(
                          child: Column(
                            children: [
                              isFollow
                                  ? FollowButton(
                                      text: 'Unfollow',
                                      backgroundColor: Colors.blue,
                                      textColor: Colors.white,
                                      borderColor: Colors.blue,
                                      function: _handleUnfollow,
                                    )
                                  : FollowButton(
                                      text: 'Follow',
                                      backgroundColor: Colors.blue,
                                      textColor: Colors.white,
                                      borderColor: Colors.blue,
                                      function: _handleFollow,
                                    ),
                              FollowButton(
                                text: 'Send Message',
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                borderColor: Colors.blue,
                                function: _hanldeOpenConversation,
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
            _buildPhotoGrid(userPosts!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(int number, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "Following") {
          showModalBottomSheet(
            context: context,
            builder: (context) => FollowingBottomSheet(
                isMe: isMe,
                userId: widget.userId,
                func: isMe
                    ? (followingId) {
                        _handleUnfollowUserProfilleLogin(followingId);
                      }
                    : (followingId) {}),
          );
        }

        if (label == "Followers") {
          showModalBottomSheet(
            context: context,
            builder: (context) => FollowerBottomSheet(userId: widget.userId),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<Post> posts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[300],
          child: Image.network(
            posts[index].postUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
