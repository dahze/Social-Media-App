import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/message_service.dart';

class MessageProvider with ChangeNotifier {
  final MessageService _messageService = MessageService();
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  void loadMessages(String currentUserId, String friendId) {
    _isLoading = true;
    notifyListeners();

    _messageService.getMessages(currentUserId, friendId).listen((messageList) {
      _messages = messageList;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(
      String senderId, String receiverId, Message message) async {
    await _messageService.sendMessage(senderId, receiverId, message);
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
