import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/response_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/network/multipart.dart';
import '../domain/models/trip_model.dart';

class TripController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Observable variables
  var trips = <TripModel>[].obs;
  var filteredTrips = <TripModel>[].obs;
  var searchQuery = ''.obs;
  var selectedFilter = 'All'.obs;
  var isLoading = false.obs;

  // Filter dates
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();

  // Stats
  var totalTrips = 0.obs;
  var ongoingTrips = 0.obs;
  var pendingTrips = 0.obs;

  // Assignment data
  var availableVehicles = <dynamic>[].obs;
  var availableDrivers = <dynamic>[].obs;
  var isAssigning = false.obs;

  // Form Controllers for Create Trip
  final dateController = TextEditingController();
  final routeController = TextEditingController();
  final durationController = TextEditingController();
  final vehicleCountController = TextEditingController();
  final seatingCapacityController = TextEditingController();
  final pickupAddressController = TextEditingController();
  final destinationController = TextEditingController();
  
  // Customer & Payment Controllers
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final totalAmountController = TextEditingController();
  final advanceAmountController = TextEditingController();
  
  // Observable form values
  var totalAmount = 0.0.obs;
  var advanceAmount = 0.0.obs;
  var selectedTripType = 'Round Trip'.obs;
  var selectedVehicleType = 'Luxury Bus'.obs;
  var selectedDriver = ''.obs;
  var tripDate = DateTime.now().obs;
  var selectedCountryCode = '+91'.obs;
  final selectedVehicleTypeId = Rxn<int>();
  final destinationPoints = <Map<String, dynamic>>[].obs;
  
  // Selected Trip for Details
  final selectedTrip = Rxn<TripModel>();
  var tripExpenses = <Map<String, dynamic>>[].obs;
  var dutySheets = <Map<String, dynamic>>[].obs;

  double get totalExpenseAmount => tripExpenses.fold(0, (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0));

  double get pendingAmount => totalAmount.value - advanceAmount.value;

  @override
  void onInit() {
    super.onInit();
    
    // Initial fetch
    fetchTrips();
    
    // Listen to changes - Now search also triggers API call
    debounce(searchQuery, (_) => fetchTrips(), time: const Duration(milliseconds: 500));
    ever(selectedFilter, (_) => fetchTrips());
    ever(fromDate, (_) => fetchTrips());
    ever(toDate, (_) => fetchTrips());

    totalAmountController.addListener(() {
      totalAmount.value = double.tryParse(totalAmountController.text) ?? 0.0;
    });
    advanceAmountController.addListener(() {
      advanceAmount.value = double.tryParse(advanceAmountController.text) ?? 0.0;
    });
  }

  Future<void> fetchTrips() async {
    try {
      isLoading.value = true;
      
      final Map<String, dynamic> queryParams = {
        'per_page': 20,
      };

      if (selectedFilter.value != 'All') {
        queryParams['status'] = selectedFilter.value.toLowerCase();
      }

      if (fromDate.value != null) {
        queryParams['from'] = DateFormat('yyyy-MM-dd').format(fromDate.value!);
      }

      if (toDate.value != null) {
        queryParams['to'] = DateFormat('yyyy-MM-dd').format(toDate.value!);
      }

      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      final ResponseModel response = await _apiClient.get(AppConstants.tripsUrl, queryParameters: queryParams);

      if (response.isSuccess && response.body != null) {
        final body = response.body;
        final List<dynamic> data = body is List ? body : (body['data'] ?? []);
        final List<TripModel> fetchedTrips = data.map((json) => TripModel.fromJson(json)).toList();
        
        trips.assignAll(fetchedTrips);
        filteredTrips.assignAll(fetchedTrips);

        // Update stats solely from server's trip_summary
        final fullJson = response.json;
        if (fullJson != null && fullJson['trip_summary'] != null) {
          final summary = fullJson['trip_summary'];
          totalTrips.value = summary['total_trip'] ?? 0;
          ongoingTrips.value = summary['ongoing_trip'] ?? 0;
          pendingTrips.value = summary['pending_trip'] ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching trips: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTripDetails(String id) async {
    try {
      isLoading.value = true;
      final ResponseModel response = await _apiClient.get(
        AppConstants.getTripDetailsUrl(id),
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );

      if (response.isSuccess && response.json != null) {
        final data = response.json!['data'];
        selectedTrip.value = TripModel.fromJson(data);
        debugPrint('Trip details fetched. Vehicles: ${selectedTrip.value?.assignedVehicles.length}, Drivers: ${selectedTrip.value?.assignedDrivers.length}');
        selectedTrip.refresh();
      }
    } catch (e) {
      debugPrint('Error fetching trip details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAvailableVehicles() async {
    try {
      final ResponseModel response = await _apiClient.get(AppConstants.availableVehiclesUrl);
      if (response.isSuccess && response.json != null) {
        availableVehicles.assignAll(response.json!['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching available vehicles: $e');
    }
  }

  Future<void> fetchAvailableDrivers() async {
    try {
      final ResponseModel response = await _apiClient.get(AppConstants.availableDriversUrl);
      if (response.isSuccess && response.json != null) {
        availableDrivers.assignAll(response.json!['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching available drivers: $e');
    }
  }

  Future<bool> assignVehicles(String tripId, List<int> vehicleIds) async {
    try {
      isAssigning.value = true;
      final ResponseModel response = await _apiClient.post(
        AppConstants.assignVehiclesUrl(tripId),
        data: {'vehicle_ids': vehicleIds},
      );

      if (response.isSuccess) {
        if (response.json != null && response.json!['data'] != null) {
          selectedTrip.value = TripModel.fromJson(response.json!['data']);
        }
        // Background refresh after delay
        Future.delayed(const Duration(milliseconds: 1000), () => fetchTripDetails(tripId));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error assigning vehicles: $e');
      return false;
    } finally {
      isAssigning.value = false;
    }
  }

  Future<bool> assignDrivers(String tripId, List<int> driverIds) async {
    try {
      isAssigning.value = true;
      final ResponseModel response = await _apiClient.post(
        AppConstants.assignDriversUrl(tripId),
        data: {'driver_ids': driverIds},
      );

      if (response.isSuccess) {
        if (response.json != null && response.json!['data'] != null) {
          selectedTrip.value = TripModel.fromJson(response.json!['data']);
        }
        // Background refresh after delay
        Future.delayed(const Duration(milliseconds: 1000), () => fetchTripDetails(tripId));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error assigning drivers: $e');
      return false;
    } finally {
      isAssigning.value = false;
    }
  }

  Future<bool> removeVehicle(String tripId, dynamic vehicleId) async {
    try {
      final int vId = int.tryParse(vehicleId.toString()) ?? 0;
      isAssigning.value = true;
      final ResponseModel response = await _apiClient.post(
        AppConstants.removeTripVehicles(tripId),
        data: {'vehicle_ids': [vId]},
      );

      if (response.isSuccess) {
        if (response.json != null && response.json!['data'] != null) {
          selectedTrip.value = TripModel.fromJson(response.json!['data']);
        }
        // Background refresh after delay
        Future.delayed(const Duration(milliseconds: 1000), () => fetchTripDetails(tripId));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error removing vehicle: $e');
      return false;
    } finally {
      isAssigning.value = false;
    }
  }

  Future<bool> removeDriver(String tripId, dynamic driverId) async {
    try {
      final int dId = int.tryParse(driverId.toString()) ?? 0;
      isAssigning.value = true;
      final ResponseModel response = await _apiClient.post(
        AppConstants.removeTripDrivers(tripId),
        data: {'driver_ids': [dId]},
      );

      if (response.isSuccess) {
        if (response.json != null && response.json!['data'] != null) {
          selectedTrip.value = TripModel.fromJson(response.json!['data']);
        }
        // Background refresh after delay
        Future.delayed(const Duration(milliseconds: 1000), () => fetchTripDetails(tripId));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error removing driver: $e');
      return false;
    } finally {
      isAssigning.value = false;
    }
  }

  Future<bool> createTrip({Map<String, dynamic>? data}) async {
    try {
      isLoading.value = true;

      Map<String, dynamic> payload;
      
      if (data != null) {
        payload = data;
      } else {
        // Format date as YYYY-MM-DD
        final String formattedDate = DateFormat('yyyy-MM-dd').format(tripDate.value);
        
        // Clean up duration to get only number
        final int durationDaysValue = int.tryParse(durationController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;

        payload = {
          "trip_date": formattedDate,
          "duration_days": durationDaysValue,
          "trip_route": selectedTripType.value,
          "pickup_address": pickupAddressController.text,
          "points": destinationPoints,
          "vehicle_type": (selectedVehicleTypeId.value ?? 1).toString(),
          "seating_capacity": int.tryParse(seatingCapacityController.text) ?? 4,
          "number_of_vehicles": int.tryParse(vehicleCountController.text) ?? 1,
          "customer_name": customerNameController.text.isEmpty ? "Walk-in Customer" : customerNameController.text,
          "customer_contact": customerPhoneController.text,
          "total_amount": totalAmount.value,
          "advance_amount": advanceAmount.value,
        };
      }

      final ResponseModel response = await _apiClient.post(AppConstants.tripsUrl, data: payload);

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchTrips();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error creating trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setDateFilter(DateTime? from, DateTime? to) {
    fromDate.value = from;
    toDate.value = to;
  }

  void clearFilters() {
    selectedFilter.value = 'All';
    fromDate.value = null;
    toDate.value = null;
    searchQuery.value = '';
  }

  void setStatus(String tripId, TripStatus newStatus) {
    // This would typically be an API call, but keeping local update for now if needed
    int index = trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      // trips[index] = trips[index].copyWith(status: newStatus); // if copyWith exists
      fetchTrips(); // Better to refresh from API
    }
  }

  Future<bool> updateTrip(String tripId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final ResponseModel response = await _apiClient.put(
        AppConstants.updateTripUrl(tripId),
        data: data,
      );

      if (response.isSuccess) {
        Get.snackbar('Success', 'Trip updated successfully');
        fetchTripDetails(tripId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTripStatus(String tripId, String status) async {
    try {
      isLoading.value = true;
      final ResponseModel response = await _apiClient.patch(
        AppConstants.updateTripStatusUrl(tripId),
        data: {'status': status},
      );

      if (response.isSuccess) {
        if (response.json != null && response.json!['data'] != null) {
          selectedTrip.value = TripModel.fromJson(response.json!['data']);
        }
        await fetchTripDetails(tripId);
        await fetchTrips();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating trip status: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addTripExpense(String tripId, Map<String, String> body, XFile? receipt) async {
    try {
      isLoading.value = true;
      
      final List<MultipartBody> multipartBody = [];
      if (receipt != null) {
        multipartBody.add(MultipartBody('receipt', receipt));
      }

      final ResponseModel response = await _apiClient.postMultipartData(
        '/api/v1/trips/$tripId/expenses',
        body,
        multipartBody,
        [],
      );

      if (response.isSuccess) {
        await fetchTripDetails(tripId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding trip expense: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTripExpenses(String tripId) async {
    try {
      isLoading.value = true;
      final ResponseModel response = await _apiClient.get('/api/v1/trips/$tripId/expenses');
      if (response.isSuccess && response.json != null) {
        final List<dynamic> data = response.json!['data'] ?? [];
        tripExpenses.assignAll(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error fetching trip expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadDutySheet(String tripId, XFile file, String notes) async {
    try {
      isLoading.value = true;
      
      final List<MultipartBody> multipartBody = [
        MultipartBody('file', file),
      ];

      final ResponseModel response = await _apiClient.postMultipartData(
        '/api/v1/trips/$tripId/duty-sheets',
        {'notes': notes},
        multipartBody,
        [],
      );

      if (response.isSuccess) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error uploading duty sheet: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDutySheets(String tripId) async {
    try {
      isLoading.value = true;
      final ResponseModel response = await _apiClient.get('/api/v1/trips/$tripId/duty-sheets');
      if (response.isSuccess && response.json != null) {
        final List<dynamic> data = response.json!['data'] ?? [];
        dutySheets.assignAll(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error fetching duty sheets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    try {
      isLoading.value = true;
      final ResponseModel response = await _apiClient.delete(
        AppConstants.deleteTripUrl(tripId),
      );

      if (response.isSuccess) {
        Get.snackbar('Success', 'Trip deleted successfully');
        fetchTrips(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    dateController.dispose();
    routeController.dispose();
    durationController.dispose();
    vehicleCountController.dispose();
    seatingCapacityController.dispose();
    pickupAddressController.dispose();
    destinationController.dispose();
    super.onClose();
  }
}
