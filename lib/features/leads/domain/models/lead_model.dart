import 'package:get/get.dart';

class LeadModel {
  final String? id;
  final String leadNo;
  final String customerName;
  final String phone;
  final String? email;
  final String route;
  final DateTime date;
  final String duration;
  final String vehicleType;
  final String? vehicleTypeName;
  final int? vehicleTypeId; 
  final int vehicleCount;
  final String? pickupAddress;
  final List<String> destinationPoints;
  final List<Map<String, dynamic>>? rawPoints; 
  final double totalAmount;
  final double advancePayment;
  final String status; 
  final String? quotationPath; // Added
  final DateTime? createdAt;

  LeadModel({
    this.id,
    required this.leadNo,
    required this.customerName,
    required this.phone,
    this.email,
    required this.route,
    required this.date,
    required this.duration,
    required this.vehicleType,
    this.vehicleTypeName,
    this.vehicleTypeId,
    required this.vehicleCount,
    this.pickupAddress,
    this.destinationPoints = const [],
    this.rawPoints,
    required this.totalAmount,
    required this.advancePayment,
    this.status = 'Pending',
    this.quotationPath,
    this.createdAt,
  });

  double get pendingAmount => totalAmount - advancePayment;

  factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
        id: json['id']?.toString(),
        leadNo: json['lead_no'] ?? json['lead_number'] ?? '',
        customerName: json['customer_name'] ?? '',
        phone: json['phone'] ?? json['customer_contact'] ?? '',
        email: json['email'],
        route: json['route'] ?? json['trip_route'] ?? '',
        date: json['date'] != null ? DateTime.parse(json['date']) : 
              json['trip_date'] != null ? DateTime.parse(json['trip_date']) : DateTime.now(),
        duration: json['duration'] ?? json['duration_days']?.toString() ?? '',
        vehicleType: json['vehicle_type']?.toString() ?? '',
        vehicleTypeName: json['vehicle_type_details']?['name']?.toString(),
        vehicleTypeId: int.tryParse(json['vehicle_type']?.toString() ?? ''),
        vehicleCount: json['vehicle_count'] ?? json['seating_capacity'] ?? 1,
        pickupAddress: json['pickup_address'],
        destinationPoints: json['destination_points'] != null 
            ? List<String>.from(json['destination_points'])
            : (json['points'] is List 
                ? (json['points'] as List).map((p) => p['name']?.toString() ?? '').where((n) => n.isNotEmpty).toList()
                : []),
        rawPoints: json['points'] is List ? List<Map<String, dynamic>>.from(json['points']) : null,
        totalAmount: _toDouble(json['total_amount'] ?? json['total_amount']),
        advancePayment: _toDouble(json['advance_payment'] ?? json['advance_amount']),
        status: json['status'] ?? 'Pending',
        quotationPath: json['quotation_path'],
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'lead_no': leadNo,
        'customer_name': customerName,
        'phone': phone,
        'email': email,
        'route': route,
        'date': date.toIso8601String(),
        'duration': duration,
        'vehicle_type': vehicleType,
        'vehicle_type_name': vehicleTypeName,
        'vehicle_count': vehicleCount,
        'pickup_address': pickupAddress,
        'destination_points': destinationPoints,
        'points': rawPoints,
        'total_amount': totalAmount,
        'advance_payment': advancePayment,
        'status': status,
        'quotation_path': quotationPath,
        'created_at': createdAt?.toIso8601String(),
      };

  static double _toDouble(dynamic val) => val is double ? val : double.tryParse(val?.toString() ?? '0.0') ?? 0.0;

  static LeadModel empty() => LeadModel(
    id: null,
    leadNo: '',
    customerName: '',
    phone: '',
    email: null,
    route: '',
    date: DateTime.now(),
    duration: '',
    vehicleType: '',
    vehicleTypeName: null,
    vehicleCount: 1,
    pickupAddress: null,
    destinationPoints: const [],
    totalAmount: 0,
    advancePayment: 0,
    status: 'Pending',
    createdAt: null,
  );
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

  factory LeadNote.fromJson(Map<String, dynamic> json) {
    String authorName = 'User';
    if (json['author'] != null && json['author']['name'] != null) {
      authorName = json['author']['name'];
    } else if (json['user_name'] != null) {
      authorName = json['user_name'];
    } else if (json['created_by'] != null) {
      authorName = json['created_by'].toString();
    }

    return LeadNote(
      id: json['id']?.toString() ?? '',
      leadId: json['lead_id']?.toString() ?? json['lead_id']?.toString() ?? '',
      note: json['note'] ?? '',
      userName: authorName,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}
