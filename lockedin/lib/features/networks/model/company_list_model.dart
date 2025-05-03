// company_model.dart
import 'dart:convert';

// Model class for a list of companies
class CompanyList {
  final List<CompanyResponse> companies;

  CompanyList({required this.companies});

  factory CompanyList.fromJson(List<dynamic> json) {
    return CompanyList(
      companies: json.map((x) => CompanyResponse.fromJson(x)).toList(),
    );
  }
}

// The response model that contains both company data and user relationship
class CompanyResponse {
  final Company company;
  final String userRelationship;

  CompanyResponse({required this.company, required this.userRelationship});

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(
      company: Company.fromJson(json['company']),
      userRelationship: json['userRelationship'],
    );
  }

  Map<String, dynamic> toJson() => {
    'company': company.toJson(),
    'userRelationship': userRelationship,
  };
}

// Core Company model
class Company {
  final String id;
  final String name;
  final String address;
  final String website;
  final String location;
  final String tagLine;
  final String logo;
  final String industry;
  final String organizationSize;
  final int followersCount;

  Company({
    required this.id,
    required this.name,
    required this.address,
    required this.website,
    required this.location,
    required this.tagLine,
    required this.logo,
    required this.industry,
    required this.organizationSize,
    required this.followersCount,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      website: json['website'] ?? '',
      location: json['location'] ?? '',
      tagLine: json['tagLine'] ?? '',
      logo: json['logo'] ?? '',
      industry: json['industry'] ?? '',
      organizationSize: json['organizationSize'] ?? '',
      followersCount: json['followersCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'website': website,
    'location': location,
    'tagLine': tagLine,
    'logo': logo,
    'industry': industry,
    'organizationSize': organizationSize,
    'followersCount': followersCount,
  };
}

// Helper function to convert JSON string to CompanyList object
CompanyList companyListFromJson(String str) =>
    CompanyList.fromJson(json.decode(str));

// Helper function to convert CompanyList object to JSON string
String companyListToJson(CompanyList data) =>
    json.encode(data.companies.map((company) => company.toJson()).toList());
