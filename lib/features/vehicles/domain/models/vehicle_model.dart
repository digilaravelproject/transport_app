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
  final DateTime? lastServiceDate;
  final VehicleStatus status;

  VehicleModel({
    this.id,
    required this.vehicleNumber,
    required this.type,
    required this.capacity,
    required this.model,
    required this.year,
    this.driverName,
    this.lastServiceDate,
    required this.status,
  });
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

class ServiceRecord {
  final int? id;
  final DateTime date;
  final String type;
  final double cost;
  final String workshop;
  final String? billUrl;

  ServiceRecord({
    this.id,
    required this.date,
    required this.type,
    required this.cost,
    required this.workshop,
    this.billUrl,
  });
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
