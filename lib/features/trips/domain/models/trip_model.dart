import 'package:flutter/material.dart';

enum TripStatus { pending, ongoing, completed, cancelled }

class TripModel {
  final String? id;
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

  TripModel({
    this.id,
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
  });

  double get totalExpenses => expenses.fold(0, (sum, item) => sum + item.amount);
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
