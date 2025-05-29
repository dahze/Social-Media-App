import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/retro_button.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;

  const ChatScreen({required this.chatId, required this.receiverId, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late String _currentUserId;
  String _receiverUsername = 'Loading...';

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {});

    if (!mounted) return;
    Provider.of<MessageProvider>(context, listen: false).clearMessages();

    await _fetchReceiverUsername();

    if (!mounted) return;
    Provider.of<MessageProvider>(context, listen: false)
        .loadMessages(_currentUserId, widget.receiverId);

    if (mounted) setState(() {});
  }

  Future<void> _fetchReceiverUsername() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .get();

    if (!mounted) return;

    final username = doc.data()?['username'] ?? 'Unknown';
    setState(() {
      _receiverUsername = username;
    });
  }

  void _sendMessage() {
    final content = _controller.text.trim();
    if (content.isNotEmpty) {
      final message = Message(
        id: '',
        senderId: _currentUserId,
        receiverId: widget.receiverId,
        content: content,
        timestamp: DateTime.now(),
      );
      Provider.of<MessageProvider>(context, listen: false)
          .sendMessage(_currentUserId, widget.receiverId, message);
      _controller.clear();
    }
  }

  String _formatElapsedTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    }
    if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    }
    if (difference.inDays >= 1) return '${difference.inDays}d ago';
    if (difference.inHours >= 1) return '${difference.inHours}h ago';
    if (difference.inMinutes >= 1) return '${difference.inMinutes}m ago';
    return '${difference.inSeconds}s ago';
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);
    final messages = messageProvider.messages;
    final isLoading = messageProvider.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xfffef9ef),
      appBar: AppBar(
        backgroundColor: const Color(0xfffef9ef),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _receiverUsername,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? FutureBuilder(
                        future:
                            Future.delayed(const Duration(milliseconds: 300)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return const Center(
                            child: Text(
                              'No messages yet.',
                              style: TextStyle(
                                fontFamily: 'PressStart2P',
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == _currentUserId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.blue[100]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.content,
                                      style: const TextStyle(
                                        fontFamily: 'PressStart2P',
                                        fontSize: 12.0,
                                        color: Colors.black,
                                      ),
                                      softWrap: true,
                                    ),
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        _formatElapsedTime(message.timestamp),
                                        style: const TextStyle(
                                          fontFamily: 'PressStart2P',
                                          fontSize: 8.0,
                                          color: Colors.black54,
                                        ),
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
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Say something...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'PressStart2P',
                        fontSize: 12.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                RetroButton(
                  text: 'Send',
                  onPressed: _sendMessage,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  textStyle: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 13,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
