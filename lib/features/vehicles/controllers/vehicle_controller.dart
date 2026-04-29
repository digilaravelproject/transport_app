import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models/vehicle_model.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

class VehicleController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  final vehicles = <VehicleModel>[].obs;
  final filteredVehicles = <VehicleModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs; // Status: All, Active, Maintenance
  final selectedTypeFilter = 'All'.obs;
  final selectedCapacityFilter = 'All'.obs;
  final selectedRepairFilter = 'All'.obs;
  final selectedServiceFilter = 'All'.obs;
  final repairStartDate = Rxn<DateTime>();
  final repairEndDate = Rxn<DateTime>();
  final serviceStartDate = Rxn<DateTime>();
  final serviceEndDate = Rxn<DateTime>();

  final fuelHistory = <FuelEntry>[].obs;
  final serviceHistory = <ServiceRecord>[].obs;
  final repairHistory = <ServiceRecord>[].obs;
  final documents = <VehicleDocument>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicles();
    _loadMockMaintenance();
    
    debounce(searchQuery, (_) => fetchVehicles(), time: const Duration(milliseconds: 500));
    ever(selectedFilter, (_) => fetchVehicles());
    ever(selectedTypeFilter, (_) => fetchVehicles());
    ever(selectedCapacityFilter, (_) => fetchVehicles());
  }

  Future<void> fetchVehicles() async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> queryParams = {
        'search': searchQuery.value,
        'per_page': 50,
      };

      if (selectedFilter.value != 'All') {
        queryParams['status'] = selectedFilter.value.toLowerCase();
      }

      if (selectedTypeFilter.value != 'All') {
        queryParams['type[]'] = [selectedTypeFilter.value];
      }

      if (selectedCapacityFilter.value != 'All') {
        if (selectedCapacityFilter.value == '< 30') {
          queryParams['capacity_range'] = '0-30';
        } else if (selectedCapacityFilter.value == '30 - 45') {
          queryParams['capacity_range'] = '30-45';
        } else if (selectedCapacityFilter.value == '> 45') {
          queryParams['capacity_range'] = '45-200';
        }
      }

      final response = await _apiClient.get(
        AppConstants.getVehiclesUrl,
        queryParameters: queryParams,
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        vehicles.value = data.map((json) => VehicleModel.fromJson(json)).toList();
        filteredVehicles.assignAll(vehicles);
      } else {
        Logger.e('Failed to fetch vehicles: ${response.message}');
      }
    } catch (e) {
      Logger.e('Error fetching vehicles: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMockMaintenance() {
    fuelHistory.value = [
      FuelEntry(date: DateTime.now().subtract(const Duration(days: 2)), amount: 4500, quantity: 45.5, station: 'Reliance Petrol Pump'),
      FuelEntry(date: DateTime.now().subtract(const Duration(days: 10)), amount: 5200, quantity: 50.2, station: 'HP Fuel Station'),
    ];

    serviceHistory.value = [
      ServiceRecord(
          id: 1,
          date: DateTime.now().subtract(const Duration(days: 30)),
          type: 'Full Service',
          totalBill: 12500,
          paidAmount: 12500,
          workshop: 'Tata Authorized Service Center',
          payments: [
            PaymentLog(date: DateTime.now().subtract(const Duration(days: 30)), amount: 12500),
          ]),
    ];

    repairHistory.value = [
      ServiceRecord(
          id: 3,
          date: DateTime.now().subtract(const Duration(days: 5)),
          type: 'Brake Pad Replacement',
          totalBill: 4500,
          paidAmount: 3000,
          workshop: 'City Garage',
          payments: [
            PaymentLog(date: DateTime.now().subtract(const Duration(days: 5)), amount: 3000),
          ]),
    ];

    documents.value = [
      VehicleDocument(
          name: 'Registration Certificate (RC)',
          uploadDate: DateTime.now().subtract(const Duration(days: 365)),
          expiryDate: DateTime.now().add(const Duration(days: 365 * 10)),
          fileUrl: 'rc.pdf'),
    ];
  }

  double get totalMaintenanceSpent =>
      serviceHistory.fold(0.0, (sum, item) => sum + item.totalBill) +
      repairHistory.fold(0.0, (sum, item) => sum + item.totalBill);

  double get totalMaintenancePaid =>
      serviceHistory.fold(0.0, (sum, item) => sum + item.paidAmount) +
      repairHistory.fold(0.0, (sum, item) => sum + item.paidAmount);

  double get totalMaintenanceDue => totalMaintenanceSpent - totalMaintenancePaid;

  List<ServiceRecord> get filteredRepairHistory {
    List<ServiceRecord> list = List.from(repairHistory);
    if (selectedRepairFilter.value == 'Pending') {
      list = list.where((r) => r.pendingAmount > 0).toList();
    } else if (selectedRepairFilter.value == 'Paid') {
      list = list.where((r) => r.pendingAmount == 0).toList();
    }
    if (repairStartDate.value != null) {
      list = list.where((r) => r.date.isAfter(repairStartDate.value!) || r.date.isAtSameMomentAs(repairStartDate.value!)).toList();
    }
    if (repairEndDate.value != null) {
      final end = repairEndDate.value!.add(const Duration(days: 1));
      list = list.where((r) => r.date.isBefore(end)).toList();
    }
    return list;
  }

  List<ServiceRecord> get filteredServiceHistory {
    List<ServiceRecord> list = List.from(serviceHistory);
    if (selectedServiceFilter.value == 'Pending') {
      list = list.where((s) => s.pendingAmount > 0).toList();
    } else if (selectedServiceFilter.value == 'Paid') {
      list = list.where((s) => s.pendingAmount == 0).toList();
    }
    if (serviceStartDate.value != null) {
      list = list.where((s) => s.date.isAfter(serviceStartDate.value!) || s.date.isAtSameMomentAs(serviceStartDate.value!)).toList();
    }
    if (serviceEndDate.value != null) {
      final end = serviceEndDate.value!.add(const Duration(days: 1));
      list = list.where((s) => s.date.isBefore(end)).toList();
    }
    return list;
  }

  void resetFilters() {
    selectedFilter.value = 'All';
    selectedTypeFilter.value = 'All';
    selectedCapacityFilter.value = 'All';
    searchQuery.value = '';
    fetchVehicles();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setTypeFilter(String type) {
    selectedTypeFilter.value = type;
  }

  void setCapacityFilter(String capacity) {
    selectedCapacityFilter.value = capacity;
  }

  void setRepairFilter(String filter) {
    selectedRepairFilter.value = filter;
  }

  void setServiceFilter(String filter) {
    selectedServiceFilter.value = filter;
  }

  void setRepairDateRange(DateTime? start, DateTime? end) {
    repairStartDate.value = start;
    repairEndDate.value = end;
  }

  void setServiceDateRange(DateTime? start, DateTime? end) {
    serviceStartDate.value = start;
    serviceEndDate.value = end;
  }

  void clearRepairDateRange() {
    repairStartDate.value = null;
    repairEndDate.value = null;
  }

  void clearServiceDateRange() {
    serviceStartDate.value = null;
    serviceEndDate.value = null;
  }

  void updateVehicleStatus(VehicleModel vehicle, VehicleStatus newStatus) {
    // This would likely be an API call in a real app
    final index = vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      vehicles[index] = vehicle.copyWith(status: newStatus);
      Get.snackbar(
        'Status Updated',
        'Vehicle ${vehicle.vehicleNumber} is now ${newStatus.name.capitalizeFirst}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white.withOpacity(0.9),
      );
    }
  }
}
