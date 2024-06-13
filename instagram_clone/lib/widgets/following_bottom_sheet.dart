import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/post_methods.dart';
import 'package:instagram_clone/widgets/user_card.dart';

class FollowingBottomSheet extends StatefulWidget {
  final String userId;
  final bool isMe;
  final Function(String followingId) func;
  const FollowingBottomSheet(
      {super.key,
      required this.userId,
      required this.func,
      required this.isMe});

  @override
  _FollowingBottomSheetState createState() => _FollowingBottomSheetState();
}

class _FollowingBottomSheetState extends State<FollowingBottomSheet> {
  List<User>? followingUsers;

  @override
  void initState() {
    super.initState();
    _loadFollowingUsers();
  }

  void _loadFollowingUsers() async {
    final users = await PostMethods().getFollowingUsers(widget.userId);
    setState(() {
      followingUsers = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return followingUsers == null
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Following',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: followingUsers!.length,
                  itemBuilder: (context, index) {
                    return UserCard(
                      user: followingUsers![index],
                      func: () {
                        widget.func(followingUsers![index].uid);
                        if (widget.isMe) {
                          setState(() {
                            followingUsers!.removeAt(index);
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
  }
}
