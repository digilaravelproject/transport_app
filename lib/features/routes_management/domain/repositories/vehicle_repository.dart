import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../models/vehicle_model.dart';

abstract class VehicleRepository {
  Future<ResponseModel> getVehicles({String? search});
  Future<ResponseModel> assignVehicleToRoute({
    required int routeId,
    required int vehicleId,
  });
}

class VehicleRepositoryImpl implements VehicleRepository {
  final ApiClient _apiClient;

  VehicleRepositoryImpl(this._apiClient);

  @override
  Future<ResponseModel> getVehicles({String? search}) async {
    try {
      String endpoint = '/api/v1/vehicles';
      
      // Add search parameter if provided
      if (search != null && search.isNotEmpty) {
        endpoint += '?search=$search';
      }

      print('=== VEHICLE API CALL ===');
      print('Endpoint: $endpoint');
      print('Search: $search');

      final response = await _apiClient.get(
        endpoint,
        handleError: false,
        showToaster: false,
      );

      print('=== VEHICLE API RESPONSE ===');
      print('Success: ${response.isSuccess}');
      print('Status Code: ${response.statusCode}');
      print('Message: ${response.message}');
      print('Body Type: ${response.body.runtimeType}');
      print('Body: ${response.body}');

      if (response.isSuccess && response.body != null) {
        try {
          List<VehicleModel> vehicles = [];
          
          if (response.body is Map<String, dynamic>) {
            final responseData = response.body as Map<String, dynamic>;
            
            // Handle the response structure based on API response
            if (responseData.containsKey('data') && responseData['data'] is List) {
              final List<dynamic> vehiclesData = responseData['data'];
              vehicles = vehiclesData.map((json) => VehicleModel.fromJson(json)).toList();
              print('Parsed ${vehicles.length} vehicles from response data');
            } else {
              print('Response data does not contain expected structure');
              print('Available keys: ${responseData.keys.toList()}');
            }
          } else if (response.body is List) {
            final List<dynamic> vehiclesData = response.body as List;
            vehicles = vehiclesData.map((json) => VehicleModel.fromJson(json)).toList();
            print('Parsed ${vehicles.length} vehicles from response list');
          } else {
            print('Unexpected response body type: ${response.body.runtimeType}');
          }

          print('Successfully fetched ${vehicles.length} vehicles');
          return ResponseModel(
            isSuccess: true,
            statusCode: response.statusCode ?? 200,
            message: response.message ?? 'Vehicles fetched successfully',
            body: vehicles,
          );
        } catch (e) {
          print('Error processing vehicles response: $e');
          return ResponseModel(
            isSuccess: false,
            statusCode: 500,
            message: 'Error processing vehicles data: $e',
          );
        }
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to fetch vehicles',
      );
    } catch (e) {
      print('Error fetching vehicles: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error fetching vehicles: $e',
      );
    }
  }

  @override
  Future<ResponseModel> assignVehicleToRoute({
    required int routeId,
    required int vehicleId,
  }) async {
    try {
      final endpoint = '/api/v1/routes/$routeId/assign-vehicles';
      final body = {
        'vehicle_ids': [vehicleId],
      };

      print('=== ASSIGN VEHICLE API CALL ===');
      print('Endpoint: $endpoint');
      print('Route ID: $routeId');
      print('Vehicle ID: $vehicleId');
      print('Request body: $body');

      final response = await _apiClient.post(
        endpoint,
        data: body,
        handleError: false,
        showToaster: false,
      );

      print('=== ASSIGN VEHICLE API RESPONSE ===');
      print('Success: ${response.isSuccess}');
      print('Status Code: ${response.statusCode}');
      print('Message: ${response.message}');
      print('Body: ${response.body}');

      if (response.isSuccess) {
        print('Successfully assigned vehicle to route');
        return ResponseModel(
          isSuccess: true,
          statusCode: response.statusCode ?? 200,
          message: response.message ?? 'Vehicle assigned successfully',
          body: response.body,
        );
      }

      return ResponseModel(
        isSuccess: false,
        statusCode: response.statusCode ?? 500,
        message: response.message ?? 'Failed to assign vehicle',
      );
    } catch (e) {
      print('Error assigning vehicle: $e');
      return ResponseModel(
        isSuccess: false,
        statusCode: 500,
        message: 'Error assigning vehicle: $e',
      );
    }
  }
}