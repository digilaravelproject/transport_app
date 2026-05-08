import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models/trip_model.dart';

class TripController extends GetxController {
  // Observable variables
  var trips = <TripModel>[].obs;
  var filteredTrips = <TripModel>[].obs;
  var searchQuery = ''.obs;
  var selectedFilter = 'All'.obs;
  var isLoading = false.obs;

  // Form Controllers for Create Trip
  final dateController = TextEditingController();
  final routeController = TextEditingController();
  final durationController = TextEditingController();
  final vehicleCountController = TextEditingController();
  final seatingCapacityController = TextEditingController();
  
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

  @override
  void onInit() {
    super.onInit();
    _loadMockTrips();
    
    // Listen to search query changes
    debounce(searchQuery, (_) => _filterTrips(), time: const Duration(milliseconds: 300));
    ever(selectedFilter, (_) => _filterTrips());

    totalAmountController.addListener(() {
      totalAmount.value = double.tryParse(totalAmountController.text) ?? 0.0;
    });
    advanceAmountController.addListener(() {
      advanceAmount.value = double.tryParse(advanceAmountController.text) ?? 0.0;
    });
  }

  void _loadMockTrips() {
    trips.assignAll([
      TripModel(
        id: '1',
        route: 'Delhi to Jaipur',
        date: DateTime.now().add(const Duration(days: 1)),
        duration: '2 Days',
        tripType: 'Round Trip',
        vehicleType: 'Luxury Bus',
        vehicleCount: 1,
        seatingCapacity: 45,
        driverName: 'Rajesh Kumar',
        vehicleNumber: 'DL 01 AB 1234',
        customerName: 'Amit Shah',
        customerPhone: '9876543210',
        totalAmount: 15000.0,
        advanceAmount: 5000.0,
        pendingAmount: 10000.0,
        status: TripStatus.pending,
      ),
      TripModel(
        id: '2',
        route: 'Mumbai to Pune',
        date: DateTime.now(),
        duration: '1 Day',
        tripType: 'One Way',
        vehicleType: 'Mini Bus',
        vehicleCount: 2,
        seatingCapacity: 25,
        driverName: 'Suresh Patil',
        vehicleNumber: 'MH 12 CD 5678',
        customerName: 'Priya Verma',
        customerPhone: '8765432109',
        totalAmount: 8500.0,
        advanceAmount: 8500.0,
        pendingAmount: 0.0,
        status: TripStatus.ongoing,
      ),
      TripModel(
        id: '3',
        route: 'Bangalore to Mysore',
        date: DateTime.now().subtract(const Duration(days: 2)),
        duration: '1 Day',
        tripType: 'Round Trip',
        vehicleType: 'Innova',
        vehicleCount: 1,
        seatingCapacity: 7,
        driverName: 'Karthik Rao',
        vehicleNumber: 'KA 05 EF 9012',
        customerName: 'Rahul Dravid',
        customerPhone: '7654321098',
        totalAmount: 12000.0,
        advanceAmount: 12000.0,
        pendingAmount: 0.0,
        status: TripStatus.completed,
      ),
    ]);
    filteredTrips.assignAll(trips);
  }

  void _filterTrips() {
    List<TripModel> list = List.from(trips);
    if (selectedFilter.value == 'Pending') {
      list = list.where((t) => t.status == TripStatus.pending).toList();
    } else if (selectedFilter.value == 'Ongoing') {
      list = list.where((t) => t.status == TripStatus.ongoing).toList();
    } else if (selectedFilter.value == 'Completed') {
      list = list.where((t) => t.status == TripStatus.completed).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list.where((trip) =>
        trip.route.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        (trip.driverName?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
      ).toList();
    }
    filteredTrips.assignAll(list);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setStatus(String tripId, TripStatus newStatus) {
    int index = trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      trips[index] = TripModel(
        id: trips[index].id,
        route: trips[index].route,
        date: trips[index].date,
        duration: trips[index].duration,
        tripType: trips[index].tripType,
        vehicleType: trips[index].vehicleType,
        vehicleCount: trips[index].vehicleCount,
        seatingCapacity: trips[index].seatingCapacity,
        driverName: trips[index].driverName,
        vehicleNumber: trips[index].vehicleNumber,
        status: newStatus,
        timeline: trips[index].timeline,
        expenses: trips[index].expenses,
      );
      _filterTrips();
    }
  }

  @override
  void onClose() {
    dateController.dispose();
    routeController.dispose();
    durationController.dispose();
    vehicleCountController.dispose();
    seatingCapacityController.dispose();
    super.onClose();
  }
}
