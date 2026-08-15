class ChildSponsorship {
  final String? id;
  final String organizationId;
  final String organizationName;
  final String childName;
  final int age;
  final String story;
  final String imageUrl;
  final double monthlyNeeded;
  final String? currentSponsorId;

  ChildSponsorship({
    this.id,
    required this.organizationId,
    required this.organizationName,
    required this.childName,
    required this.age,
    required this.story,
    required this.imageUrl,
    required this.monthlyNeeded,
    this.currentSponsorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'organizationName': organizationName,
      'childName': childName,
      'age': age,
      'story': story,
      'imageUrl': imageUrl,
      'monthlyNeeded': monthlyNeeded,
      if (currentSponsorId != null) 'currentSponsorId': currentSponsorId,
    };
  }

  factory ChildSponsorship.fromJson(String id, Map<String, dynamic> json) {
    return ChildSponsorship(
      id: id,
      organizationId: json['organizationId'] ?? '',
      organizationName: json['organizationName'] ?? '',
      childName: json['childName'] ?? '',
      age: json['age'] ?? 0,
      story: json['story'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      monthlyNeeded: (json['monthlyNeeded'] as num?)?.toDouble() ?? 0.0,
      currentSponsorId: json['currentSponsorId'],
    );
  }
}
