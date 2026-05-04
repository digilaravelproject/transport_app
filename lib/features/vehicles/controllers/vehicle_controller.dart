import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models/vehicle_model.dart';
import '../domain/models/service_record_model.dart';
import '../domain/models/fuel_entry_model.dart';
import '../domain/models/timeline_record_model.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/services/network/multipart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

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

  // Fuel Stats
  final totalFuelExpense = 0.0.obs;
  final monthlyFuelCost = 0.0.obs;
  final avgFuelPrice = 0.0.obs;

  // Service Stats
  final totalServiceAmount = 0.0.obs;
  final paidServiceAmount = 0.0.obs;
  final dueServiceAmount = 0.0.obs;

  // Repair Stats
  final totalRepairAmount = 0.0.obs;
  final paidRepairAmount = 0.0.obs;
  final dueRepairAmount = 0.0.obs;

  var serviceHistory = <ServiceRecord>[].obs;
  var repairHistory = <ServiceRecord>[].obs;
  var vehicleDocuments = <VehicleDocument>[].obs;
  var timelineHistory = <TimelineRecord>[].obs;
  final documents = <VehicleDocument>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicles();
    fetchVehicleStats();
    // _loadMockMaintenance();
    
    debounce(searchQuery, (_) => fetchVehicles(), time: const Duration(milliseconds: 500));
    ever(selectedFilter, (_) => fetchVehicles());

    // Service/Repair filter listeners
    ever(selectedServiceFilter, (_) => _refreshServiceHistory());
    ever(serviceStartDate, (_) => _refreshServiceHistory());
    ever(serviceEndDate, (_) => _refreshServiceHistory());

    ever(selectedRepairFilter, (_) => _refreshRepairHistory());
    ever(repairStartDate, (_) => _refreshRepairHistory());
    ever(repairEndDate, (_) => _refreshRepairHistory());
  }

  void _refreshServiceHistory() {
    final dynamic args = Get.arguments;
    final id = (args is Map) ? args['vehicle']?.id : (args is VehicleModel ? args.id : null);
    if (id != null) fetchServiceHistory(id);
  }

  void _refreshRepairHistory() {
    final dynamic args = Get.arguments;
    final id = (args is Map) ? args['vehicle']?.id : (args is VehicleModel ? args.id : null);
    if (id != null) fetchRepairHistory(id);
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
        CustomSnackbar.showError(response.message);
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
          type: 'Registration Certificate (RC)',
          number: 'MOCK-123',
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

  List<ServiceRecord> get filteredRepairHistory => repairHistory;

  List<ServiceRecord> get filteredServiceHistory => serviceHistory;

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
    if (filter == 'All') {
      clearRepairDateRange();
    }
  }

  void setServiceFilter(String filter) {
    selectedServiceFilter.value = filter;
    if (filter == 'All') {
      clearServiceDateRange();
    }
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

  Future<bool> addPaymentToRepair(dynamic vehicleId, int id, double amount, DateTime date, {String? notes, PlatformFile? receiptFile}) async {
    isLoading.value = true;
    try {
      final Map<String, String> body = {
        'amount': amount.toString(),
        'payment_date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'notes': notes ?? 'Payment for repair',
      };

      final List<MultipartDocument> otherFile = [];
      if (receiptFile != null) {
        otherFile.add(MultipartDocument('receipt', receiptFile));
      }

      final response = await _apiClient.postMultipartData(
        AppConstants.vehicleRepairPaymentUrl(vehicleId, id),
        body,
        [],
        otherFile,
      );
      
      if (response.isSuccess) {
        fetchRepairHistory(vehicleId);
        fetchRepairDetails(vehicleId, id);
        return true;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addPaymentToService(dynamic vehicleId, int id, double amount, DateTime date, {String? notes, PlatformFile? receiptFile}) async {
    isLoading.value = true;
    try {
      final Map<String, String> body = {
        'amount': amount.toString(),
        'payment_date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'notes': notes ?? 'Payment for service',
      };

      final List<MultipartDocument> otherFile = [];
      if (receiptFile != null) {
        otherFile.add(MultipartDocument('receipt', receiptFile));
      }

      final response = await _apiClient.postMultipartData(
        AppConstants.vehicleServicePaymentUrl(vehicleId, id),
        body,
        [],
        otherFile,
      );
      
      if (response.isSuccess) {
        fetchServiceHistory(vehicleId);
        fetchServiceDetails(vehicleId, id);
        return true;
      }
      return false;
    } finally {
      isLoading.value = false;
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
        otherFile.add(MultipartDocument('receipt', receiptFile.files.first));
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
      if (response.isSuccess && response.json != null) {
        final json = response.json!;
        
        // Update Stats
        totalFuelExpense.value = (json['total_fuel_expense'] ?? 0).toDouble();
        monthlyFuelCost.value = (json['monthly_cost'] ?? 0).toDouble();
        avgFuelPrice.value = (json['avg_ltr_price'] ?? 0).toDouble();

        // Update List
        final List<dynamic> data = json['data'] ?? [];
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
    if (vehicleId == null) return;
    isLoading.value = true;
    try {
      final Map<String, dynamic> queryParams = {
        'per_page': 20,
      };

      if (selectedServiceFilter.value != 'All') {
        queryParams['status'] = selectedServiceFilter.value.toLowerCase();
      }

      if (serviceStartDate.value != null) {
        queryParams['start_date'] = '${serviceStartDate.value!.year}-${serviceStartDate.value!.month.toString().padLeft(2, '0')}-${serviceStartDate.value!.day.toString().padLeft(2, '0')}';
      }

      if (serviceEndDate.value != null) {
        queryParams['end_date'] = '${serviceEndDate.value!.year}-${serviceEndDate.value!.month.toString().padLeft(2, '0')}-${serviceEndDate.value!.day.toString().padLeft(2, '0')}';
      }

      final response = await _apiClient.get(
        AppConstants.vehicleServiceUrl(vehicleId),
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.json != null) {
        final json = response.json!;

        // Update Stats
        totalServiceAmount.value = (json['total_amount'] ?? 0).toDouble();
        paidServiceAmount.value = (json['pay_amount'] ?? 0).toDouble();
        dueServiceAmount.value = (json['due_amount'] ?? 0).toDouble();

        // Update List
        final List<dynamic> data = json['data'] ?? [];
        serviceHistory.value = data.map((e) => ServiceRecord.fromJson(e)).toList();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchServiceDetails(dynamic vehicleId, int serviceId) async {
    try {
      final response = await _apiClient.get(AppConstants.vehicleServiceDetailsUrl(vehicleId, serviceId));
      if (response.isSuccess && response.json != null) {
        final newRecord = ServiceRecord.fromJson(response.json!['data']);
        final index = serviceHistory.indexWhere((s) => s.id == serviceId);
        if (index != -1) {
          serviceHistory[index] = newRecord;
        } else {
          serviceHistory.add(newRecord);
        }
      }
    } catch (e) {
      debugPrint('Error fetching service details: $e');
    }
  }

  Future<void> fetchRepairDetails(dynamic vehicleId, int repairId) async {
    try {
      final response = await _apiClient.get(AppConstants.vehicleRepairDetailsUrl(vehicleId, repairId));
      if (response.isSuccess && response.json != null) {
        final newRecord = ServiceRecord.fromJson(response.json!['data']);
        final index = repairHistory.indexWhere((r) => r.id == repairId);
        if (index != -1) {
          repairHistory[index] = newRecord;
        } else {
          repairHistory.add(newRecord);
        }
      }
    } catch (e) {
      debugPrint('Error fetching repair details: $e');
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
    if (vehicleId == null) return;
    isLoading.value = true;
    try {
      final Map<String, dynamic> queryParams = {
        'per_page': 20,
      };

      if (selectedRepairFilter.value != 'All') {
        queryParams['status'] = selectedRepairFilter.value.toLowerCase();
      }

      if (repairStartDate.value != null) {
        queryParams['start_date'] = '${repairStartDate.value!.year}-${repairStartDate.value!.month.toString().padLeft(2, '0')}-${repairStartDate.value!.day.toString().padLeft(2, '0')}';
      }

      if (repairEndDate.value != null) {
        queryParams['end_date'] = '${repairEndDate.value!.year}-${repairEndDate.value!.month.toString().padLeft(2, '0')}-${repairEndDate.value!.day.toString().padLeft(2, '0')}';
      }

      final response = await _apiClient.get(
        AppConstants.vehicleRepairUrl(vehicleId),
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.json != null) {
        final json = response.json!;

        // Update Stats
        totalRepairAmount.value = (json['total_amount'] ?? 0).toDouble();
        paidRepairAmount.value = (json['pay_amount'] ?? 0).toDouble();
        dueRepairAmount.value = (json['due_amount'] ?? 0).toDouble();

        // Update List
        final List<dynamic> data = json['data'] ?? [];
        repairHistory.value = data.map((e) => ServiceRecord.fromJson(e)).toList();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVehicleDocuments(dynamic vehicleId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppConstants.vehicleDocumentsUrl(vehicleId));
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body;
        vehicleDocuments.value = data.map((e) => VehicleDocument.fromJson(e)).toList();
        // Also update 'documents' if it's used elsewhere
        documents.value = vehicleDocuments;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVehicleTimeline(dynamic vehicleId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppConstants.vehicleTimelineUrl(vehicleId));
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body;
        timelineHistory.value = data.map((e) => TimelineRecord.fromJson(e)).toList();
      }
    } catch (e) {
      Logger.e('Error fetching vehicle timeline: $e');
    } finally {
      isLoading.value = false;
    }
  }

/*
  Future<bool> uploadDocument({
    required dynamic vehicleId,
    required String documentType,
    required String documentNumber,
    required DateTime issueDate,
    required DateTime expiryDate,
    required PlatformFile file,
    String notes = 'Registration certificate',
    int alertBeforeDays = 30,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, String> body = {
        'vehicle_id': vehicleId.toString(),
        'document_type': documentType,
        'document_number': documentNumber,
        'issue_date': issueDate.toIso8601String().split('T')[0],
        'expiry_date': expiryDate.toIso8601String().split('T')[0],
        'alert_before_days': alertBeforeDays.toString(),
        'notes': notes,
      };

      final response = await _apiClient.postMultipartData(
        AppConstants.vehicleDocumentsUrl(vehicleId),
        body,
        [],
        [MultipartDocument('file', file)],
      );

      if (response.isSuccess) {
        fetchVehicleDocuments(vehicleId);
        return true;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
*/


  Future<bool> uploadDocument({
    required int vehicleId, // 🔥 dynamic hata ke proper type use karo
    required String documentType,
    required String documentNumber,
    required DateTime issueDate,
    required DateTime expiryDate,
    required PlatformFile file,
    String notes = 'Registration certificate',
    int alertBeforeDays = 30,
  }) async {
    isLoading.value = true;

    try {
      final Map<String, String> body = {
        'document_type': documentType,
        'document_number': documentNumber,
        'issue_date': issueDate.toIso8601String().split('T').first,
        'expiry_date': expiryDate.toIso8601String().split('T').first,
        'alert_before_days': alertBeforeDays.toString(),
        'notes': notes,
      };

      // 🔥 File null/bytes check
      if (file.bytes == null && file.path == null) {
        throw Exception('Invalid file selected');
      }

      final response = await _apiClient.postMultipartData(
        AppConstants.vehicleDocumentsUrl(vehicleId),
        body,
        [],
        [
          MultipartDocument(
            'file',
            file,
          ),
        ],
      );

      if (response.isSuccess) {
        await fetchVehicleDocuments(vehicleId); // 🔥 await add karo
        return true;
      } else {
        debugPrint('Upload failed: ${response.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
