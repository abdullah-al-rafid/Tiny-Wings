
class Organization {
  final String id;
  final String name;
  final String location;
  final String description;
  final String about;
  final String phone;
  final String email;
  final String imageUrl;
  final bool isVerified;
  final bool isFeatured;
  final int totalChildren;

  Organization({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.about,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required this.isVerified,
    this.isFeatured = false,
    required this.totalChildren,
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
      isVerified: json['isVerified'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      totalChildren: json['totalChildren'] ?? 0,
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
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'totalChildren': totalChildren,
    };
  }
}
