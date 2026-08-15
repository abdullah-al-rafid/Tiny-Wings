import '../utils/firestore_value_parser.dart';

enum UserRole {
  admin,
  donor,
  volunteer,
  orphanageAdmin,
  opportunityPoster
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? district;
  final String? address;
  final String? gender;
  final String? dob;
  final String? bio;
  final String? profilePictureUrl;
  final UserRole role;
  final String status; // 'active', 'pending', 'suspended'
  final String? assignedOrphanageId; // For orphanageAdmin role
  final String? profession;
  final String? skills;
  final String? emergencyPhone;
  final String? bloodGroup;
  final bool isAnonymous;
  final bool notifyDonationStatus;
  final bool notifySponsorships;
  final bool notifyNewNeeds;
  final bool notifyMarketing;
  final Map<String, dynamic>? volunteerMetadata;
  final String? organizationId;
  final String? organizationName;
  final String? type; // e.g. 'donor', 'institution', 'volunteer'
  final DateTime? createdAt;
  
  bool get isAdmin => role == UserRole.admin || role == UserRole.orphanageAdmin || role == UserRole.opportunityPoster;
  bool get isVolunteer => role == UserRole.volunteer;
  bool get isOrphanageAdmin => role == UserRole.orphanageAdmin;
  bool get isDonor => role == UserRole.donor;
  bool get isPoster => role == UserRole.opportunityPoster;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.district,
    this.address,
    this.gender,
    this.dob,
    this.bio,
    this.profilePictureUrl,
    this.role = UserRole.donor,
    this.status = 'active',
    this.assignedOrphanageId,
    this.profession,
    this.skills,
    this.emergencyPhone,
    this.bloodGroup,
    this.isAnonymous = false,
    this.notifyDonationStatus = true,
    this.notifySponsorships = true,
    this.notifyNewNeeds = true,
    this.notifyMarketing = false,
    this.volunteerMetadata,
    this.organizationId,
    this.organizationName,
    this.type,
    this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? district,
    String? address,
    String? gender,
    String? dob,
    String? bio,
    String? profilePictureUrl,
    UserRole? role,
    String? status,
    String? assignedOrphanageId,
    String? profession,
    String? skills,
    String? emergencyPhone,
    String? bloodGroup,
    bool? isAnonymous,
    bool? notifyDonationStatus,
    bool? notifySponsorships,
    bool? notifyNewNeeds,
    bool? notifyMarketing,
    Map<String, dynamic>? volunteerMetadata,
    String? organizationId,
    String? organizationName,
    String? type,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      district: district ?? this.district,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      assignedOrphanageId: assignedOrphanageId ?? this.assignedOrphanageId,
      profession: profession ?? this.profession,
      skills: skills ?? this.skills,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      notifyDonationStatus: notifyDonationStatus ?? this.notifyDonationStatus,
      notifySponsorships: notifySponsorships ?? this.notifySponsorships,
      notifyNewNeeds: notifyNewNeeds ?? this.notifyNewNeeds,
      notifyMarketing: notifyMarketing ?? this.notifyMarketing,
      volunteerMetadata: volunteerMetadata ?? this.volunteerMetadata,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(String uid, Map<String, dynamic> json) {
    return UserModel(
      uid: uid,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      district: json['district'],
      address: json['address'],
      gender: json['gender'],
      dob: json['dob'],
      bio: json['bio'],
      profilePictureUrl: json['profilePictureUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] ?? 'donor'),
        orElse: () => UserRole.donor,
      ),
      status: json['status'] ?? 'active',
      assignedOrphanageId: json['assignedOrphanageId'],
      profession: json['profession'],
      skills: json['skills'],
      emergencyPhone: json['emergencyPhone'],
      bloodGroup: json['bloodGroup'],
      isAnonymous: json['isAnonymous'] ?? false,
      notifyDonationStatus: json['notifyDonationStatus'] ?? true,
      notifySponsorships: json['notifySponsorships'] ?? true,
      notifyNewNeeds: json['notifyNewNeeds'] ?? true,
      notifyMarketing: json['notifyMarketing'] ?? false,
      volunteerMetadata: json['volunteerMetadata'],
      organizationId: json['organizationId'],
      organizationName: json['organizationName'],
      type: json['type'],
      createdAt: parseFirestoreDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'district': district,
      'address': address,
      'gender': gender,
      'dob': dob,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'role': role.name,
      'status': status,
      'assignedOrphanageId': assignedOrphanageId,
      'profession': profession,
      'skills': skills,
      'emergencyPhone': emergencyPhone,
      'bloodGroup': bloodGroup,
      'isAnonymous': isAnonymous,
      'notifyDonationStatus': notifyDonationStatus,
      'notifySponsorships': notifySponsorships,
      'notifyNewNeeds': notifyNewNeeds,
      'notifyMarketing': notifyMarketing,
      'volunteerMetadata': volunteerMetadata,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'type': type,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
