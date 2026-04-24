import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/shift_model.dart';

abstract class DriverRepository {
  Future<ResponseModel> getAvailableDrivers({String? search});
}

class DriverRepositoryImpl implements DriverRepository {
  final ApiClient _apiClient;

  DriverRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> getAvailableDrivers({String? search}) async {
    try {
      String endpoint = '/api/v1/drivers/8'; // Based on the provided API endpoint
      
      // Add search parameter if provided
      if (search != null && search.isNotEmpty) {
        endpoint += '?search=$search';
      }

      print('Fetching available drivers from: $endpoint');

      final response = await _apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      print('Drivers response - Success: ${response.isSuccess}, Status: ${response.statusCode}');
      print('Drivers response body type: ${response.body.runtimeType}');

      if (response.isSuccess && response.body != null) {
        try {
          List<DriverModel> drivers = [];
          
          if (response.body is Map<String, dynamic>) {
            final responseData = response.body as Map<String, dynamic>;
            
            // Handle the response structure based on API response
            if (responseData.containsKey('data') && responseData['data'] is List) {
              final List<dynamic> driversData = responseData['data'];
              drivers = driversData.map((json) => DriverModel.fromJson(json)).toList();
            }
          } else if (response.body is List) {
            final List<dynamic> driversData = response.body as List;
            drivers = driversData.map((json) => DriverModel.fromJson(json)).toList();
          }

          print('Successfully fetched ${drivers.length} drivers');
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
}