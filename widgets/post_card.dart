import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String currentUserId;
  final void Function(String postId) onEdit;
  final void Function(String postId) onDelete;

  // ignore: prefer_final_fields
  static Map<String, String> _cachedUsernames = {};

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatElapsedTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inSeconds}s ago';
    }
  }

  Future<String> _getUsername(String userId) async {
    if (_cachedUsernames.containsKey(userId)) {
      return _cachedUsernames[userId]!;
    } else {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      String username = snapshot['username'];
      _cachedUsernames[userId] = username;
      return username;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUserPost = post.userId == currentUserId;

    return FutureBuilder<String>(
      future: _getUsername(post.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        String username = snapshot.data ?? 'Unknown';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          color: const Color(0xffbff0ce),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _formatElapsedTime(post.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    post.content,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (isCurrentUserPost)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () => onEdit(post.postId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        onPressed: () => onDelete(post.postId),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
