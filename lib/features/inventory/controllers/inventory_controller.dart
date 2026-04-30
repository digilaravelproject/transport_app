import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models/inventory_model.dart';
import '../domain/models/inventory_item_request_model.dart';
import '../domain/models/stock_transaction_model.dart';
import '../domain/services/inventory_service.dart';
import '../../../core/utils/custom_snackbar.dart';

class InventoryController extends GetxController {
  final AddInventoryItemUseCase _addInventoryItemUseCase;
  final GetInventoryDataUseCase _getInventoryDataUseCase;
  final GetInventoryDetailsUseCase _getInventoryDetailsUseCase;
  final UpdateInventoryItemUseCase _updateInventoryItemUseCase;
  final DeleteInventoryItemUseCase _deleteInventoryItemUseCase;
  final StockInUseCase _stockInUseCase;
  final StockOutUseCase _stockOutUseCase;

  InventoryController({
    required AddInventoryItemUseCase addInventoryItemUseCase,
    required GetInventoryDataUseCase getInventoryDataUseCase,
    required GetInventoryDetailsUseCase getInventoryDetailsUseCase,
    required UpdateInventoryItemUseCase updateInventoryItemUseCase,
    required DeleteInventoryItemUseCase deleteInventoryItemUseCase,
    required StockInUseCase stockInUseCase,
    required StockOutUseCase stockOutUseCase,
  }) : _addInventoryItemUseCase = addInventoryItemUseCase,
       _getInventoryDataUseCase = getInventoryDataUseCase,
       _getInventoryDetailsUseCase = getInventoryDetailsUseCase,
       _updateInventoryItemUseCase = updateInventoryItemUseCase,
       _deleteInventoryItemUseCase = deleteInventoryItemUseCase,
       _stockInUseCase = stockInUseCase,
       _stockOutUseCase = stockOutUseCase;

  final RxList<InventoryModel> _items = <InventoryModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isDetailsLoading = false.obs;

  final Rxn<InventoryModel> currentItem = Rxn<InventoryModel>();
  final RxList<StockTransactionModel> recentTransactions = <StockTransactionModel>[].obs;
  
  int _currentPage = 1;
  final int _perPage = 10;
  bool _hasMore = true;

  final ScrollController scrollController = ScrollController();

  List<InventoryModel> get items => _items;
  bool get hasMore => _hasMore;

  List<InventoryModel> get filteredItems {
    if (searchQuery.value.isEmpty && selectedFilter.value == 'All') {
      return _items;
    }
    return _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          item.sku.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesFilter = selectedFilter.value == 'All' || item.category == selectedFilter.value;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void updateSearch(String query) => searchQuery.value = query;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchInventoryData(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && _hasMore) {
        fetchInventoryData(refresh: false);
      }
    }
  }

  void setFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      fetchInventoryData(refresh: true);
    }
  }

  Future<void> fetchInventoryData({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _items.clear();
      isLoading.value = true;
    } else {
      if (!_hasMore) return;
      isLoadingMore.value = true;
    }

    try {
      final response = await _getInventoryDataUseCase.call(
        page: _currentPage,
        perPage: _perPage,
        category: selectedFilter.value == 'All' ? null : selectedFilter.value,
      );

      if (response.isSuccess && response.body != null) {
        final List<dynamic> dataList = response.body['data'] ?? [];
        final List<InventoryModel> newItems = dataList.map((json) => InventoryModel.fromJson(json)).toList();

        if (refresh) {
          _items.assignAll(newItems);
        } else {
          _items.addAll(newItems);
        }

        final int totalPages = response.body['last_page'] ?? 1;
        _hasMore = _currentPage < totalPages;
        
        if (_hasMore) {
          _currentPage++;
        }
      } else {
        CustomSnackbar.showError('Failed to fetch inventory data');
      }
    } catch (e) {
      print('Error fetching inventory data: $e');
      if (refresh) {
        CustomSnackbar.showError('Error connecting to server');
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchInventoryDetails(int id) async {
    try {
      isDetailsLoading.value = true;
      currentItem.value = null;
      recentTransactions.clear();

      final response = await _getInventoryDetailsUseCase.call(id);

      if (response.isSuccess && response.body != null) {
        final inventoryData = response.body['inventory'];
        if (inventoryData != null) {
          currentItem.value = InventoryModel.fromJson(inventoryData);
        }

        final List<dynamic> stocksList = response.body['recent_stocks'] ?? [];
        recentTransactions.assignAll(
          stocksList.map((json) => StockTransactionModel.fromJson(json)).toList(),
        );
      } else {
        CustomSnackbar.showError('Failed to fetch item details');
      }
    } catch (e) {
      print('Error fetching inventory details: $e');
      CustomSnackbar.showError('Error connecting to server');
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<bool> saveItem(InventoryItemRequestModel request) async {
    try {
      isLoading.value = true;
      final response = await _addInventoryItemUseCase.call(request);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Item added to inventory successfully');
        fetchInventoryData(refresh: true);
        Get.back();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      print('Error saving inventory item: $e');
      CustomSnackbar.showError('Failed to save inventory item');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateItem(int id, InventoryItemRequestModel request) async {
    try {
      isLoading.value = true;
      final response = await _updateInventoryItemUseCase.call(id, request);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Inventory item updated successfully');
        fetchInventoryDetails(id); // Refresh details screen data
        fetchInventoryData(refresh: true); // Refresh list screen data
        Get.back();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      print('Error updating inventory item: $e');
      CustomSnackbar.showError('Failed to update inventory item');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      isLoading.value = true;
      final response = await _deleteInventoryItemUseCase.call(id);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Inventory item deleted successfully');
        fetchInventoryData(refresh: true);
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      print('Error deleting inventory item: $e');
      CustomSnackbar.showError('Failed to delete inventory item');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> stockIn(int id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _stockInUseCase.call(id, data);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Stock added successfully');
        fetchInventoryDetails(id); // Refresh details screen data
        fetchInventoryData(refresh: true); // Refresh list screen data
        Get.back();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      print('Error during stock-in: $e');
      CustomSnackbar.showError('Failed to add stock');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> stockOut(int id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await _stockOutUseCase.call(id, data);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Stock used/removed successfully');
        fetchInventoryDetails(id); // Refresh details screen data
        fetchInventoryData(refresh: true); // Refresh list screen data
        Get.back();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      print('Error during stock-out: $e');
      CustomSnackbar.showError('Failed to remove stock');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
