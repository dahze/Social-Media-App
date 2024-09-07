class FriendRequest {
  String senderId;
  String receiverId;
  DateTime timestamp;

  FriendRequest({
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static FriendRequest fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
