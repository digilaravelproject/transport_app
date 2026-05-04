import 'package:get/get.dart';
import '../domain/models/vehicle_type_model.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/custom_snackbar.dart';

class VehicleTypeController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final vehicleTypes = <VehicleTypeModel>[].obs;
  final filteredVehicleTypes = <VehicleTypeModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicleTypes();
    debounce(searchQuery, (_) => _filterVehicleTypes(), time: const Duration(milliseconds: 500));
  }

  Future<void> fetchVehicleTypes() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppConstants.getVehicleTypesUrl);
      if (response.isSuccess) {
        final List<dynamic> bodyData = response.body;
        final fetchedTypes = bodyData.map((json) => VehicleTypeModel.fromJson(json)).toList();
        
        if (fetchedTypes.isEmpty) {
          vehicleTypes.value = _getDefaultVehicleTypes();
        } else {
          vehicleTypes.value = fetchedTypes;
        }
        _filterVehicleTypes();
      } else {
        // If API fails, show defaults as fallback
        vehicleTypes.value = _getDefaultVehicleTypes();
        _filterVehicleTypes();
        Logger.e('Failed to fetch vehicle types: ${response.message}');
      }
    } catch (e) {
      vehicleTypes.value = _getDefaultVehicleTypes();
      _filterVehicleTypes();
      Logger.e('Error fetching vehicle types: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<VehicleTypeModel> _getDefaultVehicleTypes() {
    return [
      VehicleTypeModel(id: 101, name: 'Truck', capacity: 1000, perKmPrice: 25.0, acPricePerKm: 5.0, description: 'Heavy goods vehicle'),
      VehicleTypeModel(id: 102, name: 'Bus', capacity: 50, perKmPrice: 40.0, acPricePerKm: 10.0, description: 'Passenger transport'),
      VehicleTypeModel(id: 103, name: 'Car', capacity: 4, perKmPrice: 15.0, acPricePerKm: 3.0, description: 'Small passenger vehicle'),
      VehicleTypeModel(id: 104, name: 'Bike', capacity: 1, perKmPrice: 8.0, acPricePerKm: 0.0, description: 'Two-wheeler'),
      VehicleTypeModel(id: 105, name: 'Van', capacity: 12, perKmPrice: 20.0, acPricePerKm: 4.0, description: 'Medium transport vehicle'),
    ];
  }

  void _filterVehicleTypes() {
    if (searchQuery.value.isEmpty) {
      filteredVehicleTypes.assignAll(vehicleTypes);
    } else {
      filteredVehicleTypes.assignAll(
        vehicleTypes.where((type) => 
          type.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (type.description?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
        ).toList(),
      );
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  Future<bool> addVehicleType(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.post(
        AppConstants.vehicleTypesUrl,
        data: {
          ...data,
          'is_active': 1,
        },
      );

      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Vehicle type added successfully');
        fetchVehicleTypes();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('Error adding vehicle type: $e');
      CustomSnackbar.showError('Something went wrong');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateVehicleType(dynamic id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.put(
        AppConstants.updateVehicleTypeUrl(id),
        data: data,
      );

      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Vehicle type updated successfully');
        fetchVehicleTypes();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('Error updating vehicle type: $e');
      CustomSnackbar.showError('Something went wrong');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteVehicleType(dynamic id) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.delete(AppConstants.deleteVehicleTypeUrl(id));
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Vehicle type deleted successfully');
        fetchVehicleTypes();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('Error deleting vehicle type: $e');
      CustomSnackbar.showError('Something went wrong');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
