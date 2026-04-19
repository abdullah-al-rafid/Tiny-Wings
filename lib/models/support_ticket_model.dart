class SupportTicket {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String category; // Suggestion, Complaint, Question
  final String subject;
  final String message;
  final int timestamp;
  final String status; // pending, resolved
  final String? adminReply;
  final int? repliedAt;
  final bool isReadByUser;
  final bool isReadByAdmin;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.category,
    required this.subject,
    required this.message,
    required this.timestamp,
    this.status = 'pending',
    this.adminReply,
    this.repliedAt,
    this.isReadByUser = false,
    this.isReadByAdmin = false,
  });

  SupportTicket copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? category,
    String? subject,
    String? message,
    int? timestamp,
    String? status,
    String? adminReply,
    int? repliedAt,
    bool? isReadByUser,
    bool? isReadByAdmin,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      adminReply: adminReply ?? this.adminReply,
      repliedAt: repliedAt ?? this.repliedAt,
      isReadByUser: isReadByUser ?? this.isReadByUser,
      isReadByAdmin: isReadByAdmin ?? this.isReadByAdmin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'category': category,
      'subject': subject,
      'message': message,
      'timestamp': timestamp,
      'status': status,
      'adminReply': adminReply,
      'repliedAt': repliedAt,
      'isReadByUser': isReadByUser,
      'isReadByAdmin': isReadByAdmin,
    };
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json, [String? id]) {
    return SupportTicket(
      id: id ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      category: json['category'] ?? 'Question',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      status: json['status'] ?? 'pending',
      adminReply: json['adminReply'],
      repliedAt: json['repliedAt'],
      isReadByUser: json['isReadByUser'] ?? true, // Default to true for old tickets
      isReadByAdmin: json['isReadByAdmin'] ?? true, // Default to true for old tickets
    );
  }
}
