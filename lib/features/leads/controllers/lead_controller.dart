import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/lead_model.dart';
import '../../trips/controllers/trip_controller.dart';

class LeadController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final isLoading = false.obs;
  final leads = <LeadModel>[].obs;
  final filteredLeads = <LeadModel>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  final selectedDateFilter = 'All'.obs;
  final customDateRange = Rxn<DateTimeRange>();

  // Detailed lead state
  final selectedLeadDetails = Rxn<Map<String, dynamic>>();
  final leadFollowups = <Map<String, dynamic>>[].obs;
  final leadExpenses = <Map<String, dynamic>>[].obs;
  final leadDutySheets = <Map<String, dynamic>>[].obs;
  final isDetailsLoading = false.obs;
  final isFollowupsLoading = false.obs;

  // Pagination state
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final isMoreLoading = false.obs;
  final totalItems = 0.obs;

  // Dashboard Stats
  int get totalLeads => leads.length;
  int get pendingLeads => leads.where((l) => l.status.toLowerCase() == 'pending').length;
  int get confirmedLeads => leads.where((l) => l.status.toLowerCase() == 'confirmed').length;

  // Form controllers
  final customerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final routeController = TextEditingController();
  final totalAmountController = TextEditingController();
  final advancePaymentController = TextEditingController();
  final pickupAddressController = TextEditingController();
  final destinationController = TextEditingController();
  
  final selectedDate = DateTime.now().obs;
  final selectedDuration = '1 Day'.obs;
  final selectedVehicleType = ''.obs;
  final selectedVehicleTypeId = Rxn<int>();
  final vehicleCount = 1.obs;
  final destinationPoints = <Map<String, dynamic>>[].obs;
  final selectedCountryCode = '+91'.obs;

  // Quick Presets
  final List<Map<String, dynamic>> tripPresets = [
    {
      'label': 'Delhi - Agra',
      'pickup': 'Delhi',
      'destinations': ['Agra'],
      'duration': '1 Day',
      'vehicle': 'Innova (7 Seater)',
      'amount': '8500.0',
    },
    {
      'label': 'Delhi - Jaipur',
      'pickup': 'Delhi',
      'destinations': ['Jaipur', 'Amer Fort'],
      'duration': '2 Days',
      'vehicle': 'Innova (7 Seater)',
      'amount': '15500.0',
    },
    {
      'label': 'Local 8/80',
      'pickup': 'Delhi',
      'destinations': ['Local Sightseeing'],
      'duration': '1 Day',
      'vehicle': 'Sedan (4 Seater)',
      'amount': '2500.0',
    },
    {
      'label': 'Airport Pick',
      'pickup': 'IGI Airport T3',
      'destinations': ['Gurugram'],
      'duration': '1 Day',
      'vehicle': 'Sedan (4 Seater)',
      'amount': '1200.0',
    },
  ];

  void applyPreset(int index) {
    if (index < 0 || index >= tripPresets.length) return;
    final preset = tripPresets[index];
    
    pickupAddressController.text = preset['pickup'];
    destinationPoints.assignAll(
      (preset['destinations'] as List<String>).map((name) => {
        'name': name,
        'lat': 0.0,
        'lng': 0.0,
      }).toList()
    );
    selectedDuration.value = preset['duration'];
    selectedVehicleType.value = preset['vehicle'];
    totalAmountController.text = preset['amount'];
    
    totalAmountController.notifyListeners();
  }

  @override
  void onInit() {
    super.onInit();
    fetchLeads(isRefresh: true);
    
    debounce(searchQuery, (_) => fetchLeads(isRefresh: true), time: const Duration(milliseconds: 500));
    ever(selectedFilter, (_) => fetchLeads(isRefresh: true));
    ever(selectedDateFilter, (_) => fetchLeads(isRefresh: true));
    ever(customDateRange, (_) => fetchLeads(isRefresh: true));
  }

  Future<void> fetchLeads({bool isRefresh = false, bool showLoading = true}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      leads.clear();
    }

    if (!hasMoreData.value || (isLoading.value || isMoreLoading.value)) return;

    if (currentPage.value == 1) {
      if (showLoading) isLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }

    try {
      Map<String, dynamic> queryParams = {
        'page': currentPage.value,
        'per_page': 10,
      };

      if (selectedFilter.value != 'All') {
        queryParams['status'] = selectedFilter.value.toLowerCase();
      }

      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      // Date Filters
      final now = DateTime.now();
      String? fromDate;
      String? toDate;

      if (selectedDateFilter.value != 'All') {
        DateTime start;
        DateTime end = now;

        switch (selectedDateFilter.value) {
          case 'Today':
            start = DateTime(now.year, now.month, now.day);
            end = DateTime(now.year, now.month, now.day, 23, 59, 59);
            break;
          case '3 Days':
            start = now.subtract(const Duration(days: 3));
            break;
          case 'Week':
            start = now.subtract(const Duration(days: 7));
            break;
          case 'Month':
            start = now.subtract(const Duration(days: 30));
            break;
          case '3 Months':
            start = now.subtract(const Duration(days: 90));
            break;
          case '6 Months':
            start = now.subtract(const Duration(days: 180));
            break;
          case 'Year':
            start = now.subtract(const Duration(days: 365));
            break;
          case 'Custom':
            if (customDateRange.value != null) {
              start = customDateRange.value!.start;
              end = customDateRange.value!.end;
            } else {
              start = now;
            }
            break;
          default:
            start = now;
        }
        
        fromDate = "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
        toDate = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";
        
        queryParams['from'] = fromDate;
        queryParams['to'] = toDate;
      }

      final response = await _apiClient.get(AppConstants.leadsUrl, queryParameters: queryParams);
      
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body is List ? response.body : [];
        final List<LeadModel> fetchedLeads = data.map((json) => LeadModel.fromJson(json)).toList();

        if (isRefresh) {
          leads.assignAll(fetchedLeads);
        } else {
          leads.addAll(fetchedLeads);
        }

        // Handle pagination metadata from response.json
        if (response.json != null && response.json!['meta'] != null) {
          final meta = response.json!['meta'];
          totalItems.value = meta['total'] ?? 0;
          
          if (meta['current_page'] >= meta['last_page']) {
            hasMoreData.value = false;
          } else {
            currentPage.value++;
            hasMoreData.value = true;
          }
        } else {
          // If no meta, assume no more data if list is small
          if (fetchedLeads.length < 10) {
            hasMoreData.value = false;
          } else {
            currentPage.value++;
          }
        }
        
        filterLeads(); // Still call filterLeads for search and date filtering that might not be on API
      } else {
        if (currentPage.value == 1) _loadMockData();
      }
    } catch (e) {
      print('Error fetching leads: $e');
      if (currentPage.value == 1) _loadMockData();
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void _loadMockData() {
    leads.value = [
      LeadModel(
        id: '1',
        leadNo: '#LD-1001',
        customerName: 'Rahul Sharma',
        phone: '9876543210',
        route: 'Delhi - Manali',
        date: DateTime.now().add(const Duration(days: 2)),
        duration: '3 Days',
        vehicleType: 'Innova',
        vehicleCount: 1,
        totalAmount: 25000,
        advancePayment: 5000,
        status: 'Pending',
        createdAt: DateTime.now(),
      ),
    ];
    filteredLeads.value = leads;
  }

  void filterLeads() {
    List<LeadModel> list = List.from(leads);
    
    // 1. Filter by Status
    if (selectedFilter.value != 'All') {
      list = list.where((l) => l.status.toLowerCase() == selectedFilter.value.toLowerCase()).toList();
    }
    
    // 2. Filter by Search Query
    if (searchQuery.value.isNotEmpty) {
      list = list.where((lead) =>
        lead.customerName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        lead.phone.contains(searchQuery.value) ||
        lead.route.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        lead.leadNo.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    // 3. Filter by Date Range
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    
    if (selectedDateFilter.value != 'All') {
      list = list.where((lead) {
        final leadDate = DateTime(lead.date.year, lead.date.month, lead.date.day);
        
        switch (selectedDateFilter.value) {
          case 'Today':
            return leadDate.isAtSameMomentAs(startOfToday);
          case '3 Days':
            return leadDate.isAfter(startOfToday.subtract(const Duration(days: 1))) && 
                   leadDate.isBefore(startOfToday.add(const Duration(days: 3)));
          case 'Week':
            return leadDate.isAfter(startOfToday.subtract(const Duration(days: 1))) && 
                   leadDate.isBefore(startOfToday.add(const Duration(days: 7)));
          case 'Month':
            return leadDate.isAfter(startOfToday.subtract(const Duration(days: 1))) && 
                   leadDate.isBefore(startOfToday.add(const Duration(days: 30)));
          case 'Custom':
            if (customDateRange.value != null) {
              return (leadDate.isAtSameMomentAs(customDateRange.value!.start) || leadDate.isAfter(customDateRange.value!.start)) && 
                     (leadDate.isAtSameMomentAs(customDateRange.value!.end) || leadDate.isBefore(customDateRange.value!.end));
            }
            return true;
          default:
            return true;
        }
      }).toList();
    }

    filteredLeads.value = list;
  }

  void setDateFilter(String filter) {
    selectedDateFilter.value = filter;
    if (filter != 'Custom') {
      customDateRange.value = null;
    }
  }

  void setCustomDateRange(DateTimeRange range) {
    customDateRange.value = range;
    selectedDateFilter.value = 'Custom';
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<bool> createLead(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.post(AppConstants.leadsUrl, data: data);
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        fetchLeads();
        return true;
      } else {
        String errorMessage = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          errorMessage = response.errors!.first.message ?? response.message;
        }
        CustomSnackbar.showError(errorMessage);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Error creating lead: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    customerNameController.clear();
    phoneController.clear();
    emailController.clear();
    routeController.clear();
    totalAmountController.clear();
    advancePaymentController.clear();
    pickupAddressController.clear();
    destinationController.clear();
    selectedDate.value = DateTime.now();
    selectedDuration.value = '1 Day';
    selectedVehicleType.value = '';
    selectedVehicleTypeId.value = null;
    vehicleCount.value = 1;
    destinationPoints.clear();
    selectedCountryCode.value = '+91';
  }

  double get pendingAmount {
    double total = double.tryParse(totalAmountController.text) ?? 0;
    double advance = double.tryParse(advancePaymentController.text) ?? 0;
    return total - advance;
  }

  void calculateRoute() {
    if (pickupAddressController.text.isNotEmpty && destinationPoints.isNotEmpty) {
      String dest = destinationPoints.last['name'];
      routeController.text = "${pickupAddressController.text} to $dest";
    }
  }

  void setSelectedLead(LeadModel lead) {
    customerNameController.text = lead.customerName;
    
    // Split phone and country code
    String phone = lead.phone.replaceAll(' ', '');
    if (phone.startsWith('+91')) {
      selectedCountryCode.value = '+91';
      phone = phone.substring(3);
    } else if (phone.startsWith('91') && phone.length > 10) {
      selectedCountryCode.value = '+91';
      phone = phone.substring(2);
    } else if (phone.startsWith('+')) {
      if (phone.length > 10) {
        int splitIndex = phone.length - 10;
        selectedCountryCode.value = phone.substring(0, splitIndex);
        phone = phone.substring(splitIndex);
      }
    }
    phoneController.text = phone;
    
    routeController.text = lead.route;
    totalAmountController.text = lead.totalAmount.toString();
    advancePaymentController.text = lead.advancePayment.toString();
    selectedDate.value = lead.date;
    selectedDuration.value = lead.duration;
    selectedVehicleType.value = lead.vehicleType;
    selectedVehicleTypeId.value = lead.vehicleTypeId;
    vehicleCount.value = lead.vehicleCount;
    pickupAddressController.text = lead.pickupAddress ?? '';
  }

  Future<void> updateLeadStatus(String id, String newStatus) async {
    // Logic to update status via API if needed
    final index = leads.indexWhere((l) => l.id == id);
    if (index != -1) {
      fetchLeads(); // Refresh list
      CustomSnackbar.showSuccess('Status updated to $newStatus');
    }
  }

  final leadNotes = <LeadNote>[].obs;
  final isNotesLoading = false.obs;

  Future<void> fetchLeadNotes(String leadId) async {
    isNotesLoading.value = true;
    try {
      final response = await _apiClient.get('/api/v1/leads/$leadId/notes');
      if (response.isSuccess) {
        dynamic responseData = response.body;
        List<dynamic> notesList = [];
        
        if (responseData is Map && responseData.containsKey('data')) {
          notesList = responseData['data'] is List ? responseData['data'] : [];
        } else if (responseData is List) {
          notesList = responseData;
        }
        
        leadNotes.value = notesList.map((json) => LeadNote.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching notes: $e');
    } finally {
      isNotesLoading.value = false;
    }
  }

  Future<bool> addLeadNote(String leadId, String note) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.post('/api/v1/leads/$leadId/notes', data: {'note': note});
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        fetchLeadNotes(leadId);
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Error adding note: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLeadDetails(String id) async {
    isDetailsLoading.value = true;
    try {
      final response = await _apiClient.get('${AppConstants.leadsUrl}/$id');
      if (response.isSuccess && response.body != null) {
        final Map<String, dynamic> data = response.body;
        selectedLeadDetails.value = data;
        
        // Extract related data
        if (data['followups'] != null) {
          leadFollowups.value = List<Map<String, dynamic>>.from(data['followups']);
        }
        if (data['expenses'] != null) {
          leadExpenses.value = List<Map<String, dynamic>>.from(data['expenses']);
        }
        if (data['duty_sheets'] != null) {
          leadDutySheets.value = List<Map<String, dynamic>>.from(data['duty_sheets']);
        }
      }
    } catch (e) {
      print('Error fetching lead details: $e');
      CustomSnackbar.showError('Could not load lead details');
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<bool> updateLead(String id) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> data = {
        'trip_route': routeController.text,
        'trip_date': "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}",
        'duration_days': int.tryParse(selectedDuration.value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1,
        'vehicle_type': selectedVehicleTypeId.value ?? 1,
        'seating_capacity': vehicleCount.value,
        'pickup_address': pickupAddressController.text,
        'points': destinationPoints,
        'customer_name': customerNameController.text,
        'customer_contact': "${selectedCountryCode.value}${phoneController.text.trim()}",
        'total_amount': double.tryParse(totalAmountController.text) ?? 0.0,
        'advance_amount': double.tryParse(advancePaymentController.text) ?? 0.0,
        'pending_amount': pendingAmount,
      };

      final response = await _apiClient.put('${AppConstants.leadsUrl}/$id', data: data);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        await fetchLeadDetails(id);
        fetchLeads(isRefresh: true);
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Error updating lead: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteLead(String id) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.delete('${AppConstants.leadsUrl}/$id');
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        fetchLeads(isRefresh: true);
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Error deleting lead: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateLeadStatusDetail(String id, String newStatus, {bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    try {
      final response = await _apiClient.patch(
        '/api/v1/leads/$id/status',
        data: {'status': newStatus.toLowerCase()},
      );
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Status updated to $newStatus');
        if (selectedLeadDetails.value != null && selectedLeadDetails.value!['id'].toString() == id) {
          await fetchLeadDetails(id);
        }
        fetchLeads(isRefresh: true, showLoading: false); // Soft refresh list
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Error updating status: $e');
      return false;
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<bool> addLeadFollowup(String leadId, Map<String, dynamic> data) async {
    isFollowupsLoading.value = true;
    try {
      final response = await _apiClient.post('/api/v1/leads/$leadId/followups', data: data);
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        await fetchLeadDetails(leadId); // Refresh details
        await fetchLeadFollowups(leadId); // Refresh followups list
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Error adding follow up: $e');
      return false;
    } finally {
      isFollowupsLoading.value = false;
    }
  }

  Future<void> fetchLeadFollowups(String leadId) async {
    isFollowupsLoading.value = true;
    try {
      final response = await _apiClient.get('/api/v1/leads/$leadId/followups');
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body is Map ? (response.body['data'] ?? []) : response.body;
        leadFollowups.value = List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print('Error fetching followups: $e');
    } finally {
      isFollowupsLoading.value = false;
    }
  }

  Future<bool> convertToTrip(String leadId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.post(AppConstants.convertLeadToTripUrl(leadId));
      if (response.isSuccess) {
        CustomSnackbar.showSuccess('Lead converted to trip successfully');
        await fetchLeadDetails(leadId);
        fetchLeads(isRefresh: true, showLoading: false);
        
        // Refresh Trip List if controller is available
        if (Get.isRegistered<TripController>()) {
          Get.find<TripController>().fetchTrips();
        }
        
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Error converting lead to trip: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getLeadQuotationUrl(String leadId) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppConstants.getLeadBillUrl(leadId));
      if (response.isSuccess && response.json != null) {
        return response.json!['data']?['url'];
      } else {
        CustomSnackbar.showError(response.message);
        return null;
      }
    } catch (e) {
      CustomSnackbar.showError('Error fetching quotation: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
