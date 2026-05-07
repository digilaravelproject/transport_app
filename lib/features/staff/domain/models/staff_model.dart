import 'package:get/get.dart';
import 'package:flutter/material.dart';

enum StaffRole { driver, manager, accountant, helper }
enum StaffStatus { active, inactive }
enum SalaryType { monthly, daily }


class StaffModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;

  final StaffRole role;
  final String? roleId;
  final String? roleName;

  final String? licenseNumber;
  final DateTime? licenseExpiry;

  final String? assignedVehicleNumber;

  final StaffStatus status;
  final String? photoUrl;
  final DateTime? joiningDate;
  final String? aadharNumber;
  final String? panNumber;
  final String? badgeNumber;
  final DateTime? badgeExpiry;
  final String? bankPassbookUrl;

  final double salary;
  final SalaryType salaryType;
  final String? shift;
  final String? shiftId;
  final String? shiftName;

  final int totalTrips;
  final double dutyHours;
  final double salaryBalance;
  final double advanceTaken;

  StaffModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.role = StaffRole.helper,
    this.roleId,
    this.roleName,
    this.licenseNumber,
    this.licenseExpiry,
    this.assignedVehicleNumber,
    required this.status,
    this.photoUrl,
    this.joiningDate,
    this.aadharNumber,
    this.panNumber,
    this.badgeNumber,
    this.badgeExpiry,
    this.bankPassbookUrl,
    this.salary = 0.0,
    this.salaryType = SalaryType.monthly,
    this.shift,
    this.shiftId,
    this.shiftName,
    this.totalTrips = 0,
    this.dutyHours = 0,
    this.salaryBalance = 0,
    this.advanceTaken = 0,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    /// ============================
    /// ROLE HANDLING
    /// ============================
    String? rId = json['staff_type_id']?.toString();
    String? rName = json['role_name'] ?? json['staff_type_name'];

    if (rName == null && rId != null && !RegExp(r'^[0-9]+$').hasMatch(rId)) {
      rName = rId;
    }

    /// ============================
    /// SHIFT HANDLING
    /// ============================
    String? sId;
    String? sName;
    if (json['work_shift'] is Map) {
      sId = json['work_shift']['id']?.toString();
      sName = json['work_shift']['name'];
    } else {
      sId = json['work_shift']?.toString();
    }

    return StaffModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      roleId: rId,
      roleName: rName,
      role: _mapRole(rName),
      licenseNumber: json['license'] != null ? json['license']['number'] : json['dl_number'],
      licenseExpiry: _parseDate(json['license'] != null ? json['license']['expiry'] : json['dl_expiry']),
      assignedVehicleNumber: json['assigned_vehicle'],
      status: json['is_active'] == true || json['is_active'] == 1 ? StaffStatus.active : StaffStatus.inactive,
      photoUrl: json['photo_file'] ?? json['photo'],
      joiningDate: _parseDate(json['date_of_joining']),
      aadharNumber: json['aadhar_number'],
      panNumber: json['pan_number'],
      badgeNumber: json['badge'] != null ? json['badge']['number'] : json['badge_number'],
      badgeExpiry: _parseDate(json['badge'] != null ? json['badge']['expiry'] : json['badge_expiry']),
      bankPassbookUrl: json['passbook_file'] ?? json['bank_passbook'],
      salary: double.tryParse(json['basic_salary']?.toString() ?? json['salary']?['basic_salary']?.toString() ?? '0') ?? 0.0,
      salaryType: json['salary_type'] == 'daily' ? SalaryType.daily : SalaryType.monthly,
      shift: sId,
      shiftId: sId,
      shiftName: sName,
      totalTrips: json['total_trips'] ?? 0,
      dutyHours: double.tryParse(json['total_duty_hours']?.toString() ?? '0') ?? 0.0,
      salaryBalance: double.tryParse(json['salary_balance']?.toString() ?? '0') ?? 0.0,
      advanceTaken: double.tryParse(json['advance_taken']?.toString() ?? '0') ?? 0.0,
    );
  }

  /// ============================
  /// DATE PARSER (DD-MM-YYYY + ISO SAFE)
  /// ============================
  static DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;

    try {
      final str = dateStr.toString();

      /// DD-MM-YYYY FORMAT
      if (str.contains('-') && str.split('-').first.length <= 2) {
        final parts = str.split('-');
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }

      /// ISO FORMAT
      return DateTime.tryParse(str);
    } catch (_) {
      return null;
    }
  }

  /// ============================
  /// ROLE MAPPING
  /// ============================
  static StaffRole _mapRole(String? roleName) {
    if (roleName == null) return StaffRole.helper;

    switch (roleName.toLowerCase()) {
      case 'driver':
        return StaffRole.driver;
      case 'manager':
        return StaffRole.manager;
      case 'accountant':
        return StaffRole.accountant;
      default:
        return StaffRole.helper;
    }
  }
}

class AttendanceRecord {
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double totalHours;
  final String staffName;
  final String? status;

  AttendanceRecord({
    required this.date,
    this.checkIn,
    this.checkOut,
    this.totalHours = 0,
    required this.staffName,
    this.status,
  });
}

class SalaryRecord {
  final String month;
  final double totalSalary;
  final double paidAmount;
  final double pendingAmount;

  SalaryRecord({
    required this.month,
    required this.totalSalary,
    required this.paidAmount,
    required this.pendingAmount,
  });
}

class AdvancePayment {
  final double amount;
  final String reason;
  final DateTime date;
  final String staffName;

  AdvancePayment({
    required this.amount,
    required this.reason,
    required this.date,
    required this.staffName,
  });
}

class StaffDocument {
  final int id;
  final String documentType;
  final String? documentNumber;
  final DateTime? expiryDate;
  final bool isVerified;
  final String? notes;
  final String? createdAt;
  final String? viewUrl;
  final String? downloadUrl;

  StaffDocument({
    required this.id,
    required this.documentType,
    this.documentNumber,
    this.expiryDate,
    this.isVerified = false,
    this.notes,
    this.createdAt,
    this.viewUrl,
    this.downloadUrl,
  });

  String get name {
    switch (documentType.toLowerCase()) {
      case 'aadhar': return 'Aadhar Card';
      case 'pan': return 'PAN Card';
      case 'license': return 'Driving License';
      case 'badge': return 'Badge';
      case 'bank_passbook': return 'Bank Passbook';
      case 'photo': return 'Photo';
      default: return documentType.capitalizeFirst!;
    }
  }

  factory StaffDocument.fromJson(Map<String, dynamic> json) {
    return StaffDocument(
      id: json['id'] ?? 0,
      documentType: json['document_type'] ?? '',
      documentNumber: json['document_number'],
      expiryDate: _parseDate(json['expiry_date']),
      isVerified: json['is_verified'] ?? false,
      notes: json['notes'],
      createdAt: json['created_at'],
      viewUrl: json['view_url'],
      downloadUrl: json['download_url'],
    );
  }

  static DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;
    try {
      final str = dateStr.toString();
      if (str.contains('-') && str.split('-').first.length <= 2) {
        final parts = str.split('-');
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
      return DateTime.tryParse(str);
    } catch (_) {
      return null;
    }
  }
}