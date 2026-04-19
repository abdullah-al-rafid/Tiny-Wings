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
  final String type; // e.g., 'Donor', 'Volunteer'
  final String? profession;
  final String? skills;
  final String? emergencyPhone;
  final String? bloodGroup;
  final bool isAnonymous;
  final bool notifyDonationStatus;
  final bool notifySponsorships;
  final bool notifyNewNeeds;
  final bool notifyMarketing;
  
  bool get isAdmin => type == 'Admin';

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
    this.type = 'Donor',
    this.profession,
    this.skills,
    this.emergencyPhone,
    this.bloodGroup,
    this.isAnonymous = false,
    this.notifyDonationStatus = true,
    this.notifySponsorships = true,
    this.notifyNewNeeds = true,
    this.notifyMarketing = false,
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
    String? type,
    String? profession,
    String? skills,
    String? emergencyPhone,
    String? bloodGroup,
    bool? isAnonymous,
    bool? notifyDonationStatus,
    bool? notifySponsorships,
    bool? notifyNewNeeds,
    bool? notifyMarketing,
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
      type: type ?? this.type,
      profession: profession ?? this.profession,
      skills: skills ?? this.skills,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      notifyDonationStatus: notifyDonationStatus ?? this.notifyDonationStatus,
      notifySponsorships: notifySponsorships ?? this.notifySponsorships,
      notifyNewNeeds: notifyNewNeeds ?? this.notifyNewNeeds,
      notifyMarketing: notifyMarketing ?? this.notifyMarketing,
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
      type: json['type'] ?? 'Donor',
      profession: json['profession'],
      skills: json['skills'],
      emergencyPhone: json['emergencyPhone'],
      bloodGroup: json['bloodGroup'],
      isAnonymous: json['isAnonymous'] ?? false,
      notifyDonationStatus: json['notifyDonationStatus'] ?? true,
      notifySponsorships: json['notifySponsorships'] ?? true,
      notifyNewNeeds: json['notifyNewNeeds'] ?? true,
      notifyMarketing: json['notifyMarketing'] ?? false,
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
      'type': type,
      'profession': profession,
      'skills': skills,
      'emergencyPhone': emergencyPhone,
      'bloodGroup': bloodGroup,
      'isAnonymous': isAnonymous,
      'notifyDonationStatus': notifyDonationStatus,
      'notifySponsorships': notifySponsorships,
      'notifyNewNeeds': notifyNewNeeds,
      'notifyMarketing': notifyMarketing,
    };
  }
}
