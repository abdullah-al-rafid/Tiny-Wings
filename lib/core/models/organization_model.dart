import '../utils/firestore_value_parser.dart';

enum VerificationStatus {
  pending,
  verified,
  rejected
}

class Organization {
  final String id;
  final String name;
  final String location;
  final String description;
  final String about;
  final String phone;
  final String email;
  final String imageUrl;
  final VerificationStatus status;
  final bool isFeatured;
  final int totalChildren;
  final String? submittedBy; // UID of the user who submitted
  final DateTime? submittedAt;
  final String? verifiedBy; // UID of the admin who verified
  final DateTime? approvedAt;
  final String? verificationNotes;
  final int impactChildCount; // Number of children currently supported via sponsorship

  bool get isVerified => status == VerificationStatus.verified;

  Organization({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.about,
    required this.phone,
    required this.email,
    required this.imageUrl,
    this.status = VerificationStatus.pending,
    this.isFeatured = false,
    required this.totalChildren,
    this.submittedBy,
    this.submittedAt,
    this.verifiedBy,
    this.approvedAt,
    this.verificationNotes,
    this.impactChildCount = 0,
  });

  factory Organization.fromJson(String id, Map<String, dynamic> json) {
    return Organization(
      id: id,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      about: json['about'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? (json['isVerified'] == true ? 'verified' : 'pending')),
        orElse: () => VerificationStatus.pending,
      ),
      isFeatured: json['isFeatured'] ?? false,
      totalChildren: json['totalChildren'] ?? 0,
      submittedBy: json['submittedBy'],
      submittedAt: parseFirestoreDateTime(json['submittedAt']),
      verifiedBy: json['verifiedBy'],
      approvedAt: parseFirestoreDateTime(json['approvedAt']),
      verificationNotes: json['verificationNotes'],
      impactChildCount: json['impactChildCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'about': about,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'status': status.name,
      'isFeatured': isFeatured,
      'totalChildren': totalChildren,
      'submittedBy': submittedBy,
      'submittedAt': submittedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'verificationNotes': verificationNotes,
      'impactChildCount': impactChildCount,
    };
  }

  Organization copyWith({
    String? name,
    String? location,
    String? description,
    String? about,
    String? phone,
    String? email,
    String? imageUrl,
    VerificationStatus? status,
    bool? isFeatured,
    int? totalChildren,
    String? submittedBy,
    DateTime? submittedAt,
    String? verifiedBy,
    DateTime? approvedAt,
    String? verificationNotes,
    int? impactChildCount,
  }) {
    return Organization(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      about: about ?? this.about,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      totalChildren: totalChildren ?? this.totalChildren,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      impactChildCount: impactChildCount ?? this.impactChildCount,
    );
  }
}
