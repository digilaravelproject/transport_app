import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/shift_model.dart';

abstract class ShiftRepository {
  Future<ResponseModel> createShift({
    required String name,
    required String startTime,
    required String endTime,
    required String type,
    String? date,
    String? notes,
  });
}

class ShiftRepositoryImpl implements ShiftRepository {
  final ApiClient _apiClient;

  ShiftRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> createShift({
    required String name,
    required String startTime,
    required String endTime,
    required String type,
    String? date,
    String? notes,
  }) async {
    try {
      final body = {
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
        'type': type.toLowerCase(),
        if (date != null && date.isNotEmpty) 'date': date,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('Creating shift with body: $body');

      final response = await _apiClient.post(
        AppConstants.createShift,
        data: body,
        handleError: false,
        showToaster: false,
      );

      print('Shift creation response - Success: ${response.isSuccess}, Status: ${response.statusCode}');
      print('Shift response body: ${response.body}');

      if (response.body != null) {
        try {
          final responseBody = response.body as Map<String, dynamic>;
          
          // Check if API returned success: true
          final apiSuccess = responseBody['success'] == true;
          final data = responseBody['data'] as Map<String, dynamic>?;

          if (apiSuccess && data != null) {
            final shift = ShiftModel.fromJson(data);
            return ResponseModel(
              isSuccess: true,
              statusCode: response.statusCode ?? 200,
              message: responseBody['message'] ?? 'Shift created successfully',
              body: shift,
            );
          } else if (apiSuccess) {
            // Success but no data
            return ResponseModel(
              isSuccess: true,
              statusCode: response.statusCode ?? 200,
              message: responseBody['message'] ?? 'Shift created successfully',
              body: null,
            );
          }
        } catch (e) {
          print('Error parsing shift response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing shift data: $e',
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to create shift',
      );
    } catch (e) {
      print('Error creating shift: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error creating shift: $e',
      );
    }
  }
}
