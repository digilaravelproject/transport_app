import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models/vehicle_model.dart';
import '../domain/models/service_record_model.dart';
import '../domain/models/fuel_entry_model.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/services/network/multipart.dart';
import 'package:file_picker/file_picker.dart';

class VehicleController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  final vehicles = <VehicleModel>[].obs;
  final fuelHistory = <FuelEntryModel>[].obs;
  final filteredVehicles = <VehicleModel>[].obs;
  final isLoading = false.obs;
  final totalVehicles = 0.obs;
  final activeVehicles = 0.obs;
  final serviceVehicles = 0.obs;
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

  final serviceHistory = <ServiceRecord>[].obs;
  final repairHistory = <ServiceRecord>[].obs;
  final documents = <VehicleDocument>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicles();
    fetchVehicleStats();
    // _loadMockMaintenance();
    
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
        final List<dynamic> bodyData = response.body;
        vehicles.value = bodyData.map((json) => VehicleModel.fromJson(json)).toList();
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

  Future<void> fetchVehicleStats() async {
    try {
      final response = await _apiClient.get(AppConstants.getVehicleStatsUrl);
      if (response.isSuccess) {
        final data = response.body;
        totalVehicles.value = data['total'] ?? 0;
        activeVehicles.value = data['active'] ?? 0;
        serviceVehicles.value = data['service'] ?? 0;
      }
    } catch (e) {
      Logger.e('Error fetching vehicle stats: $e');
    }
  }

  Future<bool> addVehicle(Map<String, String> data, List<MultipartDocument> files) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.postMultipartData(
        AppConstants.vehiclesUrl,
        data,
        [],
        files,
      );

      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Vehicle added successfully');
        fetchVehicles();
        fetchVehicleStats();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('Error adding vehicle: $e');
      CustomSnackbar.showError('Something went wrong');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateVehicle(dynamic id, Map<String, String> data, List<MultipartDocument> files) async {
    isLoading.value = true;
    try {
      // For multipart update, we use POST with _method="PUT"
      data['_method'] = 'PUT';
      
      final response = await _apiClient.postMultipartData(
        AppConstants.updateVehicleUrl(id),
        data,
        [],
        files,
      );

      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Vehicle updated successfully');
        fetchVehicles();
        fetchVehicleStats();
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('Error updating vehicle: $e');
      CustomSnackbar.showError('Something went wrong');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<VehicleModel?> fetchVehicleDetails(dynamic id) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppConstants.updateVehicleUrl(id));
      if (response.isSuccess && response.body != null) {
        final body = response.body;
        // The body is already the data object (vehicle map)
        if (body is Map<String, dynamic>) {
          return VehicleModel.fromJson(body);
        }
      }
      return null;
    } catch (e) {
      Logger.e('Error fetching vehicle details: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMockMaintenance() {
    fuelHistory.value = [
      FuelEntryModel(vehicleId: 0, date: DateTime.now().subtract(const Duration(days: 2)), amount: 4500, quantity: 45.5, station: 'Reliance Petrol Pump', pricePerUnit: 98.9),
      FuelEntryModel(vehicleId: 0, date: DateTime.now().subtract(const Duration(days: 10)), amount: 5200, quantity: 50.2, station: 'HP Fuel Station', pricePerUnit: 103.5),
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

  int get activeFiltersCount {
    int count = 0;
    if (selectedFilter.value != 'All') count++;
    if (selectedTypeFilter.value != 'All') count++;
    if (selectedCapacityFilter.value != 'All') count++;
    return count;
  }

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

  void addRepairEntry(ServiceRecord record) {
    repairHistory.insert(0, record);
    Get.snackbar('Success', 'Repair entry added successfully', snackPosition: SnackPosition.BOTTOM);
  }

  void addPaymentToRepair(int id, double amount, DateTime date, {String? receiptUrl}) {
    final index = repairHistory.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = repairHistory[index];
      final newPayments = List<PaymentLog>.from(old.payments);
      newPayments.add(PaymentLog(date: date, amount: amount, receiptUrl: receiptUrl));
      
      repairHistory[index] = old.copyWith(
        paidAmount: old.paidAmount + amount,
        payments: newPayments,
      );
      Get.snackbar('Success', 'Payment recorded successfully', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void addServiceEntry(ServiceRecord record) {
    serviceHistory.insert(0, record);
    Get.snackbar('Success', 'Service entry added successfully', snackPosition: SnackPosition.BOTTOM);
  }

  void addPaymentToService(int id, double amount, DateTime date, {String? receiptUrl}) {
    final index = serviceHistory.indexWhere((s) => s.id == id);
    if (index != -1) {
      final old = serviceHistory[index];
      final newPayments = List<PaymentLog>.from(old.payments);
      newPayments.add(PaymentLog(date: date, amount: amount, receiptUrl: receiptUrl));
      
      serviceHistory[index] = old.copyWith(
        paidAmount: old.paidAmount + amount,
        payments: newPayments,
      );
      Get.snackbar('Success', 'Payment recorded successfully', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Fuel Methods
  Future<bool> addFuelEntry(dynamic vehicleId, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.post(
        AppConstants.vehicleFuelUrl(vehicleId),
        data: data,
      );
      if (response.isSuccess) {
        fetchFuelHistory(vehicleId); // Refresh history
        return true;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addFuelEntryMultipart(dynamic vehicleId, Map<String, String> body, FilePickerResult? receiptFile) async {
    isLoading.value = true;
    try {
      final List<MultipartDocument> otherFile = [];
      if (receiptFile != null && receiptFile.files.isNotEmpty) {
        otherFile.add(MultipartDocument('receipt_path', receiptFile.files.first));
      }

      final response = await _apiClient.postMultipartData(
        AppConstants.vehicleFuelUrl(vehicleId),
        body,
        [],
        otherFile,
      );
      
      if (response.isSuccess) {
        fetchFuelHistory(vehicleId);
        return true;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFuelHistory(dynamic vehicleId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppConstants.vehicleFuelUrl(vehicleId));
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body;
        fuelHistory.value = data.map((e) => FuelEntryModel.fromJson(e)).toList();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Service Methods
  Future<bool> addServiceEntryMultipart(dynamic vehicleId, Map<String, String> body, FilePickerResult? billFile) async {
    isLoading.value = true;
    try {
      final List<MultipartDocument> otherFile = [];
      if (billFile != null && billFile.files.isNotEmpty) {
        otherFile.add(MultipartDocument('receipt', billFile.files.first));
      }

      final response = await _apiClient.postMultipartData(
        AppConstants.vehicleServiceUrl(vehicleId),
        body,
        [],
        otherFile,
      );
      
      if (response.isSuccess) {
        fetchServiceHistory(vehicleId);
        return true;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchServiceHistory(dynamic vehicleId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppConstants.vehicleServiceUrl(vehicleId));
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body;
        serviceHistory.value = data.map((e) => ServiceRecord.fromJson(e)).toList();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Repair Methods
  Future<bool> addRepairEntryMultipart(dynamic vehicleId, Map<String, String> body, FilePickerResult? billFile) async {
    isLoading.value = true;
    try {
      final List<MultipartDocument> otherFile = [];
      if (billFile != null && billFile.files.isNotEmpty) {
        otherFile.add(MultipartDocument('receipt', billFile.files.first));
      }

      final response = await _apiClient.postMultipartData(
        AppConstants.vehicleRepairUrl(vehicleId),
        body,
        [],
        otherFile,
      );
      
      if (response.isSuccess) {
        fetchRepairHistory(vehicleId);
        return true;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRepairHistory(dynamic vehicleId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppConstants.vehicleRepairUrl(vehicleId));
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body;
        repairHistory.value = data.map((e) => ServiceRecord.fromJson(e)).toList();
      }
    } catch (e) {
      Logger.e('Error fetching repair history: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
