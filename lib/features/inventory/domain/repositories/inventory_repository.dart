import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/inventory_item_request_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class InventoryRepository {
  Future<ResponseModel> addInventoryItem(InventoryItemRequestModel request);
  Future<ResponseModel> getInventoryData({
    int page = 1,
    int perPage = 10,
    String? category,
  });
  Future<ResponseModel> getInventoryDetails(int id);
  Future<ResponseModel> getInventoryStocks(int id, {int page = 1, int perPage = 20});
  Future<ResponseModel> updateInventoryItem(int id, InventoryItemRequestModel request);
  Future<ResponseModel> deleteInventoryItem(int id);
  Future<ResponseModel> stockIn(int id, Map<String, dynamic> data);
  Future<ResponseModel> stockOut(int id, Map<String, dynamic> data);
}

class InventoryRepositoryImpl implements InventoryRepository {
  final ApiClient _apiClient;

  InventoryRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> addInventoryItem(InventoryItemRequestModel request) async {
    try {
      final response = await _apiClient.post(
        AppConstants.inventoryListUrl,
        data: request.toJson(),
      );
      return response;
    } catch (e) {
      print('Error adding inventory item: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error adding inventory item: $e',
      );
    }
  }

  @override
  Future<ResponseModel> getInventoryData({
    int page = 1,
    int perPage = 10,
    String? category,
  }) async {
    try {
      String endpoint = AppConstants.inventoryListUrl;
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }

      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
      }

      print('=== INVENTORY API CALL ===');
      print('Endpoint: $endpoint');

      final response = await _apiClient.get(endpoint);
      return response;
    } catch (e) {
      print('Error fetching inventory data: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Failed to connect to server',
      );
    }
  }

  @override
  Future<ResponseModel> getInventoryDetails(int id) async {
    try {
      final endpoint = AppConstants.inventoryDetailsUrl(id);
      print('=== INVENTORY DETAILS API CALL ===');
      print('Endpoint: $endpoint');

      final response = await _apiClient.get(endpoint);
      return response;
    } catch (e) {
      print('Error fetching inventory details: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Failed to connect to server',
      );
    }
  }

  @override
  Future<ResponseModel> getInventoryStocks(int id, {int page = 1, int perPage = 20}) async {
    try {
      final endpoint = '${AppConstants.inventoryStocksUrl(id)}?page=$page&per_page=$perPage';
      print('=== INVENTORY STOCKS API CALL ===');
      print('Endpoint: $endpoint');

      final response = await _apiClient.get(endpoint);
      return response;
    } catch (e) {
      print('Error fetching inventory stocks: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Failed to connect to server',
      );
    }
  }

  @override
  Future<ResponseModel> updateInventoryItem(int id, InventoryItemRequestModel request) async {
    try {
      final response = await _apiClient.put(
        AppConstants.inventoryDetailsUrl(id),
        data: request.toJson(),
      );
      return response;
    } catch (e) {
      print('Error updating inventory item: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error updating inventory item: $e',
      );
    }
  }

  @override
  Future<ResponseModel> deleteInventoryItem(int id) async {
    try {
      final response = await _apiClient.delete(AppConstants.inventoryDeleteUrl(id));
      return response;
    } catch (e) {
      print('Error deleting inventory item: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error deleting inventory item: $e',
      );
    }
  }

  @override
  Future<ResponseModel> stockIn(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        AppConstants.stockInUrl(id),
        data: data,
      );
      return response;
    } catch (e) {
      print('Error during stock-in: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error during stock-in: $e',
      );
    }
  }

  @override
  Future<ResponseModel> stockOut(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        AppConstants.stockOutUrl(id),
        data: data,
      );
      return response;
    } catch (e) {
      print('Error during stock-out: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error during stock-out: $e',
      );
    }
  }
}
