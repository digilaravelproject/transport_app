import 'package:flutter/material.dart';

class VehicleTypeModel {
  final int? id;
  final String name;
  final String? description;
  final int capacity;
  final double perKmPrice;
  final double acPricePerKm;
  final bool isActive;
  final DateTime? createdAt;

  VehicleTypeModel({
    this.id,
    required this.name,
    this.description,
    this.capacity = 0,
    this.perKmPrice = 0.0,
    this.acPricePerKm = 0.0,
    this.isActive = true,
    this.createdAt,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      capacity: int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
      perKmPrice: double.tryParse(json['per_km_price']?.toString() ?? '0') ?? 0.0,
      acPricePerKm: double.tryParse(json['ac_price_per_km']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'per_km_price': perKmPrice,
      'ac_price_per_km': acPricePerKm,
      'is_active': isActive ? 1 : 0,
    };
  }
}
