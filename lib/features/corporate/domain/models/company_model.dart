/*class CompanyModel {
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
}*/





class CompanyModel {
  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;

  final String? contractName;
  final String? status;

  final DateTime? startDate;
  final DateTime? endDate;

  final String? dutyType;
  final String? vehicleType;
  final String? vehicleTypeName;

  final int quantity;
  final double monthlyAmount;

  final String? notes;
  final bool isActive;

  final List<VehicleModel> vehicles;
  final List<InvoiceModel> invoices;

  CompanyModel({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.contractName,
    this.status,
    this.startDate,
    this.endDate,
    this.dutyType,
    this.vehicleType,
    this.vehicleTypeName,
    this.quantity = 0,
    this.monthlyAmount = 0,
    this.notes,
    this.isActive = true,
    this.vehicles = const [],
    this.invoices = const [],
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] ?? json;

    return CompanyModel(
      id: vendor['id']?.toString() ?? '',
      name: vendor['vendor_name'] ?? 'Unknown',

      contactPerson: vendor['contract_name'],
      phone: vendor['contact_number'],
      email: vendor['email'],

      contractName: vendor['contract_name'],
      status: vendor['status']?.toString(),

      startDate: _parseDate(vendor['start_date']),
      endDate: _parseDate(vendor['end_date']),

      dutyType: vendor['duty_type'],

      vehicleType: vendor['vehicle_type']?.toString(),
      vehicleTypeName: vendor['vehicle_type_details']?['name'],

      quantity: vendor['quantity'] is int
          ? vendor['quantity']
          : int.tryParse(vendor['quantity']?.toString() ?? '0') ?? 0,

      monthlyAmount:
      double.tryParse(vendor['monthly_amount']?.toString() ?? '0') ?? 0,

      notes: vendor['notes'],

      isActive: vendor['status'] == 1 || vendor['status'] == true,

      vehicles: (json['assigned_vehicles'] as List? ?? [])
          .map((e) => VehicleModel.fromJson(e))
          .toList(),

      invoices: (json['billing_history'] as List? ?? [])
          .map((e) => InvoiceModel.fromJson(e))
          .toList(),
    );
  }

  static DateTime? _parseDate(String? date) {
    if (date == null || date.isEmpty) return null;
    return DateTime.tryParse(date);
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? contractName,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? dutyType,
    String? vehicleType,
    String? vehicleTypeName,
    int? quantity,
    double? monthlyAmount,
    String? notes,
    bool? isActive,
    List<VehicleModel>? vehicles,
    List<InvoiceModel>? invoices,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      contractName: contractName ?? this.contractName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dutyType: dutyType ?? this.dutyType,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleTypeName: vehicleTypeName ?? this.vehicleTypeName,
      quantity: quantity ?? this.quantity,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      vehicles: vehicles ?? this.vehicles,
      invoices: invoices ?? this.invoices,
    );
  }
}

/// ===============================
/// VEHICLE MODEL
/// ===============================
class VehicleModel {
  final String id;
  final String number;
  final String type;
  final int capacity;
  final int modelYear;
  final double perKmPrice;
  final bool isActive;

  VehicleModel({
    required this.id,
    required this.number,
    required this.type,
    this.capacity = 0,
    this.modelYear = 0,
    this.perKmPrice = 0,
    this.isActive = true,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      number: json['registration_number'] ?? '',
      type: json['type'] ?? '',
      capacity: json['seating_capacity'] ?? 0,
      modelYear: json['model_year'] ?? 0,
      perKmPrice:
      double.tryParse(json['per_km_price']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true,
    );
  }
}

/// ===============================
/// INVOICE MODEL
/// ===============================
class InvoiceModel {
  final String invNo;
  final double amount;
  final String status;
  final DateTime? date;
  final String? file;

  InvoiceModel({
    required this.invNo,
    required this.amount,
    required this.status,
    this.date,
    this.file,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invNo: json['invoice_number'] ?? '',
      amount:
      double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
      date: DateTime.tryParse(json['billing_date'] ?? ''),
      file: json['file_path'],
    );
  }
}
