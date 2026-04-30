import 'package:get/get.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/transaction_model.dart';
import '../domain/models/transaction_request_model.dart';
import '../domain/services/finance_service.dart';

class FinanceController extends GetxController {
  final GetFinanceDataUseCase _getFinanceDataUseCase;
  final GetTransactionByIdUseCase _getTransactionByIdUseCase;
  final AddTransactionUseCase _addTransactionUseCase;

  FinanceController({
    required GetFinanceDataUseCase getFinanceDataUseCase,
    required GetTransactionByIdUseCase getTransactionByIdUseCase,
    required AddTransactionUseCase addTransactionUseCase,
  }) : _getFinanceDataUseCase = getFinanceDataUseCase,
       _getTransactionByIdUseCase = getTransactionByIdUseCase,
       _addTransactionUseCase = addTransactionUseCase;

  // Observable state
  final RxList<TransactionModel> _transactions = <TransactionModel>[].obs;
  final Rx<TransactionModel?> currentTransaction = Rx<TransactionModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString selectedCategory = 'All'.obs;

  // Finance summary
  final Rx<FinanceSummary?> _summary = Rx<FinanceSummary?>(null);
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxBool hasNextPage = false.obs;
  final RxBool hasPrevPage = false.obs;

  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get recentTransactions => _transactions.take(5).toList();

  FinanceSummary? get summary => _summary.value;
  double get totalIncome => _summary.value?.totalIn ?? 0.0;
  double get totalExpense => _summary.value?.totalOut ?? 0.0;
  double get currentBalance => _summary.value?.currentBalance ?? 0.0;

  List<TransactionModel> get filteredTransactions {
    List<TransactionModel> filtered = List.from(_transactions);

    // Filter by type
    if (selectedFilter.value != 'All') {
      filtered = filtered.where((t) => 
        t.entryType.toLowerCase() == selectedFilter.value.toLowerCase()
      ).toList();
    }

    // Filter by category
    if (selectedCategory.value != 'All') {
      filtered = filtered.where((t) => 
        t.category.toLowerCase() == selectedCategory.value.toLowerCase()
      ).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((t) {
        final query = searchQuery.value.toLowerCase();
        return t.displayCategory.toLowerCase().contains(query) ||
               t.description.toLowerCase().contains(query) ||
               (t.referenceNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    loadFinanceData();
  }

  // Load finance data
  Future<void> loadFinanceData({
    int page = 1,
    int perPage = 10,
    bool isRefresh = false,
  }) async {
    try {
      if (isRefresh || page == 1) {
        isLoading.value = true;
      }

      print('Loading finance data - Page: $page, Per Page: $perPage');

      final response = await _getFinanceDataUseCase.call(
        page: page,
        perPage: perPage,
        type: selectedFilter.value != 'All' ? selectedFilter.value : null,
        category: selectedCategory.value != 'All' ? selectedCategory.value : null,
      );

      if (response.isSuccess && response.body != null) {
        final financeResponse = response.body as FinanceResponse;
        
        // Update summary
        _summary.value = financeResponse.summary;
        
        // Update transactions
        if (page == 1 || isRefresh) {
          _transactions.assignAll(financeResponse.transactions);
        } else {
          _transactions.addAll(financeResponse.transactions);
        }
        
        // Update pagination
        currentPage.value = financeResponse.meta.currentPage;
        totalPages.value = financeResponse.meta.lastPage;
        totalItems.value = financeResponse.meta.total;
        hasNextPage.value = financeResponse.meta.hasNextPage;
        hasPrevPage.value = financeResponse.meta.hasPrevPage;

        print('Successfully loaded finance data:');
        print('- Balance: ${currentBalance}');
        print('- Transactions: ${_transactions.length}');
        print('- Page: ${currentPage.value} of ${totalPages.value}');
      } else {
        print('Failed to load finance data: ${response.message}');
        if (page == 1) {
          _transactions.clear();
          _summary.value = null;
        }
      }
    } catch (e) {
      print('Error loading finance data: $e');
      if (page == 1) {
        _transactions.clear();
        _summary.value = null;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Load more data (pagination)
  Future<void> loadMoreData() async {
    if (hasNextPage.value && !isLoading.value) {
      await loadFinanceData(
        page: currentPage.value + 1,
        perPage: 10,
      );
    }
  }

  // Refresh data
  Future<void> refreshFinanceData() async {
    currentPage.value = 1;
    await loadFinanceData(page: 1, perPage: 10, isRefresh: true);
  }

  // Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // Set filter
  void setFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      currentPage.value = 1;
      loadFinanceData(page: 1, perPage: 10, isRefresh: true);
    }
  }

  // Set category filter
  void setCategoryFilter(String category) {
    if (selectedCategory.value != category) {
      selectedCategory.value = category;
      currentPage.value = 1;
      loadFinanceData(page: 1, perPage: 10, isRefresh: true);
    }
  }

  // Get available categories
  List<String> get availableCategories {
    final categories = _transactions
        .map((t) => t.displayCategory)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  Future<void> fetchTransactionDetails(int id) async {
    try {
      isDetailsLoading.value = true;
      currentTransaction.value = null; // reset before loading
      final response = await _getTransactionByIdUseCase.call(id);
      
      if (response.isSuccess && response.body != null) {
        // the body is the "data" object of the API response
        final transactionJson = response.body is Map<String, dynamic> 
            ? response.body as Map<String, dynamic> 
            : null;
            
        if (transactionJson != null) {
          currentTransaction.value = TransactionModel.fromJson(transactionJson);
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
      CustomSnackbar.showError('Error fetching transaction details');
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<bool> saveTransaction(TransactionRequestModel request) async {
    try {
      isLoading.value = true;
      final response = await _addTransactionUseCase.call(request);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Transaction added successfully');
        await refreshFinanceData();
        Get.back();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      print('Error saving transaction: $e');
      CustomSnackbar.showError('Failed to save transaction');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
