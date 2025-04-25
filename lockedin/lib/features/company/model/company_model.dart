class CompanyModel {
  final String id;
  final String userId;
  final String name;
  final String address;
  final String website;
  final String industry;
  final String organizationSize;
  final String organizationType;
  final String logo;
  final String tagLine;
  final List<String> followers;
  final List<String> visitors;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CompanyModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.website,
    required this.industry,
    required this.organizationSize,
    required this.organizationType,
    required this.logo,
    required this.tagLine,
    required this.followers,
    required this.visitors,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      website: json['website'] ?? '',
      industry: json['industry'] ?? '',
      organizationSize: json['organizationSize'] ?? '',
      organizationType: json['organizationType'] ?? '',
      logo: json['logo'] ?? '',
      tagLine: json['tagLine'] ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      visitors: List<String>.from(json['visitors'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'address': address,
      'website': website,
      'industry': industry,
      'organizationSize': organizationSize,
      'organizationType': organizationType,
      'logo': logo,
      'tagLine': tagLine,
      'followers': followers,
      'visitors': visitors,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
