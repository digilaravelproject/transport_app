import 'package:flutter/material.dart';

enum VehicleStatus { active, maintenance, inactive }

class VehicleModel {
  final int? id;
  final int? vehicleTypeId;
  final String vehicleNumber;
  final String type;
  final int capacity;
  final String model;
  final int? modelYear;
  final String year; 
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
  final String? gpsDeviceId;
  final String? gpsStatus;
  final String? pucNumber;
  final DateTime? pucExpiry;
  final String? pucFileUrl;
  final String? fitnessNumber;
  final DateTime? fitnessExpiry;
  final String? fitnessFileUrl;
  final bool isAvailable;
  final bool isActive;
  final int tripsCount;
  final DateTime? createdAt;
  final VehicleStatus status;

  VehicleModel({
    this.id,
    this.vehicleTypeId,
    required this.vehicleNumber,
    required this.type,
    required this.capacity,
    this.model = '',
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
    this.gpsDeviceId,
    this.gpsStatus,
    this.pucNumber,
    this.pucExpiry,
    this.pucFileUrl,
    this.fitnessNumber,
    this.fitnessExpiry,
    this.fitnessFileUrl,
    this.isAvailable = true,
    this.isActive = true,
    this.tripsCount = 0,
    this.createdAt,
    required this.status,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Some APIs wrap the object in a 'data' or 'vehicle' key
    final Map<String, dynamic> data = json.containsKey('data') ? json['data'] : (json.containsKey('vehicle') ? json['vehicle'] : json);
    
    return VehicleModel(
      id: data['id'] ?? data['vehicle_id'],
      vehicleTypeId: data['vehicle_type_id'] != null
          ? (data['vehicle_type_id'] is int ? data['vehicle_type_id'] : int.tryParse(data['vehicle_type_id'].toString()))
          : (data['type'] is int ? data['type'] : int.tryParse(data['type']?.toString() ?? '')),
      vehicleNumber: data['registration_number'] ?? '',
      type: data['type'] ?? '',
      capacity: data['seating_capacity'] ?? 0,
      modelYear: data['model_year'],
      year: (data['model_year'] ?? '').toString(),
      model: (data['model'] ?? '').toString(),
      perKmPrice: double.tryParse(data['per_km_price']?.toString() ?? '0') ?? 0.0,
      acPricePerKm: double.tryParse(data['ac_price_per_km']?.toString() ?? '0') ?? 0.0,
      rcNumber: data['rc_number'],
      rcExpiry: _parseDate(data['rc_expiry']),
      rcFileUrl: data['rc_file_url'],
      insuranceNumber: data['insurance_number'],
      insuranceExpiry: _parseDate(data['insurance_expiry']),
      insuranceFileUrl: data['insurance_file_url'],
      permitNumber: data['permit_number'],
      permitExpiry: _parseDate(data['permit_expiry']),
      permitFileUrl: data['permit_file_url'],
      gpsDeviceId: data['gps_device_id'],
      gpsStatus: data['gps_status'],
      pucNumber: data['puc_certificate_number'],
      pucExpiry: _parseDate(data['puc_expiry_date']),
      pucFileUrl: data['puc_certificate_url'],
      fitnessNumber: data['fitness_certificate_number'],
      fitnessExpiry: _parseDate(data['fitness_valid_till']),
      fitnessFileUrl: data['fitness_certificate_url'],
      isAvailable: data['is_available'] ?? true,
      isActive: data['is_active'] ?? true,
      tripsCount: data['trips_count'] ?? 0,
      createdAt: _parseDate(data['created_at']),
      status: data['is_active'] == true ? VehicleStatus.active : VehicleStatus.inactive,
    );
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
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
    String? model,
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
    String? gpsDeviceId,
    String? gpsStatus,
    String? pucNumber,
    DateTime? pucExpiry,
    String? pucFileUrl,
    String? fitnessNumber,
    DateTime? fitnessExpiry,
    String? fitnessFileUrl,
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
      model: model ?? this.model,
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
      gpsDeviceId: gpsDeviceId ?? this.gpsDeviceId,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      pucNumber: pucNumber ?? this.pucNumber,
      pucExpiry: pucExpiry ?? this.pucExpiry,
      pucFileUrl: pucFileUrl ?? this.pucFileUrl,
      fitnessNumber: fitnessNumber ?? this.fitnessNumber,
      fitnessExpiry: fitnessExpiry ?? this.fitnessExpiry,
      fitnessFileUrl: fitnessFileUrl ?? this.fitnessFileUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      tripsCount: tripsCount ?? this.tripsCount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

class VehicleDocument {
  final int? id;
  final String type;
  final String number;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String fileUrl;
  final int alertBeforeDays;
  final String notes;

  VehicleDocument({
    this.id,
    required this.type,
    required this.number,
    this.issueDate,
    this.expiryDate,
    required this.fileUrl,
    this.alertBeforeDays = 30,
    this.notes = '',
  });

  factory VehicleDocument.fromJson(Map<String, dynamic> json) {
    return VehicleDocument(
      id: json['id'],
      type: json['type'] ?? json['document_type'] ?? '',
      number: json['number'] ?? json['document_number'] ?? '',
      issueDate: _parseDate(json['issue_date']),
      expiryDate: _parseDate(json['expiry_date']),
      fileUrl: json['file_url'] ?? json['document_path'] ?? '',
      alertBeforeDays: int.tryParse(json['alert_before_days']?.toString() ?? '30') ?? 30,
      notes: json['notes'] ?? '',
    );
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr);
      }
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        if (parts[0].length == 4) {
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        } else if (parts[2].length == 4) {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
