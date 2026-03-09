import 'package:get/get.dart';
import '../domain/models/company_model.dart';

class CorporateController extends GetxController {
  final RxList<CompanyModel> _companies = <CompanyModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  List<CompanyModel> get companies => _companies;

  List<CompanyModel> get filteredCompanies {
    if (searchQuery.value.isEmpty && selectedFilter.value == 'All') {
      return _companies;
    }
    return _companies.where((company) {
      final matchesSearch = company.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          company.contactPerson.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      bool matchesFilter = true;
      if (selectedFilter.value == 'Active') matchesFilter = company.activeContracts > 0;
      if (selectedFilter.value == 'No Contracts') matchesFilter = company.activeContracts == 0;
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void updateSearch(String query) => searchQuery.value = query;
  void setFilter(String filter) => selectedFilter.value = filter;

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
      ),
      CompanyModel(
        id: 'COMP003',
        name: 'Wipro',
        contactPerson: 'Karan Singh',
        phone: '9988776655',
        email: 'karan.singh@wipro.com',
        activeContracts: 0,
      ),
    ]);
  }
}
