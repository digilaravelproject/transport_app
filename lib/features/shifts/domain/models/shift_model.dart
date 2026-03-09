class ShiftModel {
  final String id;
  final String shiftName; // e.g., 'Morning A', 'Night B', 'Full Day Extra'
  final String startTime; // e.g., '06:00 AM'
  final String endTime; // e.g., '02:00 PM'
  final String type; // 'Regular', 'Overtime', 'Special Duty'
  final List<String> assignedDrivers; // List of driver names or IDs
  final String? notes;
  final DateTime date;

  ShiftModel({
    required this.id,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.assignedDrivers,
    required this.date,
    this.notes,
  });
}
