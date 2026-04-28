import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../domain/models/shift_model.dart';
import '../domain/repositories/shift_repository.dart';
import '../domain/repositories/shift_list_repository.dart';
import '../domain/repositories/shift_details_repository.dart';
import '../domain/repositories/driver_repository.dart';
import '../domain/services/driver_service.dart';

class ShiftController extends GetxController {
  final RxList<ShiftModel> _shifts = <ShiftModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearchLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final Rx<ShiftModel?> currentShift = Rx<ShiftModel?>(null);

  // Driver-related observables
  final RxList<DriverModel> _availableDrivers = <DriverModel>[].obs;
  final RxString driverSearchQuery = ''.obs;
  final RxBool isDriversLoading = false.obs;
  final RxList<String> selectedDriverIds = <String>[].obs;
  final RxInt currentShiftIdForDrivers = 0.obs;

  late ShiftRepository _shiftRepository;
  late ShiftListRepository _shiftListRepository;
  late ShiftDetailsRepository _shiftDetailsRepository;
  late DriverRepository _driverRepository;
  late GetAvailableDriversUseCase _getAvailableDriversUseCase;
  late AssignDriversToShiftUseCase _assignDriversToShiftUseCase;
  late RemoveDriverFromShiftUseCase _removeDriverFromShiftUseCase;

  List<ShiftModel> get shifts => _shifts;
  List<DriverModel> get availableDrivers => _availableDrivers;
  List<DriverModel> get filteredDrivers {
    if (driverSearchQuery.value.isEmpty) {
      return _availableDrivers;
    }
    return _availableDrivers.where((driver) {
      return driver.name.toLowerCase().contains(driverSearchQuery.value.toLowerCase()) ||
             (driver.phone?.contains(driverSearchQuery.value) ?? false);
    }).toList();
  }

  List<ShiftModel> get filteredShifts => _shifts;

