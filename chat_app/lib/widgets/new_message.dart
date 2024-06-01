import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  void _saveMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final detailUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    print(detailUser.data());
    await FirebaseFirestore.instance.collection("chat").add({
      "author": {
        "firstName": detailUser.data()?["username"],
        "id": user.uid,
        "imageUrl": detailUser.data()?["imageUrl"],
        "lastName": detailUser.data()?["username"]
      },
      "status": "seen",
      "text": _messageController.text,
      "type": "text",
      "id": const Uuid().v4(),
      "createdAt": DateTime.now().millisecondsSinceEpoch,
    });

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              decoration: const InputDecoration(
                labelText: 'Send a message...',
              ),
              onChanged: (value) {
                setState(() {
                  _messageController.text = value;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _saveMessage,
          ),
        ],
      ),
    );
  }
}
