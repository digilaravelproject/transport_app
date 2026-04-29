class TimelineRecord {
  final int id;
  final String activityType;
  final String title;
  final DateTime date;
  final double? amount;
  final double? quantity;
  final String? receiptPath;
  final String kind;

  TimelineRecord({
    required this.id,
    required this.activityType,
    required this.title,
    required this.date,
    this.amount,
    this.quantity,
    this.receiptPath,
    required this.kind,
  });

  factory TimelineRecord.fromJson(Map<String, dynamic> json) {
    return TimelineRecord(
      id: json['id'] ?? 0,
      activityType: json['activity_type'] ?? '',
      title: json['title'] ?? (json['activity_type'] == 'fuel' ? 'Fuel Refill' : 'Activity'),
      date: DateTime.tryParse(json['activity_date'] ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '0'),
      receiptPath: json['receipt_path'],
      kind: json['kind'] ?? 'activity',
    );
  }
}
