import 'package:get/get.dart';
import '../domain/models/vehicle_model.dart';

class VehicleController extends GetxController {
  final vehicles = <VehicleModel>[].obs;
  final filteredVehicles = <VehicleModel>[].obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;

  final fuelHistory = <FuelEntry>[].obs;
  final serviceHistory = <ServiceRecord>[].obs;
  final repairHistory = <ServiceRecord>[].obs; // Using ServiceRecord for repair too or similar model
  final documents = <VehicleDocument>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockVehicles();
    _loadMockMaintenance();
    
    debounce(searchQuery, (_) => _filterVehicles(), time: const Duration(milliseconds: 300));
    ever(selectedFilter, (_) => _filterVehicles());
  }

  void _loadMockMaintenance() {
    fuelHistory.value = [
      FuelEntry(date: DateTime.now().subtract(const Duration(days: 2)), amount: 4500, quantity: 45.5, station: 'Reliance Petrol Pump'),
      FuelEntry(date: DateTime.now().subtract(const Duration(days: 10)), amount: 5200, quantity: 50.2, station: 'HP Fuel Station'),
    ];

    serviceHistory.value = [
      ServiceRecord(date: DateTime.now().subtract(const Duration(days: 30)), type: 'Full Service', cost: 12500, workshop: 'Tata Authorized Service Center'),
      ServiceRecord(date: DateTime.now().subtract(const Duration(days: 120)), type: 'Oil Change', cost: 3500, workshop: 'Local Workshop'),
    ];

    repairHistory.value = [
      ServiceRecord(date: DateTime.now().subtract(const Duration(days: 5)), type: 'Brake Pad Replacement', cost: 4500, workshop: 'City Garage'),
      ServiceRecord(date: DateTime.now().subtract(const Duration(days: 60)), type: 'Tyre Change', cost: 18000, workshop: 'Michelin Store'),
    ];

    documents.value = [
      VehicleDocument(name: 'Registration Certificate (RC)', uploadDate: DateTime.now().subtract(const Duration(days: 365)), expiryDate: DateTime.now().add(const Duration(days: 365*10)), fileUrl: 'rc.pdf'),
      VehicleDocument(name: 'Insurance Policy', uploadDate: DateTime.now().subtract(const Duration(days: 200)), expiryDate: DateTime.now().add(const Duration(days: 165)), fileUrl: 'insurance.pdf'),
      VehicleDocument(name: 'Vehicle Permit', uploadDate: DateTime.now().subtract(const Duration(days: 300)), expiryDate: DateTime.now().add(const Duration(days: 65)), fileUrl: 'permit.pdf'),
    ];
  }

  void _loadMockVehicles() {
    vehicles.value = [
      VehicleModel(
        id: 1,
        vehicleNumber: 'DL 01 AB 1234',
        type: 'AC Sleeper',
        capacity: 36,
        model: 'Tata Marcopolo',
        year: '2022',
        driverName: 'Rajesh Kumar',
        lastServiceDate: DateTime.now().subtract(const Duration(days: 15)),
        status: VehicleStatus.active,
      ),
      VehicleModel(
        id: 2,
        vehicleNumber: 'RJ 14 PC 5588',
        type: 'Non-AC Seater',
        capacity: 42,
        model: 'Ashok Leyland',
        year: '2021',
        driverName: 'Suresh Singh',
        lastServiceDate: DateTime.now().subtract(const Duration(days: 45)),
        status: VehicleStatus.maintenance,
      ),
      VehicleModel(
        id: 3,
        vehicleNumber: 'UP 80 BD 9900',
        type: 'Luxury Volvo',
        capacity: 30,
        model: 'Volvo 9400 B11R',
        year: '2023',
        driverName: 'Amit Sharma',
        lastServiceDate: DateTime.now().subtract(const Duration(days: 5)),
        status: VehicleStatus.active,
      ),
    ];
    filteredVehicles.assignAll(vehicles);
  }

  void _filterVehicles() {
    List<VehicleModel> list = List.from(vehicles);
    if (selectedFilter.value == 'Active') {
      list = list.where((v) => v.status == VehicleStatus.active).toList();
    } else if (selectedFilter.value == 'Maintenance') {
      list = list.where((v) => v.status == VehicleStatus.maintenance).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list.where((v) =>
          v.vehicleNumber.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          v.type.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    filteredVehicles.assignAll(list);
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void addRepairEntry(ServiceRecord record) {
    repairHistory.insert(0, record);
    Get.snackbar('Success', 'Repair entry added successfully', snackPosition: SnackPosition.BOTTOM);
  }
}
