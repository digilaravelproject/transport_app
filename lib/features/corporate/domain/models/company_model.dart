class CompanyModel {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final int activeContracts;

  CompanyModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.activeContracts,
  });
}
