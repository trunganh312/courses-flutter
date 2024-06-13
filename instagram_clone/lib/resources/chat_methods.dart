import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/conversation.dart';
import 'package:uuid/uuid.dart';

class ChatMethods {
  final _firestore = FirebaseFirestore.instance;
  var uuid = const Uuid();
  Future<String> createConversation({
    required String userSendId,
    required String userReceiveId,
    required String conversationId,
  }) async {
    String message = "...";
    try {
      final dataConversation = Conversation(
          userSendId: userSendId,
          userReceiveId: userReceiveId,
          id: conversationId,
          messages: []);
      await _firestore
          .collection("conversations")
          .doc(conversationId)
          .set(dataConversation.toMap());
      message = "success";
    } catch (e) {}
    return message;
  }

  Future<Map<String, dynamic>?> getConversation({
    required String conversationId,
  }) async {
    try {
      final result = await _firestore
          .collection("conversations")
          .doc(conversationId)
          .get();
      if (result.exists) {
        // Nếu tài liệu tồn tại, trả về dữ liệu dưới dạng Map<String, dynamic>
        return result.data() as Map<String, dynamic>;
      } else {
        // Nếu tài liệu không tồn tại, có thể xử lý tại đây (ví dụ: trả về null)
        return null;
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      print("Error fetching conversation: $e");
      return null;
    }
  }

  void addMessage({
    required String userSendId,
    required String userReceiveId,
    required String conversationId,
    required String message,
    required String image,
    required String name,
  }) async {
    try {
      final messageData = {
        'id': uuid.v4(),
        'createdAt': Timestamp.now().millisecondsSinceEpoch,
        'authorId': userSendId,
        'authorImageUrl': image,
        'text': message,
        'name': name,
        'type': "text",
      };

      final firestore = FirebaseFirestore.instance;
      final conversationRef =
          firestore.collection("conversations").doc(conversationId);

      // Kiểm tra xem tài liệu đã tồn tại hay chưa
      final snapshot = await conversationRef.get();
      if (snapshot.exists) {
        // Cập nhật tài liệu
        await conversationRef.update({
          'messages': FieldValue.arrayUnion([messageData]),
        });
      } else {
        // Nếu tài liệu chưa tồn tại, tạo mới
        await conversationRef.set({
          'userSendId': userSendId,
          'userReceiveId': userReceiveId,
          'id': conversationId,
          'messages': [messageData],
        });
      }
      print('Conversation updated successfully.');
    } catch (e) {
      print('Error updating conversation: $e');
    }
  }
}
