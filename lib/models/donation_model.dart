

enum DonationType { money, items }

class Donation {
  final String? id;
  final String donorId;
  final String donorName;
  final String organizationId;
  final String organizationName;
  final DonationType type;
  
  final String status;
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
    // Handle old string quantity to avoid crashes
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
      estimatedValue: json['estimatedValue']?.toDouble(),
      approvedValue: json['approvedValue']?.toDouble(),
      adminNote: json['adminNote'],
      amount: json['amount']?.toDouble(),
      paymentMethod: json['paymentMethod'],
      itemCategory: json['itemCategory'],
      needId: json['needId'],
      quantity: parsedQuantity,
      unit: json['unit'],
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
