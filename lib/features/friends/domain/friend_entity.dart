class Friend {
  final int userId;
  String username;
  String? profilePic;
  String status;

  Friend({
    required this.userId,
    required this.username,
    this.profilePic,
    required this.status,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      profilePic: json['profile_pic'] as String?,
      status: json['status'] as String,
    );
  }
}