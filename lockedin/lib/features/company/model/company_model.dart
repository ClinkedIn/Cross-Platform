class Company {
  final String userId;
  final String name;
  final String address;
  final String website;
  final String industry;
  final String organizationSize;
  final String organizationType;
  final String logo;
  final String tagLine;
  final String? id;
  final List<String>? followers;
  final List<String>? visitors;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Company({
    required this.userId,
    required this.name,
    required this.address,
    required this.website,
    required this.industry,
    required this.organizationSize,
    required this.organizationType,
    required this.logo,
    required this.tagLine,
    this.id,
    this.followers,
    this.visitors,
    this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      userId: json['userId'],
      name: json['name'],
      address: json['address'],
      website: json['website'],
      industry: json['industry'],
      organizationSize: json['organizationSize'],
      organizationType: json['organizationType'],
      logo: json['logo'],
      tagLine: json['tagLine'],
      id: json['_id'],
      followers: List<String>.from(json['followers'] ?? []),
      visitors: List<String>.from(json['visitors'] ?? []),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "address": address,
      "website": website,
      "industry": industry,
      "organizationSize": organizationSize,
      "organizationType": organizationType,
      "logo": logo,
      "tagLine": tagLine,
    };
  }
}
