import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Message>> getMessages(String currentUserId, String friendId) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(
      String senderId, String receiverId, Message message) async {
    final messageMap = message.toMap();

    await _firestore
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(receiverId)
        .collection('messages')
        .add(messageMap);

    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friends')
        .doc(senderId)
        .collection('messages')
        .add(messageMap);
  }
}
