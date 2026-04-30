class StockTransactionModel {
  final int id;
  final int inventoryId;
  final String transactionType; // 'stock_in' or 'stock_out'
  final double quantity;
  final double stockBefore;
  final double stockAfter;
  final double unitPrice;
  final double totalPrice;
  final String? vendorName;
  final String? invoiceNumber;
  final String transactionDate;
  final String? reason;

  StockTransactionModel({
    required this.id,
    required this.inventoryId,
    required this.transactionType,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.unitPrice,
    required this.totalPrice,
    this.vendorName,
    this.invoiceNumber,
    required this.transactionDate,
    this.reason,
  });

  factory StockTransactionModel.fromJson(Map<String, dynamic> json) {
    return StockTransactionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      inventoryId: json['inventory_id'] is int ? json['inventory_id'] : int.tryParse(json['inventory_id']?.toString() ?? '0') ?? 0,
      transactionType: json['transaction_type']?.toString() ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      stockBefore: double.tryParse(json['stock_before']?.toString() ?? '0') ?? 0.0,
      stockAfter: double.tryParse(json['stock_after']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      vendorName: json['vendor_name']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      transactionDate: json['transaction_date']?.toString() ?? '',
      reason: json['reason']?.toString(),
    );
  }
}
