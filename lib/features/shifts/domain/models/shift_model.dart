class ShiftModel {
  final int? id;
  final String name;
 // final String? description;
  final String startTime;
  final String endTime;
  final String? formattedTimeRange;
  final String type;
  final String? date;
  //final int? durationHours;
 // final List<dynamic>? days;
 // final List<String>? dayNames;
  final bool? isActive;
 // final int? maxDrivers;
  //final double? hourlyRate;
  final String? notes;
  final int? driversCount;
  final List<DriverModel>? drivers;
  final String? createdAt;
  final String? updatedAt;



  ShiftModel({
    this.id,
    required this.name,
  //  this.description,
    required this.startTime,
    required this.endTime,
    this.formattedTimeRange,
    required this.type,
    this.date,
   // this.durationHours,
  //  this.days,
 //   this.dayNames,
    this.isActive,
 //   this.maxDrivers,
 //   this.hourlyRate,
    this.notes,
    this.driversCount,
    this.drivers,
    this.createdAt,
    this.updatedAt,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      name: json['name'] ?? '',
      //description: json['description'],
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      formattedTimeRange: json['formatted_time_range'],
      type: json['type'] ?? '',
      date: json['date'],
    //  durationHours: json['duration_hours'],
    //  days: json['days'],
   //   dayNames: json['day_names'] != null ? List<String>.from(json['day_names']) : null,
      isActive: json['is_active'],
 //     maxDrivers: json['max_drivers'],
  //    hourlyRate: json['hourly_rate'] != null ? double.tryParse(json['hourly_rate'].toString()) : null,
      notes: json['notes'],
      driversCount: json['drivers_count'],
      drivers: json['drivers'] != null
          ? (json['drivers'] as List<dynamic>)
              .map((driver) => DriverModel.fromJson(driver as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'type': type,
      'notes': notes,
    };
  }
}

class DriverModel {
  final int? id;
  final int? tenantId;
  final int? userId;
  final String name;
  final String? phone;
  final String? email;
  final String? dateOfBirth;
  final String? dateOfJoining;
  final String? address;
  final String? emergencyContact;
  final String? emergencyContactName;
  final String? staffType;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? licenseType;
  final String? basicSalary;
  final String? daPerDay;
  final String? hra;
  final String? otherAllowance;
  final String? bankName;
  final String? bankAccount;
  final String? bankIfsc;
  final String? notes;
  final bool? isAvailable;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  DriverModel({
    this.id,
    this.tenantId,
    this.userId,
    required this.name,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.dateOfJoining,
    this.address,
    this.emergencyContact,
    this.emergencyContactName,
    this.staffType,
    this.licenseNumber,
    this.licenseExpiry,
    this.licenseType,
    this.basicSalary,
    this.daPerDay,
    this.hra,
    this.otherAllowance,
    this.bankName,
    this.bankAccount,
    this.bankIfsc,
    this.notes,
    this.isAvailable,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      dateOfBirth: json['date_of_birth'],
      dateOfJoining: json['date_of_joining'],
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      emergencyContactName: json['emergency_contact_name'],
      staffType: json['staff_type'],
      licenseNumber: json['license_number'],
      licenseExpiry: json['license_expiry'],
      licenseType: json['license_type'],
      basicSalary: json['basic_salary']?.toString(),
      daPerDay: json['da_per_day']?.toString(),
      hra: json['hra']?.toString(),
      otherAllowance: json['other_allowance']?.toString(),
      bankName: json['bank_name'],
      bankAccount: json['bank_account'],
      bankIfsc: json['bank_ifsc'],
      notes: json['notes'],
      isAvailable: json['is_available'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'date_of_birth': dateOfBirth,
      'date_of_joining': dateOfJoining,
      'address': address,
      'emergency_contact': emergencyContact,
      'emergency_contact_name': emergencyContactName,
      'staff_type': staffType,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'license_type': licenseType,
      'basic_salary': basicSalary,
      'da_per_day': daPerDay,
      'hra': hra,
      'other_allowance': otherAllowance,
      'bank_name': bankName,
      'bank_account': bankAccount,
      'bank_ifsc': bankIfsc,
      'notes': notes,
      'is_available': isAvailable,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}
