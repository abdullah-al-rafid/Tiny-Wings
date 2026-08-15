import '../utils/firestore_value_parser.dart';

enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  withdrawn
}

class VolunteerApplication {
  final String id;
  final String userId;
  final String userName;
  final String opportunityId;
  final String opportunityTitle;
  final String organizationName;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String? notes;

   VolunteerApplication({
    required this.id,
    required this.userId,
    required this.userName,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.organizationName,
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
    this.notes,
  });

  factory VolunteerApplication.fromJson(String id, Map<String, dynamic> json) {
    return VolunteerApplication(
      id: id,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      opportunityId: json['opportunityId'] ?? '',
      opportunityTitle: json['opportunityTitle'] ?? '',
      organizationName: json['organizationName'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt: parseFirestoreDateTime(json['appliedAt']) ?? DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'organizationName': organizationName,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      'notes': notes,
    };
  }
}
