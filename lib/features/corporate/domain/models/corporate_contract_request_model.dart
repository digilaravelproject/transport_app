class CorporateContractRequestModel {
  final String name;
  final String vendorName;
  final String contractNumber;
  final String startDate;
  final String endDate;
  final String dutyType;
  final String vehicleType;
  final int quantity;
  final double monthlyAmount;
  final String notes;

  CorporateContractRequestModel({
    required this.name,
    required this.vendorName,
    required this.contractNumber,
    required this.startDate,
    required this.endDate,
    required this.dutyType,
    required this.vehicleType,
    required this.quantity,
    required this.monthlyAmount,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'contract_name': name,
      'vendor_name': vendorName,
      'contact_number': contractNumber,
      'start_date': startDate,
      'end_date': endDate,
      'duty_type': dutyType,
      'vehicle_type': vehicleType,
      'quantity': quantity,
      'monthly_amount': monthlyAmount,
      'notes': notes,
    };
  }
}
