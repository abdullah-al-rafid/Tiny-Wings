class Need {
  final String id;
  final String organizationId;
  final String? organizationName;
  final String title;
  final String category;
  final String priority;
  final String subtitle;
  final String quantityOrAmount;
  final double targetQuantity;
  final double fulfilledQuantity;
  final String unit;
  final String deadline;
  final String status;
  final DateTime? createdAt;

  Need({
    required this.id,
    required this.organizationId,
    this.organizationName,
    required this.title,
    required this.category,
    required this.priority,
    required this.subtitle,
    this.quantityOrAmount = '',
    this.targetQuantity = 0.0,
    this.fulfilledQuantity = 0.0,
    this.unit = '',
    this.deadline = '',
    this.status = 'pending',
    this.createdAt,
  });

  factory Need.fromJson(String id, Map<String, dynamic> json, {String? orgName}) {
    return Need(
      id: id,
      organizationId: json['organizationId'] ?? '',
      organizationName: orgName ?? json['organizationName'],
      title: json['title'] ?? '',
      category: json['category'] ?? 'Other',
      priority: json['priority'] ?? 'Normal',
      subtitle: json['subtitle'] ?? '',
      quantityOrAmount: json['quantityOrAmount'] ?? '',
      targetQuantity: (json['targetQuantity'] as num?)?.toDouble() ?? 0.0,
      fulfilledQuantity: (json['fulfilledQuantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      deadline: json['deadline'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      if (organizationName != null) 'organizationName': organizationName,
      'title': title,
      'category': category,
      'priority': priority,
      'subtitle': subtitle,
      'quantityOrAmount': quantityOrAmount,
      'targetQuantity': targetQuantity,
      'fulfilledQuantity': fulfilledQuantity,
      'unit': unit,
      'deadline': deadline,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
