import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../domain/models/shift_model.dart';
import '../domain/repositories/shift_repository.dart';
import '../domain/repositories/shift_list_repository.dart';
import '../domain/repositories/shift_details_repository.dart';

class ShiftController extends GetxController {
  final RxList<ShiftModel> _shifts = <ShiftModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final Rx<ShiftModel?> currentShift = Rx<ShiftModel?>(null);

  late ShiftRepository _shiftRepository;
  late ShiftListRepository _shiftListRepository;
  late ShiftDetailsRepository _shiftDetailsRepository;

  List<ShiftModel> get shifts => _shifts;

  List<ShiftModel> get filteredShifts => _shifts;

  void updateSearch(String query) {
    searchQuery.value = query;
    _loadShifts();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _loadShifts();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
    _loadShifts();
  }

  void _initializeRepository() {
    _shiftRepository = ShiftRepositoryImpl(ApiClient());
    _shiftListRepository = ShiftListRepositoryImpl(ApiClient());
    _shiftDetailsRepository = ShiftDetailsRepositoryImpl(ApiClient());
  }

  Future<void> _loadShifts() async {
    try {
      isLoading.value = true;
      
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
}
