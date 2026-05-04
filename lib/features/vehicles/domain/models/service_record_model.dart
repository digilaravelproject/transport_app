import '../../../../core/constants/app_constants.dart';

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

  factory PaymentLog.fromJson(Map<String, dynamic> json) {
    return PaymentLog(
      date: DateTime.tryParse(json['paid_at'] ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      note: json['notes'],
      receiptUrl: AppConstants.getFileUrl(json['receipt_path']),
    );
  }
}

class ServiceRecord {
  final int id; 
  final DateTime date;
  final String type;
  final double totalBill;
  final double paidAmount;
  final String workshop;
  final String? billUrl;
  final String? kmReading;
  final List<PaymentLog> payments;

  ServiceRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.totalBill,
    required this.paidAmount,
    required this.workshop,
    this.billUrl,
    this.kmReading,
    this.payments = const [],
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    final double total = double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0;
    final double paid = double.tryParse(json['amount_paid']?.toString() ?? '0') ?? 0.0;

    final dynamic metaData = json['meta'];
    final Map<String, dynamic> meta = (metaData is Map) ? Map<String, dynamic>.from(metaData) : {};
    final List<dynamic> paymentsList = meta['payments'] ?? [];
    final List<PaymentLog> payments = paymentsList.map((e) => PaymentLog.fromJson(e)).toList();

    return ServiceRecord(
      id: json['id'] ?? 0,
      date: DateTime.tryParse(json['activity_date'] ?? '') ?? DateTime.now(),
      type: json['title'] ?? json['activity_type'] ?? 'Service',
      totalBill: total,
      paidAmount: paid,
      workshop: json['workshop_name'] ?? json['garage_name'] ?? 'Unknown Workshop',
      billUrl: AppConstants.getFileUrl(json['receipt_path']),
      kmReading: json['km_reading']?.toString(),
      payments: payments,
    );
  }

  double get pendingAmount => totalBill - paidAmount;
  double get cost => totalBill;
  bool get isFullPaid => pendingAmount <= 0;

  ServiceRecord copyWith({
    double? paidAmount,
    String? kmReading,
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
      kmReading: kmReading ?? this.kmReading,
      payments: payments ?? this.payments,
    );
  }
}
