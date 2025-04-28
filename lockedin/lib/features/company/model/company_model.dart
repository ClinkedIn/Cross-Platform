class Company {
  final String name;
  final String address;
  final String? website;
  final String industry;
  final String organizationSize;
  final String organizationType;
  final String? tagLine;
  final String? location;
  final String? logo;

  Company({
    required this.name,
    required this.address,
    this.website,
    required this.industry,
    required this.organizationSize,
    required this.organizationType,
    this.tagLine,
    this.location,
    this.logo,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      website: json['website'], // nullable
      industry: json['industry'] ?? '',
      organizationSize: json['organizationSize'] ?? '',
      organizationType: json['organizationType'] ?? '',
      tagLine: json['tagLine'], // nullable
      location: json['location'], // nullable
      logo: json['logo'], // nullable
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
    };
  }
}
