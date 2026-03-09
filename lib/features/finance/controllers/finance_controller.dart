import 'package:get/get.dart';
import '../domain/models/transaction_model.dart';

class FinanceController extends GetxController {
  final RxList<TransactionModel> _transactions = <TransactionModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  List<TransactionModel> get transactions => _transactions;

  List<TransactionModel> get filteredTransactions {
    if (searchQuery.value.isEmpty && selectedFilter.value == 'All') {
      return _transactions;
    }
    return _transactions.where((t) {
      final matchesSearch = t.category.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (t.description?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
          (t.referenceNo?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      
      final matchesFilter = selectedFilter.value == 'All' || 
          (selectedFilter.value == 'Income' && t.type == 'income') ||
          (selectedFilter.value == 'Expense' && t.type == 'expense');
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void updateSearch(String query) => searchQuery.value = query;
  void setFilter(String filter) => selectedFilter.value = filter;

  final _totalIncome = 0.0.obs;
  double get totalIncome => _totalIncome.value;

  final _totalExpense = 0.0.obs;
  double get totalExpense => _totalExpense.value;

  double get currentBalance => _totalIncome.value - _totalExpense.value;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    _transactions.assignAll([
      TransactionModel(
        id: 'T001',
        type: 'income',
        category: 'Corporate Payment',
        amount: 150000.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'TCS Monthly Contract Payment',
        paymentMethod: 'Bank Transfer',
        referenceNo: 'COMP001',
      ),
      TransactionModel(
        id: 'T002',
        type: 'expense',
        category: 'Fuel',
        amount: 5000.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Diesel for MH 12 AB 1234',
        paymentMethod: 'UPI',
        referenceNo: 'V001',
      ),
      TransactionModel(
        id: 'T003',
        type: 'expense',
        category: 'Maintenance',
        amount: 12000.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Regular Servicing',
        paymentMethod: 'Cash',
        referenceNo: 'V002',
      ),
      TransactionModel(
        id: 'T004',
        type: 'income',
        category: 'Trip Advance',
        amount: 25000.0,
        date: DateTime.now().subtract(const Duration(days: 4)),
        description: 'Advance for Mumbai Trip',
        paymentMethod: 'Cash',
        referenceNo: 'TRP012',
      ),
    ]);
    _calculateTotals();
  }

  void _calculateTotals() {
    double inc = 0.0;
    double exp = 0.0;
    for (var t in _transactions) {
      if (t.type == 'income') inc += t.amount;
      if (t.type == 'expense') exp += t.amount;
    }
    _totalIncome.value = inc;
    _totalExpense.value = exp;
  }
}
