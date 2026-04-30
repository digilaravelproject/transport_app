import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models/stock_transaction_model.dart';
import '../domain/services/inventory_service.dart';
import '../../../core/utils/custom_snackbar.dart';

class InventoryStocksController extends GetxController {
  final GetInventoryStocksUseCase _getInventoryStocksUseCase;

  InventoryStocksController({
    required GetInventoryStocksUseCase getInventoryStocksUseCase,
  }) : _getInventoryStocksUseCase = getInventoryStocksUseCase;

  final RxList<StockTransactionModel> stocks = <StockTransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  int _currentPage = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  int? _inventoryId;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _inventoryId = Get.arguments as int?;
    scrollController.addListener(_onScroll);
    if (_inventoryId != null) {
      fetchStocks(refresh: true);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && _hasMore) {
        fetchStocks(refresh: false);
      }
    }
  }

  Future<void> fetchStocks({bool refresh = false}) async {
    if (_inventoryId == null) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      stocks.clear();
      isLoading.value = true;
    } else {
      if (!_hasMore) return;
      isLoadingMore.value = true;
    }

    try {
      final response = await _getInventoryStocksUseCase.call(
        _inventoryId!,
        page: _currentPage,
        perPage: _perPage,
      );

      if (response.isSuccess && response.body != null) {
        final List<dynamic> dataList = response.body['data'] ?? [];
        final List<StockTransactionModel> newStocks = dataList.map((json) => StockTransactionModel.fromJson(json)).toList();

        if (refresh) {
          stocks.assignAll(newStocks);
        } else {
          stocks.addAll(newStocks);
        }

        final int totalPages = response.body['last_page'] ?? 1;
        _hasMore = _currentPage < totalPages;
        
        if (_hasMore) {
          _currentPage++;
        }
      } else {
        CustomSnackbar.showError('Failed to fetch stock history');
      }
    } catch (e) {
      print('Error fetching stocks: $e');
      if (refresh) {
        CustomSnackbar.showError('Error connecting to server');
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
}
