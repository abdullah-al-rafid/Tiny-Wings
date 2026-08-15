import '../utils/firestore_value_parser.dart';

enum OpportunityStatus {
  pending,
  approved,
  rejected,
  expired
}

class VolunteerOpportunity {
  final String id;
  final String organizationId;
  final String organizationName;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String time;
  final OpportunityStatus status;
  final List<String> requiredSkills;
  final int maxVolunteers;
  final List<String> appliedUserIds;

  VolunteerOpportunity({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    this.status = OpportunityStatus.approved,
    this.requiredSkills = const [],
    this.maxVolunteers = 10,
    this.appliedUserIds = const [],
  });

  factory VolunteerOpportunity.fromJson(String id, Map<String, dynamic> json) {
    return VolunteerOpportunity(
      id: id,
      organizationId: json['organizationId'] ?? '',
      organizationName: json['organizationName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: parseFirestoreDateTime(json['date']) ?? DateTime.now(),
      time: json['time'] ?? '',
      status: OpportunityStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'approved'),
        orElse: () => OpportunityStatus.approved,
      ),
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      maxVolunteers: json['maxVolunteers'] ?? 10,
      appliedUserIds: List<String>.from(json['appliedUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'organizationName': organizationName,
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'time': time,
      'status': status.name,
      'requiredSkills': requiredSkills,
      'maxVolunteers': maxVolunteers,
      'appliedUserIds': appliedUserIds,
    };
  }
}

enum OpportunityCategory {
  jobs,
  scholarships,
  admissions,
  internships,
  training,
  fellowships,
  mentorship,
  housing
}

class Opportunity {
  final String id;
  final String title;
  final OpportunityCategory category;
  final String description;
  final String eligibility;
  final DateTime? deadline;
  final String location;
  final String contactMethod;
  final String postedBy; // User ID
  final String? organizationId; // Optional link to an org
  final OpportunityStatus status;
  final DateTime createdAt;

  Opportunity({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.eligibility,
    this.deadline,
    required this.location,
    required this.contactMethod,
    required this.postedBy,
    this.organizationId,
    this.status = OpportunityStatus.pending,
    required this.createdAt,
  });

  factory Opportunity.fromJson(String id, Map<String, dynamic> json) {
    return Opportunity(
      id: id,
      title: json['title'] ?? '',
      category: OpportunityCategory.values.firstWhere(
        (e) => e.name == (json['category'] ?? 'jobs'),
        orElse: () => OpportunityCategory.jobs,
      ),
      description: json['description'] ?? '',
      eligibility: json['eligibility'] ?? '',
      deadline: parseFirestoreDateTime(json['deadline']),
      location: json['location'] ?? '',
      contactMethod: json['contactMethod'] ?? '',
      postedBy: json['postedBy'] ?? '',
      organizationId: json['organizationId'],
      status: OpportunityStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => OpportunityStatus.pending,
      ),
      createdAt: parseFirestoreDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category.name,
      'description': description,
      'eligibility': eligibility,
      'deadline': deadline?.toIso8601String(),
      'location': location,
      'contactMethod': contactMethod,
      'postedBy': postedBy,
      'organizationId': organizationId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
