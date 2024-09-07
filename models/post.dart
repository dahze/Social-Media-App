class Post {
  String postId;
  String userId;
  String content;
  String? username;
  DateTime timestamp;

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    required this.timestamp,
    this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'],
      userId: map['userId'],
      username: map['username'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
