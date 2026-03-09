import 'package:get/get.dart';

enum StaffRole { driver, manager, accountant, helper }
enum StaffStatus { active, inactive }

class StaffModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final StaffRole role;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? assignedVehicleNumber;
  final StaffStatus status;
  final String? photoUrl;
  final DateTime? joiningDate;
  final String? aadharNumber;
  final double salary;
  final String? shift;
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
    required this.role,
    this.licenseNumber,
    this.licenseExpiry,
    this.assignedVehicleNumber,
    required this.status,
    this.photoUrl,
    this.joiningDate,
    this.aadharNumber,
    this.salary = 0.0,
    this.shift,
    this.totalTrips = 0,
    this.dutyHours = 0,
    this.salaryBalance = 0,
    this.advanceTaken = 0,
  });
}

class AttendanceRecord {
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double totalHours;
  final String staffName;

  AttendanceRecord({
    required this.date,
    this.checkIn,
    this.checkOut,
    this.totalHours = 0,
    required this.staffName,
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
