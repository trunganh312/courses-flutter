import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/post_methods.dart';
import 'package:instagram_clone/widgets/user_card.dart';

class FollowerBottomSheet extends StatefulWidget {
  final String userId;

  const FollowerBottomSheet({super.key, required this.userId});

  @override
  _FollowerBottomSheetState createState() => _FollowerBottomSheetState();
}

class _FollowerBottomSheetState extends State<FollowerBottomSheet> {
  List<User>? followerUsers;

  @override
  void initState() {
    super.initState();
    _loadFollowerUsers();
  }

  void _loadFollowerUsers() async {
    final users = await PostMethods().getFollowerUsers(widget.userId);
    setState(() {
      followerUsers = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return followerUsers == null
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Followers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: followerUsers!.length,
                  itemBuilder: (context, index) {
                    return UserCard(user: followerUsers![index]);
                  },
                ),
              ),
            ],
          );
  }
}
