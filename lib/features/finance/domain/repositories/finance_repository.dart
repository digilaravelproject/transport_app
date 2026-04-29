import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/transaction_model.dart';
import '../models/transaction_request_model.dart';

abstract class FinanceRepository {
  Future<ResponseModel> getFinanceData({
    int page = 1,
    int perPage = 10,
    String? type,
    String? category,
  });

  Future<ResponseModel> getTransactionById(int id);

  Future<ResponseModel> addTransaction(TransactionRequestModel request);
}

class FinanceRepositoryImpl implements FinanceRepository {
  final ApiClient _apiClient;

  FinanceRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> getFinanceData({
    int page = 1,
    int perPage = 10,
    String? type,
    String? category,
  }) async {
    try {
      String endpoint = '/api/v1/finance';
      
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (type != null && type.isNotEmpty && type != 'All') {
        queryParams['type'] = type.toLowerCase();
      }

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      // Add query parameters to endpoint
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
      }

      print('=== FINANCE API CALL ===');
      print('Endpoint: $endpoint');
      print('Page: $page, Per Page: $perPage');
      print('Type: $type, Category: $category');

      final response = await _apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      print('=== FINANCE API RESPONSE ===');
      print('Success: ${response.isSuccess}');
      print('Status Code: ${response.statusCode}');
      print('Message: ${response.message}');

      if (response.isSuccess && response.body != null) {
        try {
          FinanceResponse financeResponse;
          
          if (response.json != null || response.body is Map<String, dynamic>) {
            final responseData = (response.json ?? response.body) as Map<String, dynamic>;
            financeResponse = FinanceResponse.fromJson(responseData);
            
            print('Successfully parsed finance data:');
            print('- Summary: Balance ${financeResponse.summary.currentBalance}');
            print('- Transactions: ${financeResponse.transactions.length}');
            print('- Pagination: Page ${financeResponse.meta.currentPage} of ${financeResponse.meta.lastPage}');
          } else {
            print('Unexpected response body type: ${response.body.runtimeType}');
            return ResponseModel(
              isSuccess: false,
              statusCode: 500,
              message: 'Invalid response format',
            );
          }

          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message ?? 'Finance data fetched successfully',
            body: financeResponse,
          );
        } catch (e) {
          print('Error processing finance response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing finance data: $e',
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to fetch finance data',
      );
    } catch (e) {
      print('Error fetching finance data: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error fetching finance data: $e',
      );
    }
  }

  @override
  Future<ResponseModel> getTransactionById(int id) async {
    try {
      final response = await _apiClient.get('/api/v1/finance/$id');
      return response;
    } catch (e) {
      print('Error fetching transaction by ID: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error fetching transaction details: $e',
      );
    }
  }

  @override
  Future<ResponseModel> addTransaction(TransactionRequestModel request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/finance',
        data: request.toJson(),
      );
      return response;
    } catch (e) {
      print('Error adding transaction: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error adding transaction: $e',
      );
    }
  }
}