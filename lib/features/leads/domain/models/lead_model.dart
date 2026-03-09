import 'package:get/get.dart';

class LeadModel {
  final String? id;
  final String customerName;
  final String phone;
  final String? email;
  final String route;
  final DateTime date;
  final String duration;
  final String vehicleType;
  final int vehicleCount;
  final String? pickupAddress;
  final List<String> destinationPoints;
  final double totalAmount;
  final double advancePayment;
  final String status; // 'Pending', 'Quotation Sent', 'Confirmed', 'Cancelled'
  final DateTime? createdAt;

  LeadModel({
    this.id,
    required this.customerName,
    required this.phone,
    this.email,
    required this.route,
    required this.date,
    required this.duration,
    required this.vehicleType,
    required this.vehicleCount,
    this.pickupAddress,
    this.destinationPoints = const [],
    required this.totalAmount,
    required this.advancePayment,
    this.status = 'Pending',
    this.createdAt,
  });

  double get pendingAmount => totalAmount - advancePayment;

  factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
        id: json['id'],
        customerName: json['customer_name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        route: json['route'] ?? '',
        date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
        duration: json['duration'] ?? '',
        vehicleType: json['vehicle_type'] ?? '',
        vehicleCount: json['vehicle_count'] ?? 1,
        pickupAddress: json['pickup_address'],
        destinationPoints: List<String>.from(json['destination_points'] ?? []),
        totalAmount: (json['total_amount'] ?? 0).toDouble(),
        advancePayment: (json['advance_payment'] ?? 0).toDouble(),
        status: json['status'] ?? 'Pending',
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_name': customerName,
        'phone': phone,
        'email': email,
        'route': route,
        'date': date.toIso8601String(),
        'duration': duration,
        'vehicle_type': vehicleType,
        'vehicle_count': vehicleCount,
        'pickup_address': pickupAddress,
        'destination_points': destinationPoints,
        'total_amount': totalAmount,
        'advance_payment': advancePayment,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}

class LeadNote {
  final String id;
  final String leadId;
  final String note;
  final String userName;
  final DateTime createdAt;

  LeadNote({
    required this.id,
    required this.leadId,
    required this.note,
    required this.userName,
    required this.createdAt,
  });

  factory LeadNote.fromJson(Map<String, dynamic> json) => LeadNote(
        id: json['id'],
        leadId: json['lead_id'],
        note: json['note'],
        userName: json['user_name'],
        createdAt: DateTime.parse(json['created_at']),
      );
}
