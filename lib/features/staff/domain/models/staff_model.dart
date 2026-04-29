import 'package:get/get.dart';

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
  final double salary;
  final String? shift;
  final String? shiftId;
  final String? shiftName;
  final int totalTrips;
  final double dutyHours;
  final double salaryBalance;
  final double advanceTaken;
  final SalaryType salaryType;
  final String? panNumber;
  final String? badgeNumber;
  final DateTime? badgeExpiry;
  final String? bankPassbookUrl;

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
    this.salary = 0.0,
    this.shift,
    this.shiftId,
    this.shiftName,
    this.totalTrips = 0,
    this.dutyHours = 0,
    this.salaryBalance = 0,
    this.advanceTaken = 0,
    this.salaryType = SalaryType.monthly,
    this.panNumber,
    this.badgeNumber,
    this.badgeExpiry,
    this.bankPassbookUrl,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    // Role handling
    String? rId = json['staff_type_id']?.toString();
    String? rName = json['role_name'] ?? json['staff_type_name'];
    if (rName == null && rId != null && !RegExp(r'^[0-9]+$').hasMatch(rId)) {
      rName = rId; // If rId is "driver", treat it as rName
    }

    // Shift handling
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
      photoUrl: json['photo_file'],
      joiningDate: _parseDate(json['date_of_joining']),
      aadharNumber: json['aadhar_number'],
      salary: double.tryParse(json['basic_salary']?.toString() ?? json['salary']?['basic_salary']?.toString() ?? '0') ?? 0,
      shift: sId,
      shiftId: sId,
      shiftName: sName,
      salaryType: json['salary_type'] == 'daily' ? SalaryType.daily : SalaryType.monthly,
      panNumber: json['pan_number'],
      badgeNumber: json['badge'] != null ? json['badge']['number'] : json['badge_number'],
      badgeExpiry: _parseDate(json['badge'] != null ? json['badge']['expiry'] : json['badge_expiry']),
      bankPassbookUrl: json['passbook_file'],
    );
  }

  static DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;
    // Handle DD-MM-YYYY
    if (dateStr.toString().contains('-') && dateStr.toString().split('-').first.length <= 2) {
      try {
        final parts = dateStr.toString().split('-');
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } catch (_) {}
    }
    return DateTime.tryParse(dateStr.toString());
  }

  static StaffRole _mapRole(String? roleName) {
    if (roleName == null) return StaffRole.helper;
    switch (roleName.toLowerCase()) {
      case 'driver': return StaffRole.driver;
      case 'manager': return StaffRole.manager;
      case 'accountant': return StaffRole.accountant;
      default: return StaffRole.helper;
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
  final String name;
  final DateTime uploadDate;
  final DateTime expiryDate;
  final String fileUrl;

  StaffDocument({
    required this.name,
    required this.uploadDate,
    required this.expiryDate,
    required this.fileUrl,
  });
}
