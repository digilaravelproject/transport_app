import 'package:credit_debit/core/constants/app_constants.dart';

import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/shift_model.dart';

abstract class ShiftListRepository {
  Future<ResponseModel> getShifts({
    String? type,
    String? search,
    int page = 1,
  });
}

class ShiftListRepositoryImpl implements ShiftListRepository {
  final ApiClient _apiClient;

  ShiftListRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> getShifts({
    String? type,
    String? search,
    int page = 1,
  }) async {
    try {
      String endpoint;
      Map<String, dynamic> queryParams = {};

      // Use search endpoint if search query is provided
      if (search != null && search.isNotEmpty) {
        endpoint = '/api/v1/shifts/search';
        queryParams['query'] = search;
      } else {
        endpoint = AppConstants.getShift;
        queryParams['page'] = page;
        
        if (type != null && type.isNotEmpty && type != 'All') {
          queryParams['type'] = type.toLowerCase();
        }
      }

      print('Fetching shifts from: $endpoint with params: $queryParams');

      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParams,
        handleError: false,
        showToaster: false,
      );

      print('Shifts response - Success: ${response.isSuccess}, Status: ${response.statusCode}');
      print('Shifts response body type: ${response.body.runtimeType}');

      if (response.isSuccess && response.body != null) {
        try {
          List<ShiftModel> shifts = [];
          
          // response.body is already parsed by ResponseModel.fromJson
          // It contains the 'data' array directly
          if (response.body is List<dynamic>) {
            shifts = (response.body as List<dynamic>)
                .map((item) {
                  try {
                    return ShiftModel.fromJson(item as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parsing shift item: $e, item: $item');
                    return null;
                  }
                })
                .whereType<ShiftModel>()
                .toList();
          }

          print('Successfully parsed ${shifts.length} shifts');

          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message,
            body: shifts,
          );
        } catch (e) {
          print('Error processing shifts response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing shifts: $e',
            body: <ShiftModel>[],
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to fetch shifts',
        body: <ShiftModel>[],
      );
    } catch (e) {
      print('Error fetching shifts: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error fetching shifts: $e',
        body: <ShiftModel>[],
      );
    }
  }
}
