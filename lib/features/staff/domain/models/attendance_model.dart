class AttendanceModel {
  final int id;
  final String name;
  final String phone;
  final String staffType;
  final AttendanceDetails? attendance;

  AttendanceModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.staffType,
    this.attendance,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      staffType: json['staff_type'] ?? '',
      attendance: json['attendance'] != null 
          ? AttendanceDetails.fromJson(json['attendance']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'staff_type': staffType,
      'attendance': attendance?.toJson(),
    };
  }

  String get displayStatus {
    if (attendance == null) return 'Not Marked';
    return attendance!.status.capitalizeFirst ?? 'Not Marked';
  }

  String get displayRole {
    return staffType.capitalizeFirst ?? '';
  }
}

class AttendanceDetails {
  final String status;
  final String? inTime;
  final String? outTime;
  final String? totalHours;

  AttendanceDetails({
    required this.status,
    this.inTime,
    this.outTime,
    this.totalHours,
  });

  factory AttendanceDetails.fromJson(Map<String, dynamic> json) {
    return AttendanceDetails(
      status: json['status'] ?? '',
      inTime: json['in_time'],
      outTime: json['out_time'],
      totalHours: json['total_hours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'in_time': inTime,
      'out_time': outTime,
      'total_hours': totalHours,
    };
  }

  String get displayStatus {
    return status.capitalizeFirst ?? '';
  }
}

extension StringExtension on String {
  String? get capitalizeFirst {
    if (isEmpty) return null;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
