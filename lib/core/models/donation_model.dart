
import '../utils/firestore_value_parser.dart';

enum DonationType { money, items }

class Donation {
  final String? id;
  final String donorId;
  final String donorName;
  final String organizationId;
  final String organizationName;
  final DonationType type;
  
  final String status; // pending, verified, shipped, received, rejected
  final String? itemName;
  final double? estimatedValue;
  final double? approvedValue;
  final String? adminNote;
  
  // Money specific
  final double? amount;
  final String? paymentMethod;
  
  // Items specific
  final String? itemCategory; // Food, Clothing, Toys, Books, Medical
  final String? needId; // The ID of the need this donation is fulfilling
  final double? quantity; // Numerical value for summation
  final String? unit; // kg, pieces, units, etc.
  final String? condition; // (Not used currently, kept for compatibility)
  
  final String? notes;
  final DateTime timestamp;

  Donation({
    this.id,
    required this.donorId,
    required this.donorName,
    required this.organizationId,
    required this.organizationName,
    required this.type,
    this.status = 'verified',
    this.itemName,
    this.estimatedValue,
    this.approvedValue,
    this.adminNote,
    this.amount,
    this.paymentMethod,
    this.itemCategory,
    this.needId,
    this.quantity,
    this.unit,
    this.condition,
    this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'donorId': donorId,
      'donorName': donorName,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'type': type.name,
      'status': status,
      if (itemName != null) 'itemName': itemName,
      if (estimatedValue != null) 'estimatedValue': estimatedValue,
      if (approvedValue != null) 'approvedValue': approvedValue,
      if (adminNote != null) 'adminNote': adminNote,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (itemCategory != null) 'itemCategory': itemCategory,
      if (needId != null) 'needId': needId,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Donation.fromJson(String id, Map<String, dynamic> json) {
    double? parsedQuantity;
    if (json['quantity'] is num) {
      parsedQuantity = (json['quantity'] as num).toDouble();
    } else if (json['quantity'] is String) {
      parsedQuantity = double.tryParse((json['quantity'] as String).split(' ').first);
    }

    return Donation(
      id: id,
      donorId: json['donorId'] ?? '',
      donorName: json['donorName'] ?? 'Supporter',
      organizationId: json['organizationId'] ?? '',
      organizationName: json['organizationName'] ?? '',
      type: json['type'] == 'items' ? DonationType.items : DonationType.money,
      status: json['status'] ?? 'verified',
      itemName: json['itemName'],
      estimatedValue: parseFirestoreDouble(json['estimatedValue']),
      approvedValue: parseFirestoreDouble(json['approvedValue']),
      adminNote: json['adminNote'],
      amount: parseFirestoreDouble(json['amount']),
      paymentMethod: json['paymentMethod'],
      itemCategory: json['itemCategory'],
      needId: json['needId'],
      quantity: parsedQuantity,
      unit: json['unit'],
      notes: json['notes'],
      timestamp: parseFirestoreDateTime(json['timestamp']) ?? DateTime.now(),
    );
  }

  Donation copyWith({
    String? id,
    String? status,
    double? approvedValue,
    String? adminNote,
  }) {
    return Donation(
      id: id ?? this.id,
      donorId: donorId,
      donorName: donorName,
      organizationId: organizationId,
      organizationName: organizationName,
      type: type,
      status: status ?? this.status,
      itemName: itemName,
      estimatedValue: estimatedValue,
      approvedValue: approvedValue ?? this.approvedValue,
      adminNote: adminNote ?? this.adminNote,
      amount: amount,
      paymentMethod: paymentMethod,
      itemCategory: itemCategory,
      needId: needId,
      quantity: quantity,
      unit: unit,
      condition: condition,
      notes: notes,
      timestamp: timestamp,
    );
  }
}
