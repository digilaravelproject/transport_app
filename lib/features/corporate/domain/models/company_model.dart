class CompanyModel {
  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? contractNumber;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? dutyType;
  final String? vehicleType;
  final int quantity;
  final String? monthlyAmount;
  final String? notes;
  final bool isActive;

  CompanyModel({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.contractNumber,
    this.status,
    this.startDate,
    this.endDate,
    this.dutyType,
    this.vehicleType,
    this.quantity = 0,
    this.monthlyAmount,
    this.notes,
    this.isActive = true,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id']?.toString() ?? '',
      name: json['vendor_name'] ?? json['name'] ?? 'Unknown',
      contactPerson: json['contact_person'] ?? json['contract_name'],
      phone: json['contact_number'] ?? json['phone'],
      email: json['email'],
      contractNumber: json['contact_number'],
      status: json['status']?.toString(),
      startDate: json['start_date'],
      endDate: json['end_date'],
      dutyType: json['duty_type'],
      vehicleType: json['vehicle_type'],
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      monthlyAmount: json['monthly_amount']?.toString(),
      notes: json['notes'],
      isActive: json['status'] == 1 || json['status'] == '1' || json['isActive'] == true || json['status'] == true,
    );
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? contractNumber,
    String? status,
    String? startDate,
    String? endDate,
    String? dutyType,
    String? vehicleType,
    int? quantity,
    String? monthlyAmount,
    String? notes,
    bool? isActive,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      contractNumber: contractNumber ?? this.contractNumber,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dutyType: dutyType ?? this.dutyType,
      vehicleType: vehicleType ?? this.vehicleType,
      quantity: quantity ?? this.quantity,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}

class InvoiceModel {
  final String invNo;
  final String amount;
  final String status;
  final String date;

  InvoiceModel({
    required this.invNo,
    required this.amount,
    required this.status,
    required this.date,
  });
}
