import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:credit_debit/core/constants/app_constants.dart';

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
  final String? licenseType;

  final String? assignedVehicleNumber;

  final StaffStatus status;
  final String? photoUrl;
  final DateTime? dob;
  final DateTime? joiningDate;
  final String? aadharNumber;
  final String? panNumber;
  final String? badgeNumber;
  final DateTime? badgeExpiry;
  
  final String? aadharUrl;
  final String? panUrl;
  final String? licenseUrl;
  final String? badgeUrl;
  final String? bankPassbookUrl;

  final double salary;
  final double? daPerDay;
  final double? hra;
  final SalaryType salaryType;
  
  final String? bankName;
  final String? bankAccount;
  final String? bankIfsc;
  
  final String? emergencyContactName;
  final String? emergencyContact;

  final String? shift;
  final String? shiftId;
  final String? shiftName;

  final int totalTrips;
  final double dutyHours;
  final double salaryBalance;
  final double advanceTaken;
  final bool isAvailable;
  final String? notes;
  final double? otherAllowance;

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
    this.licenseType,
    this.assignedVehicleNumber,
    required this.status,
    this.photoUrl,
    this.dob,
    this.joiningDate,
    this.aadharNumber,
    this.panNumber,
    this.badgeNumber,
    this.badgeExpiry,
    this.aadharUrl,
    this.panUrl,
    this.licenseUrl,
    this.badgeUrl,
    this.bankPassbookUrl,
    this.salary = 0.0,
    this.daPerDay,
    this.hra,
    this.salaryType = SalaryType.monthly,
    this.bankName,
    this.bankAccount,
    this.bankIfsc,
    this.emergencyContactName,
    this.emergencyContact,
    this.shift,
    this.shiftId,
    this.shiftName,
    this.totalTrips = 0,
    this.dutyHours = 0,
    this.salaryBalance = 0,
    this.advanceTaken = 0,
    this.isAvailable = true,
    this.notes,
    this.otherAllowance,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    // Handle nested "staff" object if present (single staff API)
    final Map<String, dynamic> data = json.containsKey('data') && json['data'] is Map && json['data'].containsKey('staff') 
        ? json['data']['staff'] 
        : (json.containsKey('staff') ? json['staff'] : json);

    // Get salary balance and advance from the outer data if available
    final Map<String, dynamic> outerData = json.containsKey('data') && json['data'] is Map ? json['data'] : {};

    /// ============================
    /// ROLE HANDLING
    /// ============================
    String? rId = data['staff_type_id']?.toString() ?? data['role_id']?.toString();
    String? rName = data['role_name'] ?? data['staff_type_name'];
    if (data['role'] is Map) {
      rId = data['role']['id']?.toString() ?? rId;
      rName = data['role']['name'] ?? rName;
    }

    /// ============================
    /// SHIFT HANDLING
    /// ============================
    String? sId;
    String? sName;
    if (data['work_shift'] is Map) {
      sId = data['work_shift']['id']?.toString();
      sName = data['work_shift']['name'];
    } else {
      sId = data['work_shift_id']?.toString() ?? data['work_shift']?.toString();
    }

    /// ============================
    /// NESTED OBJECTS
    /// ============================
    final Map<String, dynamic> licenseMap = (data['license'] is Map) ? data['license'] : {};
    final Map<String, dynamic> badgeMap = (data['badge'] is Map) ? data['badge'] : {};
    final Map<String, dynamic> bankMap = (data['bank'] is Map) ? data['bank'] : {};
    final Map<String, dynamic> salaryMap = (data['salary'] is Map) ? data['salary'] : {};

    /// ============================
    /// DOCUMENT HANDLING
    /// ============================
    String? aUrl, pUrl, lUrl, bUrl, pbUrl, phUrl;
    String? aNum, pNum, bNum, lNum;
    DateTime? bExp, lExp;

    if (data['documents'] is List) {
      for (var doc in data['documents']) {
        final String type = (doc['document_type']?.toString() ?? doc['type']?.toString() ?? '').toLowerCase().trim();
        final String? path = doc['view_url'] ?? doc['document_path'] ?? doc['path'];
        final String? number = doc['document_number']?.toString() ?? doc['number']?.toString();
        final dynamic expiry = doc['expiry_date'];

        if (type == 'aadhar') { 
          aUrl = AppConstants.getFileUrl(path); 
          if (number != null && number.isNotEmpty) aNum = number; 
        }
        else if (type == 'pan') { 
          pUrl = AppConstants.getFileUrl(path); 
          if (number != null && number.isNotEmpty) pNum = number; 
        }
        else if (type == 'license' || type == 'dl') { 
          lUrl = AppConstants.getFileUrl(path); 
          if (number != null && number.isNotEmpty) lNum = number;
          if (expiry != null) lExp = _parseDate(expiry);
        }
        else if (type == 'badge') { 
          bUrl = AppConstants.getFileUrl(path); 
          if (number != null && number.isNotEmpty) bNum = number;
          if (expiry != null) bExp = _parseDate(expiry);
        }
        else if (type == 'bank_passbook' || type == 'passbook') { 
          pbUrl = AppConstants.getFileUrl(path); 
        }
        else if (type == 'photo' || type == 'profile_photo') { 
          phUrl = AppConstants.getFileUrl(path); 
        }
      }
    }

    return StaffModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      roleId: rId,
      roleName: rName,
      role: _mapRole(rName),
      licenseNumber: (data['license'] is Map ? data['license']['number']?.toString() : null) ?? 
                    data['license_number']?.toString() ?? 
                    data['license_no']?.toString() ?? 
                    data['dl_number']?.toString() ?? 
                    lNum ?? 
                    (data['license'] is String ? data['license'] : null),
      licenseExpiry: _parseDate(licenseMap['expiry'] ?? data['license_expiry'] ?? data['dl_expiry'] ?? data['license_expiry_date']) ?? lExp,
      licenseType: licenseMap['type']?.toString() ?? data['license_type']?.toString(),
      assignedVehicleNumber: data['assigned_vehicle'] is Map ? data['assigned_vehicle']['registration_number']?.toString() : data['assigned_vehicle']?.toString(),
      status: data['is_active'] == true || data['is_active'] == 1 ? StaffStatus.active : StaffStatus.inactive,
      photoUrl: phUrl ?? AppConstants.getFileUrl(data['photo_url'] ?? data['photo_file'] ?? data['photo']),
      dob: _parseDate(data['date_of_birth'] ?? data['dob']),
      joiningDate: _parseDate(data['date_of_joining']),
      aadharNumber: aNum ?? data['aadhar_number']?.toString(),
      panNumber: pNum ?? data['pan_number']?.toString(),
      badgeNumber: bNum ?? badgeMap['number']?.toString() ?? data['badge_number']?.toString(),
      badgeExpiry: bExp ?? _parseDate(badgeMap['expiry'] ?? data['badge_expiry']),
      aadharUrl: aUrl ?? AppConstants.getFileUrl(data['aadhar_url'] ?? data['aadhar_file']),
      panUrl: pUrl ?? AppConstants.getFileUrl(data['pan_url'] ?? data['pan_file']),
      licenseUrl: lUrl ?? AppConstants.getFileUrl(data['license_url'] ?? data['dl_file'] ?? data['license_file']),
      badgeUrl: bUrl ?? AppConstants.getFileUrl(data['badge_url'] ?? data['badge_file']),
      bankPassbookUrl: pbUrl ?? AppConstants.getFileUrl(data['bank_passbook_url'] ?? data['passbook_file'] ?? data['bank_passbook']),
      salary: double.tryParse(data['basic_salary']?.toString() ?? salaryMap['basic_salary']?.toString() ?? '0') ?? 0.0,
      daPerDay: double.tryParse(salaryMap['da_per_day']?.toString() ?? data['da_per_day']?.toString() ?? '0'),
      hra: double.tryParse(salaryMap['hra']?.toString() ?? data['hra']?.toString() ?? '0'),
      otherAllowance: double.tryParse(salaryMap['other_allowance']?.toString() ?? data['other_allowance']?.toString() ?? '0'),
      salaryType: (data['salary_type']?.toString().toLowerCase() == 'daily') ? SalaryType.daily : SalaryType.monthly,
      bankName: bankMap['bank_name']?.toString() ?? data['bank_name']?.toString(),
      bankAccount: bankMap['bank_account']?.toString() ?? data['bank_account']?.toString(),
      bankIfsc: bankMap['bank_ifsc']?.toString() ?? data['bank_ifsc']?.toString(),
      emergencyContactName: data['emergency_contact_name']?.toString(),
      emergencyContact: data['emergency_contact']?.toString(),
      shift: sId,
      shiftId: sId,
      shiftName: sName,
      totalTrips: data['total_trips'] ?? 0,
      dutyHours: double.tryParse(data['total_duty_hours']?.toString() ?? '0') ?? 0.0,
      salaryBalance: double.tryParse(outerData['pending_da']?.toString() ?? data['salary_balance']?.toString() ?? '0') ?? 0.0,
      advanceTaken: double.tryParse(outerData['pending_advance']?.toString() ?? data['advance_taken']?.toString() ?? '0') ?? 0.0,
      isAvailable: data['is_available'] == true || data['is_available'] == 1,
      notes: data['notes']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;
    try {
      final str = dateStr.toString();
      // Handle ISO 8601 (contains T)
      if (str.contains('T')) {
        return DateTime.parse(str);
      }
      // Handle DD-MM-YYYY
      if (str.contains('-') && str.split('-').first.length <= 2) {
        final parts = str.split('-');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }
      // Handle YYYY-MM-DD
      return DateTime.tryParse(str);
    } catch (_) {
      return null;
    }
  }

  static StaffRole _mapRole(String? roleName) {
    if (roleName == null) return StaffRole.helper;
    switch (roleName.toLowerCase()) {
      case "driver": return StaffRole.driver;
      case "manager": return StaffRole.manager;
      case "accountant": return StaffRole.accountant;
      default: return StaffRole.helper;
    }
  }
}

