class User {
  final int userId;
  String username;
  final String email;
  String? profilePic; // Может быть null
  String status;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.profilePic,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePic: json['profile_pic'] as String?, // Обработка null
      status: json['status'] as String,
    );
  }

  User copyWith({String? profilePic}) {
    return User(
      userId: userId,
      username: username,
      email: email,
      profilePic: profilePic ?? this.profilePic,
      status: status,
    );
  }
}

abstract class UserAndPostState {
  set user(User value);
  User get user;
  set post(Post? value);
  Post? get post;
  void updateLoadingState(bool isLoading);
}

class Post {
  final int postId;
  final int userId;
  final String imagePath;
  String? caption; // Может быть null
  final DateTime timestamp;

  Post({
    required this.postId,
    required this.userId,
    required this.imagePath,
    this.caption,
    required this.timestamp,
  });

  Post copyWith({
    int? postId,
    int? userId,
    String? imagePath,
    String? caption,
    DateTime? timestamp,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      caption: caption ?? this.caption,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      imagePath: json['image_path'] as String,
      caption: json['caption'] as String?, // Обработка null
      timestamp: DateTime.parse(json['timestamp'] as String), // Преобразование строки в DateTime
    );
  }
}

class Friendship {
  final int userId;
  final int friendId;

  Friendship({
    required this.userId,
    required this.friendId,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      userId: json['user_id'] as int,
      friendId: json['friend_id'] as int,
    );
  }
}

class Comment {
  final int commentId;
  final int postId;
  final int userId;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['comment_id'] as int,
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String), // Преобразование строки в DateTime
    );
  }
}

class Like {
  final int postId;
  final int userId;

  Like({
    required this.postId,
    required this.userId,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
    );
  }
}
