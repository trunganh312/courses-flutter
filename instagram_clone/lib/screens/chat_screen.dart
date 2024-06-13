import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart' as UserModel;
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/chat_methods.dart';
import 'package:instagram_clone/utils/utils.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: ListView.builder(
        itemCount: 20, // Giả sử có 20 cuộc trò chuyện
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://via.placeholder.com/150', // Thay bằng URL hình ảnh thực tế
              ),
            ),
            title: Text('Username $index'),
            subtitle: const Text('Last message in the conversation'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ConversationScreen(
              //       conversationId: 'conversation_$index',
              //     ),
              //   ),
              // );
            },
          );
        },
      ),
    );
  }
}

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  final String userReceiveId;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.userReceiveId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  UserModel.User? _user;

  void _getUserLogin() async {
    final result = await AuthMethods()
        .getDetailUser(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _user = result;
    });
  }

  void _handleSendMessage() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }
    ChatMethods().addMessage(
      userSendId: FirebaseAuth.instance.currentUser!.uid,
      userReceiveId: widget.userReceiveId,
      conversationId: widget.conversationId,
      message: _controller.text,
      image: _user!.photoUrl,
      name: _user!.username,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadMessages();
    _getUserLogin();
  }

  List<dynamic> messages = [];

  void _loadMessages() async {
    final result = await ChatMethods()
        .getConversation(conversationId: widget.conversationId);
    setState(() {
      messages = result!["messages"];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation with ${widget.conversationId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages
                  .length, // Giả sử có 20 tin nhắn trong cuộc trò chuyện
              itemBuilder: (context, index) {
                bool isMe = FirebaseAuth.instance.currentUser!.uid ==
                    messages[index][
                        "authorId"]; // Giả định luân phiên giữa tin nhắn của tôi và người khác
                return ListTile(
                  leading: isMe
                      ? null
                      : CircleAvatar(
                          backgroundImage: NetworkImage(
                            messages[index][
                                "authorImageUrl"], // Thay bằng URL hình ảnh thực tế
                          ),
                        ),
                  trailing: isMe
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(
                            messages[index][
                                "authorImageUrl"], // Thay bằng URL hình ảnh thực tế
                          ),
                        )
                      : null,
                  title: Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            messages[index]["text"],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDateTime(messages[index]
                                ["createdAt"]), // Thay bằng ngày giờ thực tế
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Gửi tin nhắn
                    _handleSendMessage();
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
