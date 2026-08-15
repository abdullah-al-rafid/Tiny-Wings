import 'dart:convert';

import '../utils/firestore_value_parser.dart';

enum NotificationType {
  donation,
  need,
  sponsorship,
  admin,
  message,
  social,
  volunteer,
  other
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime timestamp;
  final String? relatedId; // ID of the donation, need, etc.

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.timestamp,
    this.relatedId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'relatedId': relatedId,
    };
  }

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (value) => value.name == (map['type'] ?? 'other'),
        orElse: () => NotificationType.other,
      ),
      isRead: map['isRead'] ?? false,
      timestamp: parseFirestoreDateTime(map['timestamp']) ?? DateTime.now(),
      relatedId: map['relatedId'],
    );
  }

  String toJson() => json.encode(toMap());

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? timestamp,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}
