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

  Future<ResponseModel> updateShift({
    required int shiftId,
    required String name,
    required String startTime,
    required String endTime,
    required String type,
    String? date,
    String? notes,
  });

  Future<ResponseModel> deleteShift(int shiftId);
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
      print('Shift response body type: ${response.body.runtimeType}');

      if (response.isSuccess && response.body != null) {
        try {
          // response.body is already parsed by ResponseModel.fromJson
          // It contains the 'data' object directly
          if (response.body is Map<String, dynamic>) {
            final shift = ShiftModel.fromJson(response.body as Map<String, dynamic>);
            return ResponseModel(
              isSuccess: true,
              statusCode: response.statusCode ?? 200,
              message: response.message,
              body: shift,
            );
          }

          print('Successfully created shift');
          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message ?? 'Shift created successfully',
            body: response.body,
          );
        } catch (e) {
          print('Error processing shift creation response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing shift creation data: $e',
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

  @override
  Future<ResponseModel> updateShift({
    required int shiftId,
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

      print('Updating shift $shiftId with body: $body');

      final response = await _apiClient.put(
        '/api/v1/shifts/$shiftId',
        data: body,
        handleError: false,
        showToaster: false,
      );

      print('Shift update response - Success: ${response.isSuccess}, Status: ${response.statusCode}');
      print('Shift update response body type: ${response.body.runtimeType}');

      if (response.isSuccess && response.body != null) {
        try {
          // response.body is already parsed by ResponseModel.fromJson
          // It contains the 'data' object directly
          if (response.body is Map<String, dynamic>) {
            final shift = ShiftModel.fromJson(response.body as Map<String, dynamic>);
            return ResponseModel(
              isSuccess: true,
              statusCode: response.statusCode ?? 200,
              message: response.message,
              body: shift,
            );
          }

          print('Successfully updated shift');
          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message ?? 'Shift updated successfully',
            body: response.body,
          );
        } catch (e) {
          print('Error processing shift update response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing shift update data: $e',
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to update shift',
      );
    } catch (e) {
      print('Error updating shift: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error updating shift: $e',
      );
    }
  }

  @override
  Future<ResponseModel> deleteShift(int shiftId) async {
    try {
      print('Deleting shift with ID: $shiftId');

      final response = await _apiClient.delete(
        '/api/v1/shifts/$shiftId',
        handleError: false,
        showToaster: false,
      );

      print('Shift delete response - Success: ${response.isSuccess}, Status: ${response.statusCode}');
      print('Shift delete response body type: ${response.body.runtimeType}');

      if (response.isSuccess) {
        print('Successfully deleted shift');
        return ResponseModel(
          isSuccess: true,
          statusCode: response.statusCode ?? 200,
          message: response.message ?? 'Shift deleted successfully',
        );
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to delete shift',
      );
    } catch (e) {
      print('Error deleting shift: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error deleting shift: $e',
      );
    }
  }
}
