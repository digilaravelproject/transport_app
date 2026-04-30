class TransactionRequestModel {
  final String type;
  final double amount;
  final String entryDate;
  final String category;
  final String paymentMethod;
  final String? referenceNumber;
  final String description;

  TransactionRequestModel({
    required this.type,
    required this.amount,
    required this.entryDate,
    required this.category,
    required this.paymentMethod,
    this.referenceNumber,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type,
      'amount': amount,
      'entry_date': entryDate,
      'category': category,
      'payment_method': paymentMethod,
      'description': description,
    };
    
    if (referenceNumber != null && referenceNumber!.isNotEmpty) {
      data['reference_number'] = referenceNumber;
    }
    
    return data;
  }
}
