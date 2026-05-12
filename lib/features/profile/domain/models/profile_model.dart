import 'dart:convert';
import '../../../../core/constants/app_constants.dart';

class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final int? tenantId;
  final String? companyName;
  final String? ownerName;
  final String? gstin;
  final String? address;
  final String? logoUrl;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.tenantId,
    this.companyName,
    this.ownerName,
    this.gstin,
    this.address,
    this.logoUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      tenantId: json['tenant_id'],
      companyName: json['company_name'],
      ownerName: json['owner_name'],
      gstin: json['gstin'],
      address: json['address'],
      logoUrl: AppConstants.getFileUrl(json['logo_url']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'tenant_id': tenantId,
      'company_name': companyName,
      'owner_name': ownerName,
      'gstin': gstin,
      'address': address,
      'logo_url': logoUrl,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory ProfileModel.fromJsonString(String jsonString) {
    return ProfileModel.fromJson(json.decode(jsonString));
  }

  ProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    int? tenantId,
    String? companyName,
    String? ownerName,
    String? gstin,
    String? address,
    String? logoUrl,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      companyName: companyName ?? this.companyName,
      ownerName: ownerName ?? this.ownerName,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, name: $name, email: $email, phone: $phone, role: $role, companyName: $companyName)';
  }
}
