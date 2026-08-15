import '../utils/firestore_value_parser.dart';

class Subscription {
  final String? id;
  final String donorId;
  final String donorName;
  final String targetType; // 'org' or 'child'
  final String targetId;
  final String targetName; 
  final String orgId; // Added to link to organization
  final double amount; 
  final String status; // 'pending', 'active', 'cancelled'
  final DateTime startDate;
  final DateTime lastPaymentDate;
  final int totalPayments;
  final double totalAmountPaid;

  Subscription({
    this.id,
    required this.donorId,
    required this.donorName,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.orgId,
    required this.amount,
    this.status = 'pending',
    required this.startDate,
    required this.lastPaymentDate,
    this.totalPayments = 1,
    double? totalAmountPaid,
  }) : totalAmountPaid = totalAmountPaid ?? amount;

  Map<String, dynamic> toJson() {
    return {
      'donorId': donorId,
      'donorName': donorName,
      'targetType': targetType,
      'targetId': targetId,
      'targetName': targetName,
      'orgId': orgId,
      'amount': amount,
      'status': status,
       'startDate': startDate.toIso8601String(),
      'lastPaymentDate': lastPaymentDate.toIso8601String(),
      'totalPayments': totalPayments,
      'totalAmountPaid': totalAmountPaid,
    };
  }

  factory Subscription.fromJson(String id, Map<String, dynamic> json) {
    return Subscription(
      id: id,
      donorId: json['donorId'] ?? '',
      donorName: json['donorName'] ?? 'Anonymous',
      targetType: json['targetType'] ?? 'org',
      targetId: json['targetId'] ?? '',
      targetName: json['targetName'] ?? '',
      orgId: json['orgId'] ?? (json['targetType'] == 'org' ? json['targetId'] : ''),
      amount: parseFirestoreDouble(json['amount']) ?? 0.0,
      status: json['status'] ?? 'pending',
      startDate: parseFirestoreDateTime(json['startDate']) ?? DateTime.now(),
      lastPaymentDate: parseFirestoreDateTime(json['lastPaymentDate']) ?? DateTime.now(),
      totalPayments: json['totalPayments'] ?? 1,
      totalAmountPaid: parseFirestoreDouble(json['totalAmountPaid']),
    );
  }
}
