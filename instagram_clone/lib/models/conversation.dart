class Message {
  final String id;
  final String text;
  final String authorId;
  final String name;
  final String authorImageUrl;
  final String type; // Kiểu tin nhắn (text, image, ...)
  final int createdAt; // Thời điểm tạo tin nhắn

  Message({
    required this.id,
    required this.text,
    required this.authorId,
    required this.name,
    required this.authorImageUrl,
    this.type = "text",
    required this.createdAt,
  });

  // Hàm tạo từ Map dữ liệu
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      text: map['text'],
      authorId: map['author']['id'],
      name: map['author']['name'],
      authorImageUrl: map['author']['imageUrl'],
      type: map['type'],
      createdAt: map['createdAt'],
    );
  }

  // Chuyển đổi sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'author': {
        'id': authorId,
        'name': name,
        'imageUrl': authorImageUrl,
      },
      'type': type,
      'createdAt': createdAt,
    };
  }
}

class Conversation {
  final String id;
  final List<Message> messages;
  final String userSendId;
  final String userReceiveId;

  Conversation({
    required this.userSendId,
    required this.userReceiveId,
    required this.id,
    required this.messages,
  });

  // Hàm tạo từ Map dữ liệu
  factory Conversation.fromMap(Map<String, dynamic> map) {
    final List<dynamic> messagesList = map['messages'];
    List<Message> messages =
        messagesList.map((msg) => Message.fromMap(msg)).toList();

    return Conversation(
      id: map['id'],
      messages: messages,
      userSendId: map["userSendId"],
      userReceiveId: map["userReceiveId"],
    );
  }

  // Chuyển đổi sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> messagesMapList =
        messages.map((msg) => msg.toMap()).toList();

    return {
      'id': id,
      'messages': messagesMapList,
      'userSendId': userSendId,
      'userReceiveId': userReceiveId,
    };
  }
}
