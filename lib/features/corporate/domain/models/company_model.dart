class CompanyModel {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final int activeContracts;
  final bool isActive;

  CompanyModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.activeContracts,
    this.isActive = true,
  });
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
