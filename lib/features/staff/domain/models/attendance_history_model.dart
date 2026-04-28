class AttendanceHistoryModel {
  final int id;
  final String name;
  final String phone;
  final String staffType;
  final List<AttendanceHistoryRecord> attendance;

  AttendanceHistoryModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.staffType,
    required this.attendance,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      staffType: json['staff_type'] ?? '',
      attendance: (json['attendance'] as List<dynamic>?)
              ?.map((e) => AttendanceHistoryRecord.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'staff_type': staffType,
      'attendance': attendance.map((e) => e.toJson()).toList(),
    };
  }

  String get displayRole {
    return staffType.capitalizeFirst ?? '';
  }
}

class AttendanceHistoryRecord {
  final DateTime date;
  final String status;
  final String? inTime;
  final String? outTime;
  final String? totalHours;

  AttendanceHistoryRecord({
    required this.date,
    required this.status,
    this.inTime,
    this.outTime,
    this.totalHours,
  });

  factory AttendanceHistoryRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryRecord(
      date: DateTime.parse(json['date']),
      status: json['status'] ?? '',
      inTime: json['in_time'],
      outTime: json['out_time'],
      totalHours: json['total_hours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'status': status,
      'in_time': inTime,
      'out_time': outTime,
      'total_hours': totalHours,
    };
  }

  String get displayStatus {
    return status.capitalizeFirst ?? '';
  }

  String get displayTotalHours {
    if (totalHours == null) return '0h';
    final hours = double.tryParse(totalHours!) ?? 0.0;
    return '${hours.toStringAsFixed(1)}h';
  }
}

extension StringExtension on String {
  String? get capitalizeFirst {
    if (isEmpty) return null;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
