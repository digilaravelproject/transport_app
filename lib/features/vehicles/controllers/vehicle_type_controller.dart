import 'package:get/get.dart';
import '../domain/models/vehicle_type_model.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/custom_snackbar.dart';

class VehicleTypeController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final selectedVehicle = Rxn<VehicleTypeModel>();
  final vehicleTypes = <VehicleTypeModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final searchQuery = ''.obs;

  int _currentPage = 1;
  bool _hasNextPage = true;

  @override
  void onInit() {
    super.onInit();
    fetchVehicleTypes();
    // Debounce search to avoid too many API calls
    debounce(searchQuery, (_) => fetchVehicleTypes(isRefresh: true), time: const Duration(milliseconds: 600));
  }

  Future<void> fetchVehicleTypes({bool isRefresh = true}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
      if (searchQuery.value.isEmpty) {
        isLoading.value = true;
      }
    } else {
      if (!_hasNextPage || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      String url;
      if (searchQuery.value.isNotEmpty) {
        url = AppConstants.searchVehicleTypesUrl(searchQuery.value, _currentPage);
      } else {
        url = AppConstants.getVehicleTypesPagedUrl(_currentPage);
      }

      final response = await _apiClient.get(url);

      if (response.isSuccess) {
        // Handle Laravel pagination structure: response.body['data']
        final dynamic responseData = response.body;
        List<dynamic> dataList = [];

        if (responseData is Map && responseData.containsKey('data')) {
          dataList = responseData['data'];

          // Update pagination state from meta
          final meta = responseData['meta'];
          if (meta != null) {
            _currentPage = (meta['current_page'] ?? _currentPage) + 1;
            _hasNextPage = (meta['current_page'] ?? 1) < (meta['last_page'] ?? 1);
          } else {
            _hasNextPage = false;
          }
        } else if (responseData is List) {
          // Fallback for simple list response
          dataList = responseData;
          _hasNextPage = false;
        }

        final fetchedTypes = dataList.map((json) => VehicleTypeModel.fromJson(json)).toList();

        if (isRefresh) {
          vehicleTypes.assignAll(fetchedTypes);
        } else {
          vehicleTypes.addAll(fetchedTypes);
        }
      } else {
        if (isRefresh && searchQuery.value.isEmpty) {
          vehicleTypes.value = _getDefaultVehicleTypes();
        }
        Logger.e('Failed to fetch vehicle types: ${response.message}');
      }
    } catch (e) {
      if (isRefresh && searchQuery.value.isEmpty) {
        vehicleTypes.value = _getDefaultVehicleTypes();
      }
      Logger.e('Error fetching vehicle types: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
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

  Future<void> fetchVehicleTypeById(int id) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get('${AppConstants.vehicleTypesUrl}/$id');
      if (response.isSuccess) {
        final data = response.body['data'];
        selectedVehicle.value = VehicleTypeModel.fromJson(data);
      } else {
        Logger.e('Failed to fetch vehicle type: "+response.message');
      }
    } catch (e) {
      Logger.e('Error fetching vehicle type: $e');
    } finally {
      isLoading.value = false;
    }
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

  // Update search query and trigger debounce fetch
  void updateSearch(String query) {
    searchQuery.value = query;
  }
}
