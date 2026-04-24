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
  final String name;
  final String? phone;
  final String? email;
  final String? staffType;
  final String? dateOfBirth;
  final String? dateOfJoining;
  final String? address;
  final String? emergencyContact;
  final String? emergencyContactName;
  final bool? isAvailable;
  final bool? isActive;
  final String? notes;

  DriverModel({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.staffType,
    this.dateOfBirth,
    this.dateOfJoining,
    this.address,
    this.emergencyContact,
    this.emergencyContactName,
    this.isAvailable,
    this.isActive,
    this.notes,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      staffType: json['staff_type'],
      dateOfBirth: json['date_of_birth'],
      dateOfJoining: json['date_of_joining'],
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      emergencyContactName: json['emergency_contact_name'],
      isAvailable: json['is_available'],
      isActive: json['is_active'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'staff_type': staffType,
    };
  }
}
