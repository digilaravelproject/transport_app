class FuelEntryModel {
  final int? id;
  final int vehicleId;
  final String date;
  final double amount;
  final double quantity;
  final double pricePerUnit;
  final String stationName;
  final String? receiptPath;

  FuelEntryModel({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.amount,
    required this.quantity,
    required this.pricePerUnit,
    required this.stationName,
    this.receiptPath,
  });

  factory FuelEntryModel.fromJson(Map<String, dynamic> json) {
    return FuelEntryModel(
      id: json['id'],
      vehicleId: json['vehicle_id'] ?? 0,
      date: json['activity_date'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      pricePerUnit: double.tryParse(json['price_per_unit']?.toString() ?? '0') ?? 0.0,
      stationName: json['station_name'] ?? '',
      receiptPath: json['receipt_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_date': date,
      'amount': amount,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'station_name': stationName,
    };
  }
}
