import 'dart:convert';

import '../utils/firestore_value_parser.dart';

class PostComment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;

  PostComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PostComment.fromMap(Map<String, dynamic> map) {
    return PostComment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      content: map['content'] ?? '',
      timestamp: parseFirestoreDateTime(map['timestamp']) ?? DateTime.now(),
    );
  }
}

class Post {
  final String id;
  final String content;
  final String? imageData; // Base64 string
  final DateTime timestamp;
  final String? tag;
  final String authorId;
  final List<String> likes; // Resident IDs
  final List<PostComment> comments;

  Post({
    required this.id,
    required this.content,
    this.imageData,
    required this.timestamp,
    this.tag,
    required this.authorId,
    this.likes = const [],
    this.comments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'imageData': imageData,
      'timestamp': timestamp.toIso8601String(),
      'tag': tag,
      'authorId': authorId,
      'likes': likes,
      'comments': comments.map((x) => x.toMap()).toList(),
    };
  }

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    var commentsList = map['comments'] as List<dynamic>?;
    List<PostComment> parsedComments = [];
    if (commentsList != null) {
      parsedComments = commentsList.map((c) => PostComment.fromMap(Map<String, dynamic>.from(c))).toList();
    }

    return Post(
      id: id,
      content: map['content'] ?? '',
      imageData: map['imageData'],
      timestamp: parseFirestoreDateTime(map['timestamp']) ?? DateTime.now(),
      tag: map['tag'],
      authorId: map['authorId'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      comments: parsedComments,
    );
  }

  String toJson() => json.encode(toMap());

  Post copyWith({
    String? id,
    String? content,
    String? imageData,
    DateTime? timestamp,
    String? tag,
    String? authorId,
    List<String>? likes,
    List<PostComment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      imageData: imageData ?? this.imageData,
      timestamp: timestamp ?? this.timestamp,
      tag: tag ?? this.tag,
      authorId: authorId ?? this.authorId,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}
