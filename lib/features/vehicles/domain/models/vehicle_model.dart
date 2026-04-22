import 'package:flutter/material.dart';

enum VehicleStatus { active, maintenance, inactive }

class VehicleModel {
  final int? id;
  final String vehicleNumber;
  final String type;
  final int capacity;
  final String model;
  final String year;
  final String? driverName;
  final double perKmPrice;
  final double acPricePerKm;
  final DateTime? lastServiceDate;
  final String? rcNumber;
  final DateTime? rcExpiry;
  final String? insuranceNumber;
  final DateTime? insuranceExpiry;
  final String? permitNumber;
  final DateTime? permitExpiry;
  final VehicleStatus status;

  VehicleModel({
    this.id,
    required this.vehicleNumber,
    required this.type,
    required this.capacity,
    required this.model,
    required this.year,
    this.driverName,
    this.perKmPrice = 0.0,
    this.acPricePerKm = 0.0,
    this.lastServiceDate,
    this.rcNumber,
    this.rcExpiry,
    this.insuranceNumber,
    this.insuranceExpiry,
    this.permitNumber,
    this.permitExpiry,
    required this.status,
  });

  VehicleModel copyWith({
    int? id,
    String? vehicleNumber,
    String? type,
    int? capacity,
    String? model,
    String? year,
    String? driverName,
    double? perKmPrice,
    double? acPricePerKm,
    DateTime? lastServiceDate,
    String? rcNumber,
    DateTime? rcExpiry,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
    String? permitNumber,
    DateTime? permitExpiry,
    VehicleStatus? status,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      model: model ?? this.model,
      year: year ?? this.year,
      driverName: driverName ?? this.driverName,
      perKmPrice: perKmPrice ?? this.perKmPrice,
      acPricePerKm: acPricePerKm ?? this.acPricePerKm,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      rcNumber: rcNumber ?? this.rcNumber,
      rcExpiry: rcExpiry ?? this.rcExpiry,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      permitNumber: permitNumber ?? this.permitNumber,
      permitExpiry: permitExpiry ?? this.permitExpiry,
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
