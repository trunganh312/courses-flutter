import 'package:chat_app/widgets/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

class ChatMessagesNew extends StatefulWidget {
  const ChatMessagesNew({super.key});

  @override
  State<ChatMessagesNew> createState() => _ChatMessagesNewState();
}

class _ChatMessagesNewState extends State<ChatMessagesNew> {
  final auth = FirebaseAuth.instance.currentUser;
  final List<types.Message> _messages = [];
  late final _user = types.User(
    id: auth!.uid,
  );
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _loadMessages() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    firestore.collection('chat').get().then((value) {
      for (var element in value.docs) {
        _addMessage(types.Message.fromJson(element.data()));
      }
    });
  }

  void _saveMessage(types.PartialText message) async {
    if (message.text.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final detailUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    await FirebaseFirestore.instance.collection("chat").add({
      "author": {
        "firstName": detailUser.data()?["username"],
        "id": user.uid,
        "imageUrl": detailUser.data()?["imageUrl"],
        "lastName": detailUser.data()?["username"]
      },
      "status": "seen",
      "text": message.text,
      "type": "text",
      "id": const Uuid().v4(),
      "createdAt": DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<types.Message> messages = snapshot.data!.docs.map((doc) {
          return types.Message.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        return Chat(
          usePreviewData: false,
          // theme: const DarkChatTheme(),
          onSendPressed: _saveMessage,
          messages: messages,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
          // customBottomWidget: const NewMessage(),
        );
      },
    );
  }
}
