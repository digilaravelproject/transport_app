class TransactionModel {
  final String id;
  final String type; // 'income' or 'expense'
  final String category; // 'Trip Advance', 'Fuel', 'Salary', 'Corporate Payment', etc.
  final double amount;
  final DateTime date;
  final String description;
  final String paymentMethod; // 'Cash', 'Bank Transfer', 'UPI', etc.
  final String? referenceNo; // e.g., trip ID, vehicle ID, staff ID

  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.paymentMethod,
    this.referenceNo,
  });
}
