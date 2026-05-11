import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/shift_model.dart';

abstract class DriverRepository {
  Future<ResponseModel> getAvailableDrivers({
    required int shiftId,
    String? search,
  });
  Future<ResponseModel> assignDriversToShift({
    required int shiftId,
    required List<int> driverIds,
  });
  Future<ResponseModel> removeDriverFromShift({
    required int shiftId,
    required int driverId,
  });
}

class DriverRepositoryImpl implements DriverRepository {
  final ApiClient _apiClient;

  DriverRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> getAvailableDrivers({
    required int shiftId,
    String? search,
  }) async {
    try {
      String endpoint = '/api/v1/drivers/$shiftId';
      
      if (search != null && search.isNotEmpty) {
        endpoint += '?search=$search';
      }

      print('=== DRIVER API CALL ===');
      print('Endpoint: $endpoint');
      print('Shift ID: $shiftId');
      print('Search: $search');

      final response = await _apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      print('=== DRIVER API RESPONSE ===');
      print('Success: ${response.isSuccess}');
      print('Status Code: ${response.statusCode}');
      print('Message: ${response.message}');
      print('Body Type: ${response.body.runtimeType}');
      print('Body: ${response.body}');

      if (response.isSuccess && response.body != null) {
        try {
          List<DriverModel> drivers = [];
          
          if (response.body is Map<String, dynamic>) {
            final responseData = response.body as Map<String, dynamic>;
            
            // Handle the response structure based on API response
            if (responseData.containsKey('data') && responseData['data'] is List) {
              final List<dynamic> driversData = responseData['data'];
              drivers = driversData.map((json) => DriverModel.fromJson(json)).toList();
              print('Parsed ${drivers.length} drivers from response data');
            } else {
              print('Response data does not contain expected structure');
              print('Available keys: ${responseData.keys.toList()}');
            }
          } else if (response.body is List) {
            final List<dynamic> driversData = response.body as List;
            drivers = driversData.map((json) => DriverModel.fromJson(json)).toList();
            print('Parsed ${drivers.length} drivers from response list');
          } else {
            print('Unexpected response body type: ${response.body.runtimeType}');
          }

          print('Successfully fetched ${drivers.length} drivers for shift $shiftId');
          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message ?? 'Drivers fetched successfully',
            body: drivers,
          );
        } catch (e) {
          print('Error processing drivers response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing drivers data: $e',
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to fetch drivers',
      );
    } catch (e) {
      print('Error fetching drivers: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error fetching drivers: $e',
      );
    }
  }

  @override
  Future<ResponseModel> assignDriversToShift({
    required int shiftId,
    required List<int> driverIds,
  }) async {
    try {
      final endpoint = '/api/v1/shifts/$shiftId/add-driver';
      final body = {
        'driver_id': driverIds,
      };

      print('Assigning drivers to shift $shiftId: $driverIds');
      print('Request body: $body');

      final response = await _apiClient.post(
        endpoint,
        data: body,
        handleError: false,
        showToaster: false,
      );

      print('Assign drivers response - Success: ${response.isSuccess}, Status: ${response.statusCode}');
      print('Assign drivers response body: ${response.body}');

      if (response.isSuccess) {
        print('Successfully assigned drivers to shift');
        return ResponseModel(
          isSuccess: true,
          statusCode: response.statusCode ?? 200,
          message: response.message ?? 'Drivers assigned successfully',
          body: response.body,
        );
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to assign drivers',
      );
    } catch (e) {
      print('Error assigning drivers: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error assigning drivers: $e',
      );
    }
  }

  @override
  Future<ResponseModel> removeDriverFromShift({
    required int shiftId,
    required int driverId,
  }) async {
    try {
      final endpoint = '/api/v1/shifts/$shiftId/remove-driver';
      final body = {
        'driver_id': driverId,
      };

      print('Removing driver $driverId from shift $shiftId');
      print('Endpoint: $endpoint');

      final response = await _apiClient.post(
        endpoint,
        data: body,
        handleError: false,
        showToaster: false,
      );

      print('Remove driver response - Success: ${response.isSuccess}, Status: ${response.statusCode}');
      print('Remove driver response body: ${response.body}');

      if (response.isSuccess) {
        print('Successfully removed driver from shift');
        return ResponseModel(
          isSuccess: true,
          statusCode: response.statusCode ?? 200,
          message: response.message ?? 'Driver removed successfully',
          body: response.body,
        );
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to remove driver',
      );
    } catch (e) {
      print('Error removing driver: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error removing driver: $e',
      );
    }
  }
}