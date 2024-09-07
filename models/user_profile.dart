class UserProfile {
  String userId;
  String username;
  String email;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
    };
  }

  static UserProfile fromMap(String userId, Map<String, dynamic> map) {
    return UserProfile(
      userId: userId,
      username: map['username'],
      email: map['email'],
    );
  }
}
