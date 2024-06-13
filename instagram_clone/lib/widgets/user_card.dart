import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final Function()? func;
  const UserCard({super.key, required this.user, this.func});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: func,
      ),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.photoUrl),
      ),
      title: Text(user.username),
      subtitle: Text(user.bio),
    );
  }
}
