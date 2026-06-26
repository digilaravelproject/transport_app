import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TripStatus { pending, ongoing, completed, cancelled }

class TripModel {
  final String? id;
  final String? tripNumber;
  final String route;
  final DateTime date;
  final String duration;
  final String tripType; // One way / Round
  final String vehicleType;
  final int vehicleCount;
  final int seatingCapacity;
  final String? driverName;
  final String? vehicleNumber;
  final String? customerName;
  final String? customerPhone;
  final double totalAmount;
  final double advanceAmount;
  final double pendingAmount;
  final TripStatus status;
  final List<TripTimelineItem> timeline;
  final List<TripExpense> expenses;
  final String? pickupAddress;
  final List<Map<String, dynamic>>? destinationPoints;
  final String? invoiceUrl;
  final String? dutySlipUrl;
  final String? notes;
  final List<Map<String, dynamic>> assignedVehicles;
  final List<Map<String, dynamic>> assignedDrivers;
  final Map<String, dynamic>? vehicleTypeDetails;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? payment;

  // Getters for compatibility
  String get tripDate => DateFormat('yyyy-MM-dd').format(date);
  String get tripRoute => route;
  int get durationDays => int.tryParse(duration.split(' ')[0]) ?? 1;

  TripModel({
    this.id,
    this.tripNumber,
    required this.route,
    required this.date,
    required this.duration,
    required this.tripType,
    required this.vehicleType,
    required this.vehicleCount,
    required this.seatingCapacity,
    this.driverName,
    this.vehicleNumber,
    this.customerName,
    this.customerPhone,
    this.totalAmount = 0.0,
    this.advanceAmount = 0.0,
    this.pendingAmount = 0.0,
    this.status = TripStatus.pending,
    this.timeline = const [],
    this.expenses = const [],
    this.pickupAddress,
    this.destinationPoints,
    this.invoiceUrl,
    this.dutySlipUrl,
    this.notes,
    this.assignedVehicles = const [],
    this.assignedDrivers = const [],
    this.vehicleTypeDetails,
    this.customer,
    this.payment,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse date from DD-MM-YYYY
    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        final parts = dateStr.split(' ')[0].split('-');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } catch (_) {}
      return DateTime.tryParse(dateStr) ?? DateTime.now();
    }

    final vehicleTypeDetails = json['vehicle_type_details'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    final payment = json['payment'] as Map<String, dynamic>?;
    final driver = json['driver'] as Map<String, dynamic>?;
    
    final List<dynamic>? vehiclesList = json['vehicles'] is List ? json['vehicles'] : null;
    final List<dynamic>? driversList = json['drivers'] is List ? json['drivers'] : null;

    final List<Map<String, dynamic>> parsedVehicles = vehiclesList != null 
        ? List<Map<String, dynamic>>.from(vehiclesList) 
        : [];
    final List<Map<String, dynamic>> parsedDrivers = driversList != null 
        ? List<Map<String, dynamic>>.from(driversList) 
        : [];

    return TripModel(
      id: json['id']?.toString(),
      tripNumber: json['trip_number'],
      route: json['trip_route'] ?? '',
      date: parseDate(json['trip_date']),
      duration: "${json['duration_days'] ?? 0} Days",
      tripType: json['trip_route'] ?? 'One Way',
      vehicleType: vehicleTypeDetails?['name'] ?? 'Luxury Bus',
      vehicleCount: json['number_of_vehicles'] ?? 1,
      seatingCapacity: vehicleTypeDetails?['capacity'] ?? 4,
      driverName: driver?['name'] ?? (parsedDrivers.isNotEmpty ? parsedDrivers.first['name'] : null),
      vehicleNumber: (parsedVehicles.isNotEmpty ? parsedVehicles.first['registration_number'] : null),
      customerName: customer?['name'],
      customerPhone: customer?['contact'],
      totalAmount: _parseDouble(payment?['total']),
      advanceAmount: _parseDouble(payment?['advance']),
      pendingAmount: _parseDouble(payment?['balance']),
      status: _parseStatus(json['status']),
      pickupAddress: json['pickup_address'],
      destinationPoints: _parseDestinationPoints(json['destination_points']),
      invoiceUrl: json['invoice_url'],
      dutySlipUrl: json['duty_slip_url'],
      notes: json['notes'],
      assignedVehicles: parsedVehicles,
      assignedDrivers: parsedDrivers,
      vehicleTypeDetails: vehicleTypeDetails,
      customer: customer,
      payment: payment,
    );
  }

  static TripStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'ongoing':
        return TripStatus.ongoing;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.pending;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<Map<String, dynamic>>? _parseDestinationPoints(dynamic points) {
    if (points == null) return null;
    if (points is List) {
      if (points.isEmpty) return <Map<String, dynamic>>[];
      if (points.first is String) {
        return points.map((p) => <String, dynamic>{'name': p.toString(), 'type': 'stop'}).toList();
      } else if (points.first is Map) {
        return List<Map<String, dynamic>>.from(points);
      }
    }
    return null;
  }

  double get totalExpenses => expenses.fold(0, (sum, item) => sum + item.amount);

  String get allDriverNames {
    if (assignedDrivers.isEmpty) return 'Unassigned';
    return assignedDrivers.map((d) => d['name']?.toString() ?? 'N/A').join(', ');
  }

  String get allVehicleNumbers {
    if (assignedVehicles.isEmpty) return 'Not Assigned';
    return assignedVehicles.map((v) => v['registration_number']?.toString() ?? 'N/A').join(', ');
  }
}

class TripExpense {
  final String id;
  final String type; // Fuel, Toll, Driver Allowance, etc.
  final double amount;
  final DateTime date;
  final String? note;
  final String? receiptUrl;

  TripExpense({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
    this.receiptUrl,
  });
}

class TripTimelineItem {
  final String status;
  final DateTime timestamp;
  final String? location;
  final bool isCompleted;

  TripTimelineItem({
    required this.status,
    required this.timestamp,
    this.location,
    this.isCompleted = false,
  });
}
