import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy("createdAt", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Messages"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, right: 13, left: 13),
          reverse: false,
          itemCount: snapshot.data?.docs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(snapshot.data?.docs[index].data()['text']),
            );
          },
        );
      },
    );
  }
}
