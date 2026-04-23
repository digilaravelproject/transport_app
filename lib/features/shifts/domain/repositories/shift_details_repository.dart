import 'package:credit_debit/core/constants/app_constants.dart';

import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/shift_model.dart';

abstract class ShiftDetailsRepository {
  Future<ResponseModel> getShiftDetails(int shiftId);
}

class ShiftDetailsRepositoryImpl implements ShiftDetailsRepository {
  final ApiClient _apiClient;

  ShiftDetailsRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> getShiftDetails(int shiftId) async {
    try {
      print('Fetching shift details for ID: $shiftId');

      final response = await _apiClient.get(
        AppConstants.getShiftById(shiftId),
        handleError: false,
        showToaster: false,
      );

      print('Shift details response - Success: ${response.isSuccess}, Status: ${response.statusCode}');

      if (response.isSuccess && response.body != null) {
        try {
          // response.body is already the shift data from ResponseModel.fromJson
          final shift = ShiftModel.fromJson(response.body as Map<String, dynamic>);

          print('Successfully parsed shift details');

          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message,
            body: shift,
          );
        } catch (e) {
          print('Error processing shift details response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing shift details: $e',
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to fetch shift details',
      );
    } catch (e) {
      print('Error fetching shift details: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error fetching shift details: $e',
      );
    }
  }
}
