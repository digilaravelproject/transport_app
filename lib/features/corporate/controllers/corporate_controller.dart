import 'package:get/get.dart';
import '../domain/models/company_model.dart';

class CorporateController extends GetxController {
  final RxList<CompanyModel> _companies = <CompanyModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;

  List<CompanyModel> get companies => _companies;

  List<CompanyModel> get filteredCompanies {
    if (searchQuery.value.isEmpty && selectedFilter.value == 'All') {
      return _companies;
    }
    return _companies.where((company) {
      final matchesSearch = company.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          company.contactPerson.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      bool matchesFilter = true;
      if (selectedFilter.value == 'Active') matchesFilter = company.isActive;
      if (selectedFilter.value == 'No Contracts') matchesFilter = company.activeContracts == 0;
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void updateSearch(String query) => searchQuery.value = query;
  void setFilter(String filter) => selectedFilter.value = filter;

  void toggleCompanyStatus(String id) {
    final index = _companies.indexWhere((c) => c.id == id);
    if (index != -1) {
      final company = _companies[index];
      _companies[index] = CompanyModel(
        id: company.id,
        name: company.name,
        contactPerson: company.contactPerson,
        phone: company.phone,
        email: company.email,
        activeContracts: company.activeContracts,
        isActive: !company.isActive,
      );
      _companies.refresh();
    }
  }

  void toggleInvoiceStatus(String invNo) {
    final index = invoices.indexWhere((i) => i.invNo == invNo);
    if (index != -1) {
      final inv = invoices[index];
      invoices[index] = InvoiceModel(
        invNo: inv.invNo,
        amount: inv.amount,
        date: inv.date,
        status: inv.status == 'Paid' ? 'Pending' : 'Paid',
      );
      invoices.refresh();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadMockCompanies();
  }

  void _loadMockCompanies() {
    _companies.assignAll([
      CompanyModel(
        id: 'COMP001',
        name: 'TCS',
        contactPerson: 'Rahul Sharma',
        phone: '9876543210',
        email: 'rahul.sharma@tcs.com',
        activeContracts: 3,
      ),
      CompanyModel(
        id: 'COMP002',
        name: 'Infosys',
        contactPerson: 'Anita Desai',
        phone: '9123456780',
        email: 'adesai@infosys.com',
        activeContracts: 1,
        isActive: true,
      ),
      CompanyModel(
        id: 'COMP003',
        name: 'Wipro',
        contactPerson: 'Karan Singh',
        phone: '9988776655',
        email: 'karan.singh@wipro.com',
        activeContracts: 0,
        isActive: false,
      ),
    ]);

    invoices.assignAll([
      InvoiceModel(invNo: 'INV-2024-001', amount: '₹ 1,50,000', status: 'Paid', date: '01 Apr 2024'),
      InvoiceModel(invNo: 'INV-2024-012', amount: '₹ 1,50,000', status: 'Pending', date: '01 May 2024'),
    ]);
  }
}