  void updateSearch(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      isSearchLoading.value = false;
      _loadShifts();
    } else {
      isSearchLoading.value = true;
      _loadShifts();
    }
  }

  void updateDriverSearch(String query) {
    driverSearchQuery.value = query;
    // No need to call API again, just filter locally
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    if (filter == 'All') {
      isSearchLoading.value = false;
    } else {
      isSearchLoading.value = true;
    }
    _loadShifts();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
    _loadShifts();
    // Don't load drivers on init, load them when needed for specific shift
  }

  void _initializeRepository() {
    _shiftRepository = ShiftRepositoryImpl(ApiClient());
    _shiftListRepository = ShiftListRepositoryImpl(ApiClient());
    _shiftDetailsRepository = ShiftDetailsRepositoryImpl(ApiClient());
    _driverRepository = DriverRepositoryImpl(ApiClient());
    _getAvailableDriversUseCase = GetAvailableDriversUseCase(_driverRepository);
    _assignDriversToShiftUseCase = AssignDriversToShiftUseCase(_driverRepository);
    _removeDriverFromShiftUseCase = RemoveDriverFromShiftUseCase(_driverRepository);
  }

  Future<void> _loadShifts() async {
    try {
      if (searchQuery.value.isEmpty && selectedFilter.value == 'All') {
        isLoading.value = true;
      }
      
      final type = selectedFilter.value == 'All' ? null : selectedFilter.value;
      final search = searchQuery.value.isEmpty ? null : searchQuery.value;

      final response = await _shiftListRepository.getShifts(
        type: type,
        search: search,
        page: 1,
      );

      if (response.isSuccess && response.body != null) {
        final shifts = response.body as List<ShiftModel>;
        _shifts.assignAll(shifts);
      } else {
        _shifts.clear();
      }
    } catch (e) {
      print('Error loading shifts: $e');
      _shifts.clear();
    } finally {
      isLoading.value = false;
      isSearchLoading.value = false;
    }
  }

  Future<void> refreshShifts() async {
    await _loadShifts();
  }

  Future<void> createShift({
    required String name,
    required String startTime,
    required String endTime,
    required String type,
    String? date,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      isSuccess.value = false;

      final response = await _shiftRepository.createShift(
        name: name,
        startTime: startTime,
        endTime: endTime,
        type: type,
        date: date,
        notes: notes,
      );

      if (response.isSuccess && response.body != null) {
        final shift = response.body as ShiftModel;
        _shifts.add(shift);
        isSuccess.value = true;
        print("shift craeted :  successful  "+response.message);
        CustomSnackbar.showSuccess(response.message ?? 'Shift created successfully');
      } else {
        isSuccess.value = false;
        print("shift craeted :  failed  "+response.message);
        CustomSnackbar.showError(response.message ?? 'Failed to create shift');
      }
    } catch (e) {
      isSuccess.value = false;
      print('Error creating shift: $e');
      CustomSnackbar.showError('Error creating shift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateShift({
    required int shiftId,
    required String name,
    required String startTime,
    required String endTime,
    required String type,
    String? date,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      isSuccess.value = false;

      final response = await _shiftRepository.updateShift(
        shiftId: shiftId,
        name: name,
        startTime: startTime,
        endTime: endTime,
        type: type,
        date: date,
        notes: notes,
      );

      if (response.isSuccess) {
        isSuccess.value = true;
        print("shift updated: successful ${response.message}");
        CustomSnackbar.showSuccess(response.message ?? 'Shift updated successfully');
        
        // Refresh shift details if we have the updated shift
        if (response.body != null) {
          currentShift.value = response.body as ShiftModel;
        } else {
          // Refresh shift details from API
          await getShiftDetails(shiftId);
        }
      } else {
        isSuccess.value = false;
        print("shift updated: failed ${response.message}");
        CustomSnackbar.showError(response.message ?? 'Failed to update shift');
      }
    } catch (e) {
      isSuccess.value = false;
      print('Error updating shift: $e');
      CustomSnackbar.showError('Error updating shift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getShiftDetails(int shiftId) async {
    try {
      isLoading.value = true;

      final response = await _shiftDetailsRepository.getShiftDetails(shiftId);

      if (response.isSuccess && response.body != null) {
        currentShift.value = response.body as ShiftModel;
        print('Shift details loaded successfully');
      } else {
        print('Failed to load shift details: ${response.message}');
        CustomSnackbar.showError(response.message ?? 'Failed to load shift details');
      }
    } catch (e) {
      print('Error loading shift details: $e');
      CustomSnackbar.showError('Error loading shift details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteShift(int shiftId) async {
    try {
      isLoading.value = true;
      isSuccess.value = false;

      final response = await _shiftRepository.deleteShift(shiftId);

      if (response.isSuccess) {
        isSuccess.value = true;
        print("shift deleted: successful ${response.message}");
        CustomSnackbar.showSuccess(response.message ?? 'Shift deleted successfully');
        
        // Remove shift from local list if it exists
        _shifts.removeWhere((shift) => shift.id == shiftId);
        
        // Clear current shift if it's the deleted one
        if (currentShift.value?.id == shiftId) {
          currentShift.value = null;
        }
      } else {
        isSuccess.value = false;
        print("shift deleted: failed ${response.message}");
        CustomSnackbar.showError(response.message ?? 'Failed to delete shift');
      }
    } catch (e) {
      isSuccess.value = false;
      print('Error deleting shift: $e');
      CustomSnackbar.showError('Error deleting shift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Driver-related methods
  Future<void> loadAvailableDriversForShift(int shiftId) async {
    try {
      print('=== Loading drivers for shift ID: $shiftId ===');
      isDriversLoading.value = true;
      currentShiftIdForDrivers.value = shiftId;

      final response = await _getAvailableDriversUseCase.call(shiftId: shiftId);

      print('Driver API response - Success: ${response.isSuccess}');
      print('Driver API response - Message: ${response.message}');
      print('Driver API response - Body type: ${response.body.runtimeType}');

      if (response.isSuccess && response.body != null) {
        final drivers = response.body as List<DriverModel>;
        _availableDrivers.assignAll(drivers);
        print('Successfully loaded ${drivers.length} available drivers for shift $shiftId');
        
        // Print driver names for debugging
        for (var driver in drivers) {
          print('Driver: ${driver.name} (ID: ${driver.id})');
        }
      } else {
        _availableDrivers.clear();
        print('Failed to load drivers for shift $shiftId: ${response.message}');
      }
    } catch (e) {
      print('ERROR loading available drivers for shift $shiftId: $e');
      _availableDrivers.clear();
    } finally {
      isDriversLoading.value = false;
      print('=== Finished loading drivers for shift ID: $shiftId ===');
    }
  }

  Future<void> _loadAvailableDrivers() async {
    // This method is deprecated, use loadAvailableDriversForShift instead
    if (currentShiftIdForDrivers.value > 0) {
      await loadAvailableDriversForShift(currentShiftIdForDrivers.value);
    }
  }

  Future<void> refreshDrivers() async {
    if (currentShiftIdForDrivers.value > 0) {
      await loadAvailableDriversForShift(currentShiftIdForDrivers.value);
    }
  }

  void toggleDriverSelection(String driverId) {
    if (selectedDriverIds.contains(driverId)) {
      selectedDriverIds.remove(driverId);
    } else {
      selectedDriverIds.add(driverId);
    }
  }

  void clearDriverSelection() {
    selectedDriverIds.clear();
  }

  Future<void> assignDriversToShift(int shiftId) async {
    try {
      isLoading.value = true;
      
      // Convert selected driver IDs from String to int
      final List<int> driverIds = selectedDriverIds.map((id) => int.parse(id)).toList();
      
      print('Assigning ${driverIds.length} drivers to shift $shiftId: $driverIds');
      
      final response = await _assignDriversToShiftUseCase.call(
        shiftId: shiftId,
        driverIds: driverIds,
      );
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? '${selectedDriverIds.length} drivers assigned to shift successfully');
        clearDriverSelection();
        
        // Refresh shift details to show updated drivers
        await getShiftDetails(shiftId);
      } else {
        CustomSnackbar.showError(response.message ?? 'Failed to assign drivers');
      }
      
    } catch (e) {
      print('Error assigning drivers: $e');
      CustomSnackbar.showError('Error assigning drivers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeDriverFromShift(int shiftId, int driverId) async {
    try {
      isLoading.value = true;
      
      print('Removing driver $driverId from shift $shiftId');
      
      final response = await _removeDriverFromShiftUseCase.call(
        shiftId: shiftId,
        driverId: driverId,
      );
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? 'Driver removed from shift successfully');
        
        // Refresh shift details to show updated drivers
        await getShiftDetails(shiftId);
      } else {
        CustomSnackbar.showError(response.message ?? 'Failed to remove driver from shift');
      }
      
    } catch (e) {
      print('Error removing driver: $e');
      CustomSnackbar.showError('Error removing driver: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
