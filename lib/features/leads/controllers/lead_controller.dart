import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models/lead_model.dart';

class LeadController extends GetxController {
  final isLoading = false.obs;
  final leads = <LeadModel>[].obs;
  final filteredLeads = <LeadModel>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;

  // Dashboard Stats
  int get totalLeads => leads.length;
  int get pendingLeads => leads.where((l) => l.status == 'Pending').length;
  int get confirmedLeads => leads.where((l) => l.status == 'Confirmed').length;

  // Form controllers
  final customerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final routeController = TextEditingController();
  final totalAmountController = TextEditingController();
  final advancePaymentController = TextEditingController();
  final pickupAddressController = TextEditingController();
  
  final selectedDate = DateTime.now().obs;
  final selectedDuration = '1 Day'.obs;
  final selectedVehicleType = 'Sedan'.obs;
  final vehicleCount = 1.obs;
  final destinationPoints = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
    
    // Setup search listener
    debounce(searchQuery, (_) => filterLeads(), time: const Duration(milliseconds: 500));
    ever(selectedFilter, (_) => filterLeads());
  }

  void fetchLeads() {
    // Mock data for initial development
    leads.value = [
      LeadModel(
        id: '1',
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
      LeadModel(
        id: '2',
        customerName: 'Amit Verma',
        phone: '9988776655',
        route: 'Noida - Jaipur',
        date: DateTime.now().add(const Duration(days: 5)),
        duration: '2 Days',
        vehicleType: 'Tempo Traveller',
        vehicleCount: 1,
        totalAmount: 18000,
        advancePayment: 18000,
        status: 'Confirmed',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    filteredLeads.value = leads;
  }

  void filterLeads() {
    List<LeadModel> list = List.from(leads);
    if (selectedFilter.value != 'All') {
      list = list.where((l) => l.status == selectedFilter.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list.where((lead) =>
        lead.customerName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        lead.phone.contains(searchQuery.value) ||
        lead.route.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    filteredLeads.value = list;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void resetForm() {
    customerNameController.clear();
    phoneController.clear();
    emailController.clear();
    routeController.clear();
    totalAmountController.clear();
    advancePaymentController.clear();
    pickupAddressController.clear();
    selectedDate.value = DateTime.now();
    selectedDuration.value = '1 Day';
    selectedVehicleType.value = 'Sedan';
    vehicleCount.value = 1;
    destinationPoints.clear();
  }

  void addDestination(String point) {
    if (point.isNotEmpty) {
      destinationPoints.add(point);
    }
  }

  void removeDestination(int index) {
    destinationPoints.removeAt(index);
  }

  double get pendingAmount {
    double total = double.tryParse(totalAmountController.text) ?? 0;
    double advance = double.tryParse(advancePaymentController.text) ?? 0;
    return total - advance;
  }

  // --- CRUD Operations ---

  void addLead() {
    final newLead = LeadModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate simple unique ID
      customerName: customerNameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      route: routeController.text.trim(),
      date: selectedDate.value,
      duration: selectedDuration.value,
      vehicleType: selectedVehicleType.value,
      vehicleCount: vehicleCount.value,
      pickupAddress: pickupAddressController.text.trim(),
      destinationPoints: List.from(destinationPoints),
      totalAmount: double.tryParse(totalAmountController.text) ?? 0,
      advancePayment: double.tryParse(advancePaymentController.text) ?? 0,
      status: 'Pending',
      createdAt: DateTime.now(),
    );

    leads.add(newLead);
    filterLeads();
    Get.back();
    Get.snackbar(
      'Success',
      'Lead added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }

  void updateLead(String id) {
    final index = leads.indexWhere((l) => l.id == id);
    if (index != -1) {
      final updatedLead = LeadModel(
        id: id,
        customerName: customerNameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        route: routeController.text.trim(),
        date: selectedDate.value,
        duration: selectedDuration.value,
        vehicleType: selectedVehicleType.value,
        vehicleCount: vehicleCount.value,
        pickupAddress: pickupAddressController.text.trim(),
        destinationPoints: List.from(destinationPoints),
        totalAmount: double.tryParse(totalAmountController.text) ?? 0,
        advancePayment: double.tryParse(advancePaymentController.text) ?? 0,
        status: leads[index].status, // Preserve existing status
        createdAt: leads[index].createdAt, // Preserve creation date
      );

      leads[index] = updatedLead;
      filterLeads();
      Get.back();
      Get.snackbar(
        'Success',
        'Lead updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void deleteLead(String id) {
    leads.removeWhere((l) => l.id == id);
    filterLeads();
    Get.back(); // Usually called from details or bottom sheet
    Get.snackbar(
      'Deleted',
      'Lead removed perfectly',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }

  void updateLeadStatus(String id, String newStatus) {
    final index = leads.indexWhere((l) => l.id == id);
    if (index != -1) {
      final oldLead = leads[index];
      leads[index] = LeadModel(
        id: oldLead.id,
        customerName: oldLead.customerName,
        phone: oldLead.phone,
        email: oldLead.email,
        route: oldLead.route,
        date: oldLead.date,
        duration: oldLead.duration,
        vehicleType: oldLead.vehicleType,
        vehicleCount: oldLead.vehicleCount,
        pickupAddress: oldLead.pickupAddress,
        destinationPoints: oldLead.destinationPoints,
        totalAmount: oldLead.totalAmount,
        advancePayment: oldLead.advancePayment,
        status: newStatus, // Updated status
        createdAt: oldLead.createdAt,
      );
      filterLeads();
      Get.snackbar(
        'Status Updated',
        'Lead marked as $newStatus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }
}
