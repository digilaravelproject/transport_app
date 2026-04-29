import 'package:flutter/material.dart';

enum VehicleStatus { active, maintenance, inactive }

class VehicleModel {
  final int? id;
  final String vehicleNumber;
  final String type;
  final int capacity;
  final int? modelYear;
  final String year; // Kept for backward compatibility if needed, but modelYear is preferred
  final String? driverName;
  final double perKmPrice;
  final double acPricePerKm;
  final DateTime? lastServiceDate;
  final String? rcNumber;
  final DateTime? rcExpiry;
  final String? rcFileUrl;
  final String? insuranceNumber;
  final DateTime? insuranceExpiry;
  final String? insuranceFileUrl;
  final String? permitNumber;
  final DateTime? permitExpiry;
  final String? permitFileUrl;
  final bool isAvailable;
  final bool isActive;
  final int tripsCount;
  final DateTime? createdAt;
  final VehicleStatus status;

  VehicleModel({
    this.id,
    required this.vehicleNumber,
    required this.type,
    required this.capacity,
    this.modelYear,
    required this.year,
    this.driverName,
    this.perKmPrice = 0.0,
    this.acPricePerKm = 0.0,
    this.lastServiceDate,
    this.rcNumber,
    this.rcExpiry,
    this.rcFileUrl,
    this.insuranceNumber,
    this.insuranceExpiry,
    this.insuranceFileUrl,
    this.permitNumber,
    this.permitExpiry,
    this.permitFileUrl,
    this.isAvailable = true,
    this.isActive = true,
    this.tripsCount = 0,
    this.createdAt,
    required this.status,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      vehicleNumber: json['registration_number'] ?? '',
      type: json['type'] ?? '',
      capacity: json['seating_capacity'] ?? 0,
      modelYear: json['model_year'],
      year: (json['model_year'] ?? '').toString(),
      perKmPrice: double.tryParse(json['per_km_price']?.toString() ?? '0') ?? 0.0,
      acPricePerKm: double.tryParse(json['ac_price_per_km']?.toString() ?? '0') ?? 0.0,
      rcNumber: json['rc_number'],
      rcExpiry: _parseDate(json['rc_expiry']),
      rcFileUrl: json['rc_file_url'],
      insuranceNumber: json['insurance_number'],
      insuranceExpiry: _parseDate(json['insurance_expiry']),
      insuranceFileUrl: json['insurance_file_url'],
      permitNumber: json['permit_number'],
      permitExpiry: _parseDate(json['permit_expiry']),
      permitFileUrl: json['permit_file_url'],
      isAvailable: json['is_available'] ?? true,
      isActive: json['is_active'] ?? true,
      tripsCount: json['trips_count'] ?? 0,
      createdAt: _parseDate(json['created_at']),
      status: json['is_active'] == true ? VehicleStatus.active : VehicleStatus.inactive,
      // lastServiceDate and driverName are not in the primary list JSON provided, but might be in details or other endpoints
    );
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // Handle DD-MM-YYYY format from API
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  VehicleModel copyWith({
    int? id,
    String? vehicleNumber,
    String? type,
    int? capacity,
    int? modelYear,
    String? year,
    String? driverName,
    double? perKmPrice,
    double? acPricePerKm,
    DateTime? lastServiceDate,
    String? rcNumber,
    DateTime? rcExpiry,
    String? rcFileUrl,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
    String? insuranceFileUrl,
    String? permitNumber,
    DateTime? permitExpiry,
    String? permitFileUrl,
    bool? isAvailable,
    bool? isActive,
    int? tripsCount,
    DateTime? createdAt,
    VehicleStatus? status,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      modelYear: modelYear ?? this.modelYear,
      year: year ?? this.year,
      driverName: driverName ?? this.driverName,
      perKmPrice: perKmPrice ?? this.perKmPrice,
      acPricePerKm: acPricePerKm ?? this.acPricePerKm,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      rcNumber: rcNumber ?? this.rcNumber,
      rcExpiry: rcExpiry ?? this.rcExpiry,
      rcFileUrl: rcFileUrl ?? this.rcFileUrl,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      insuranceFileUrl: insuranceFileUrl ?? this.insuranceFileUrl,
      permitNumber: permitNumber ?? this.permitNumber,
      permitExpiry: permitExpiry ?? this.permitExpiry,
      permitFileUrl: permitFileUrl ?? this.permitFileUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      tripsCount: tripsCount ?? this.tripsCount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

class FuelEntry {
  final int? id;
  final DateTime date;
  final double amount;
  final double quantity;
  final String station;
  final String? receiptUrl;

  FuelEntry({
    this.id,
    required this.date,
    required this.amount,
    required this.quantity,
    required this.station,
    this.receiptUrl,
  });
}

class PaymentLog {
  final DateTime date;
  final double amount;
  final String? note;
  final String? receiptUrl;

  PaymentLog({
    required this.date,
    required this.amount,
    this.note,
    this.receiptUrl,
  });
}

class ServiceRecord {
  final int id; // Added ID for referencing
  final DateTime date;
  final String type;
  final double totalBill;
  final double paidAmount;
  final String workshop;
  final String? billUrl;
  final List<PaymentLog> payments;

  ServiceRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.totalBill,
    required this.paidAmount,
    required this.workshop,
    this.billUrl,
    this.payments = const [],
  });

  double get pendingAmount => totalBill - paidAmount;
  double get cost => totalBill;
  bool get isFullPaid => pendingAmount <= 0;

  ServiceRecord copyWith({
    double? paidAmount,
    List<PaymentLog>? payments,
  }) {
    return ServiceRecord(
      id: id,
      date: date,
      type: type,
      totalBill: totalBill,
      paidAmount: paidAmount ?? this.paidAmount,
      workshop: workshop,
      billUrl: billUrl,
      payments: payments ?? this.payments,
    );
  }
}

class VehicleDocument {
  final int? id;
  final String name;
  final DateTime uploadDate;
  final DateTime expiryDate;
  final String fileUrl;

  VehicleDocument({
    this.id,
    required this.name,
    required this.uploadDate,
    required this.expiryDate,
    required this.fileUrl,
  });
}
