import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _filteredFriends = [];

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('friends')
        .get();

    final List<Map<String, dynamic>> loadedFriends = [];

    for (final doc in snapshot.docs) {
      final friendId = doc.id;
      final friendDoc =
          await _firestore.collection('users').doc(friendId).get();

      final username = friendDoc.data()?['username'] ?? 'Unknown';
      final lastMessageDoc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('friends')
          .doc(friendId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final lastMessageData = lastMessageDoc.docs.isNotEmpty
          ? lastMessageDoc.docs.first.data()
          : null;

      loadedFriends.add({
        'id': friendId,
        'username': username,
        'lastMessage': lastMessageData?['content'],
        'timestamp': lastMessageData?['timestamp'],
      });
    }

    loadedFriends.sort((a, b) {
      final aTime = a['timestamp'] as Timestamp?;
      final bTime = b['timestamp'] as Timestamp?;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    setState(() {
      _friends = loadedFriends;
      _filteredFriends = loadedFriends;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = _friends.where((friend) {
        final username = friend['username']!.toLowerCase();
        return username.contains(query);
      }).toList();
    });
  }

  String _generateChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffef9ef),
      appBar: AppBar(
        backgroundColor: const Color(0xfffef9ef),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '2001',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        titleSpacing: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB8E986),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search friends',
                      hintStyle: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: _filteredFriends.isEmpty
                      ? const Center(
                          child: Text(
                            'No friends found.',
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          itemCount: _filteredFriends.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final friend = _filteredFriends[index];
                            final chatId =
                                _generateChatId(_currentUserId, friend['id']!);

                            final lastMessage = friend['lastMessage'];
                            final timestamp = friend['timestamp'] != null
                                ? (friend['timestamp'] as Timestamp).toDate()
                                : null;

                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                    color: Colors.black, width: 0.5),
                              ),
                              tileColor: const Color(0xffbff0ce),
                              leading: const Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 50,
                              ),
                              title: Text(
                                friend['username'],
                                style: const TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.black, width: 1),
                                          ),
                                          child: Text(
                                            lastMessage ?? 'Say something...',
                                            style: TextStyle(
                                              fontFamily: 'PressStart2P',
                                              fontSize: 10,
                                              color: Colors.grey.shade700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: timestamp != null
                                  ? Text(
                                      _formatTimestamp(timestamp),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontFamily: 'PressStart2P',
                                      ),
                                    )
                                  : null,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      chatId: chatId,
                                      receiverId: friend['id'],
                                    ),
                                  ),
                                );
                                setState(() {
                                  _isLoading = true;
                                });
                                await _loadFriends();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inSeconds}s';
    }
  }
}
