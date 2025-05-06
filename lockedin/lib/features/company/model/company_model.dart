class Company {
  final String id;
  final String name;
  final String address;
  final String? website;
  final String industry;
  final String organizationSize;
  final String organizationType;
  final String? tagLine;
  final String? location;
  final String? logo;
  final bool isFollowing;

  Company({
    this.id = "",
    required this.name,
    required this.address,
    this.website,
    required this.industry,
    required this.organizationSize,
    required this.organizationType,
    this.tagLine,
    this.location,
    this.logo,
    this.isFollowing = false,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      website: json['website'], // nullable
      industry: json['industry'] ?? '',
      organizationSize: json['organizationSize'] ?? '',
      organizationType: json['organizationType'] ?? '',
      tagLine: json['tagLine'], // nullable
      location: json['location'], // nullable
      logo: json['logo'], // nullable
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'website': website,
      'industry': industry,
      'organizationSize': organizationSize,
      'organizationType': organizationType,
      'tagLine': tagLine,
      'location': location,
      'logo': logo,
      'isFollowing': isFollowing,
    };
  }

  Company copyWith({
    String? id,
    String? name,
    String? address,
    String? website,
    String? industry,
    String? organizationSize,
    String? organizationType,
    String? tagLine,
    String? location,
    String? logo,
    bool? isFollowing,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      website: website ?? this.website,
      industry: industry ?? this.industry,
      organizationSize: organizationSize ?? this.organizationSize,
      organizationType: organizationType ?? this.organizationType,
      tagLine: tagLine ?? this.tagLine,
      location: location ?? this.location,
      logo: logo ?? this.logo,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