class DutyHoursModel {
  final DutyHoursSummary summary;
  final List<DutyLog> logs;

  DutyHoursModel({required this.summary, required this.logs});

  factory DutyHoursModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final summaryData = data['summary'] ?? {};
    final logsData = data['logs'] as List? ?? [];

    return DutyHoursModel(
      summary: DutyHoursSummary.fromJson(summaryData),
      logs: logsData.map((e) => DutyLog.fromJson(e)).toList(),
    );
  }
}

class DutyHoursSummary {
  final double today;
  final double weekly;
  final double monthly;

  DutyHoursSummary({
    required this.today,
    required this.weekly,
    required this.monthly,
  });

  factory DutyHoursSummary.fromJson(Map<String, dynamic> json) {
    return DutyHoursSummary(
      today: double.tryParse(json['today']?.toString() ?? '0') ?? 0.0,
      weekly: double.tryParse(json['weekly']?.toString() ?? '0') ?? 0.0,
      monthly: double.tryParse(json['monthly']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class DutyLog {
  final DateTime date;
  final String status;
  final String inTime;
  final String outTime;
  final String totalHours;
  final String? notes;

  DutyLog({
    required this.date,
    required this.status,
    required this.inTime,
    required this.outTime,
    required this.totalHours,
    this.notes,
  });

  factory DutyLog.fromJson(Map<String, dynamic> json) {
    return DutyLog(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
      inTime: json['in_time'] ?? '',
      outTime: json['out_time'] ?? '',
      totalHours: json['total_hours']?.toString() ?? '0.0',
      notes: json['notes'],
    );
  }
}


class PerformanceReportModel {
  final double? overallScore;
  final Map<String, dynamic> efficiencyMetrics;
  final List<MonthlyTripHistory> monthlyTripHistory;
  final List<dynamic> recentFeedback;

  PerformanceReportModel({
    this.overallScore,
    required this.efficiencyMetrics,
    required this.monthlyTripHistory,
    required this.recentFeedback,
  });

  factory PerformanceReportModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return PerformanceReportModel(
      overallScore: data['overall_score'] != null ? double.tryParse(data['overall_score'].toString()) : null,
      efficiencyMetrics: data['efficiency_metrics'] ?? {},
      monthlyTripHistory: (data['monthly_trip_history'] as List? ?? [])
          .map((e) => MonthlyTripHistory.fromJson(e))
          .toList(),
      recentFeedback: data['recent_feedback'] ?? [],
    );
  }
}

class MonthlyTripHistory {
  final String month;
  final int trips;

  MonthlyTripHistory({required this.month, required this.trips});

  factory MonthlyTripHistory.fromJson(Map<String, dynamic> json) {
    return MonthlyTripHistory(
      month: json['month'] ?? '',
      trips: json['trips'] ?? 0,
    );
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
  final int id;
  final String month;
  final int year;
  final double basicSalary;
  final double netSalary;
  final double totalDeduction;
  final String paymentStatus;
  final String? paymentMode;
  final DateTime? paidOn;
  final String? transactionRef;

  SalaryRecord({
    required this.id,
    required this.month,
    required this.year,
    required this.basicSalary,
    required this.netSalary,
    required this.totalDeduction,
    required this.paymentStatus,
    this.paymentMode,
    this.paidOn,
    this.transactionRef,
  });

  factory SalaryRecord.fromJson(Map<String, dynamic> json) {
    return SalaryRecord(
      id: json['id'] ?? 0,
      month: json['month']?.toString() ?? '',
      year: json['year'] ?? 0,
      basicSalary: double.tryParse(json['basic_salary']?.toString() ?? '0') ?? 0,
      netSalary: double.tryParse(json['net_salary']?.toString() ?? '0') ?? 0,
      totalDeduction: double.tryParse(json['total_deduction']?.toString() ?? '0') ?? 0,
      paymentStatus: json['payment_status'] ?? '',
      paymentMode: json['payment_mode'],
      paidOn: json['paid_on'] != null ? DateTime.tryParse(json['paid_on']) : null,
      transactionRef: json['transaction_ref'],
    );
  }
}

class SalarySummary {
  final double monthlySalary;
  final double totalPaid;
  final double totalPending;

  SalarySummary({
    required this.monthlySalary,
    required this.totalPaid,
    required this.totalPending,
  });

  factory SalarySummary.fromJson(Map<String, dynamic> json) {
    return SalarySummary(
      monthlySalary: double.tryParse(json['monthly_salary']?.toString() ?? '0') ?? 0,
      totalPaid: double.tryParse(json['total_paid']?.toString() ?? '0') ?? 0,
      totalPending: double.tryParse(json['total_pending']?.toString() ?? '0') ?? 0,
    );
  }
}

class StaffSalaryHistoryModel {
  final SalarySummary summary;
  final List<SalaryRecord> records;

  StaffSalaryHistoryModel({
    required this.summary,
    required this.records,
  });

  factory StaffSalaryHistoryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final summaryData = data['summary'] ?? {};
    final recordsData = data['financial_history']?['data'] as List? ?? [];

    return StaffSalaryHistoryModel(
      summary: SalarySummary.fromJson(summaryData),
      records: recordsData.map((e) => SalaryRecord.fromJson(e)).toList(),
    );
  }
}

class AdvancePayment {
  final int id;
  final double amount;
  final String reason;
  final DateTime date;
  final String staffName;
  final String? paymentMode;

  AdvancePayment({
    required this.id,
    required this.amount,
    required this.reason,
    required this.date,
    required this.staffName,
    this.paymentMode,
  });

  factory AdvancePayment.fromJson(Map<String, dynamic> json) {
    return AdvancePayment(
      id: json['id'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      reason: json['reason'] ?? '',
      date: DateTime.tryParse(json['advance_date'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      staffName: json['staff']?['name'] ?? '',
      paymentMode: json['payment_mode'],
    );
  }
}

class StaffAdvanceHistoryModel {
  final double totalAdvance;
  final double pendingAmount;
  final List<AdvancePayment> advances;

  StaffAdvanceHistoryModel({
    required this.totalAdvance,
    required this.pendingAmount,
    required this.advances,
  });

  factory StaffAdvanceHistoryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final advancesData = data['advances']?['data'] as List? ?? [];
    
    return StaffAdvanceHistoryModel(
      totalAdvance: double.tryParse(data['total_advance']?.toString() ?? '0') ?? 0,
      pendingAmount: double.tryParse(data['pending_amount']?.toString() ?? '0') ?? 0,
      advances: advancesData.map((e) => AdvancePayment.fromJson(e)).toList(),
    );
  }
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
        if (parts.length == 3) {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }
      return DateTime.tryParse(str);
    } catch (_) {
      return null;
    }
  }
}