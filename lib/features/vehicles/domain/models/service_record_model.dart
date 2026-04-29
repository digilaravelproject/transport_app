class PaymentLog {
  final DateTime date;
  final double amount;
  final String? note;
  final String? receiptUrl;

  PaymentLog({
    required this.date,
    required this.amount,
    this.note,
    this.receiptUrl,
  });
}

class ServiceRecord {
  final int id; 
  final DateTime date;
  final String type;
  final double totalBill;
  final double paidAmount;
  final String workshop;
  final String? billUrl;
  final List<PaymentLog> payments;

  ServiceRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.totalBill,
    required this.paidAmount,
    required this.workshop,
    this.billUrl,
    this.payments = const [],
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      id: json['id'] ?? 0,
      date: DateTime.tryParse(json['activity_date'] ?? '') ?? DateTime.now(),
      type: json['title'] ?? json['activity_type'] ?? 'Service',
      totalBill: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(json['amount_paid']?.toString() ?? '0') ?? 
                 double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      workshop: json['workshop_name'] ?? 'Unknown Workshop',
      billUrl: json['receipt_path'],
    );
  }

  double get pendingAmount => totalBill - paidAmount;
  double get cost => totalBill;
  bool get isFullPaid => pendingAmount <= 0;

  ServiceRecord copyWith({
    double? paidAmount,
    List<PaymentLog>? payments,
  }) {
    return ServiceRecord(
      id: id,
      date: date,
      type: type,
      totalBill: totalBill,
      paidAmount: paidAmount ?? this.paidAmount,
      workshop: workshop,
      billUrl: billUrl,
      payments: payments ?? this.payments,
    );
  }
}
