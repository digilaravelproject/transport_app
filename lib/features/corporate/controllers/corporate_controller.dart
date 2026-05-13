import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/multipart.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/company_model.dart';
import '../domain/models/corporate_contract_request_model.dart';
import '../domain/repositories/corporate_repository.dart';
import '../../../core/constants/app_text_constants.dart';

class CorporateController extends GetxController {
  final CorporateRepository _repository = CorporateRepositoryImpl(Get.find<ApiClient>());
  
  final RxList<CompanyModel> _companies = <CompanyModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  final Rx<CompanyModel?> selectedVendor = Rx<CompanyModel?>(null);
  final RxList<Map<String, dynamic>> assignedVehicles = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> assignedDrivers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> billingHistory = <Map<String, dynamic>>[].obs;
  final RxBool isDetailsLoading = false.obs;

  var selectedCountryCode = '+91'.obs;

  List<CompanyModel> get companies => _companies;

  List<CompanyModel> get filteredCompanies {
    // We handle filtering at the API level now for search, 
    // but we can still keep local filtering for other UI filters if needed.
    if (selectedFilter.value == 'All') {
      return _companies;
    }
    return _companies.where((company) {
      bool matchesFilter = true;
      if (selectedFilter.value == 'Active') matchesFilter = company.isActive;
      if (selectedFilter.value == 'Inactive') matchesFilter = !company.isActive;

      return matchesFilter;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadVendors();
  }

  Future<void> loadVendors({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || (!isRefresh && (isLoading.value || isMoreLoading.value))) return;

    try {
      final int requestPage = currentPage.value;
      if (requestPage == 1) {
        isLoading.value = true;
      } else {
        isMoreLoading.value = true;
      }

      final response = await _repository.getVendors(
        search: searchQuery.value,
        page: requestPage,
      );

      if (response.isSuccess && response.body != null) {
        // In this project's ResponseModel, 'body' already contains the 'data' field
        final List<dynamic> data = response.body is List ? response.body : [];
        final meta = response.json?['meta'];
        
        final List<CompanyModel> newVendors = data.map((json) => CompanyModel.fromJson(json)).toList();
        
        if (requestPage == 1) {
          _companies.assignAll(newVendors);
        } else {
          _companies.addAll(newVendors);
        }
        
        if (newVendors.isEmpty && requestPage > 1) {
          hasMoreData.value = false;
        } else {
          if (currentPage.value == requestPage) {
            currentPage.value++;
          }
          
          if (meta != null && meta['current_page'] != null && meta['last_page'] != null) {
            if (meta['current_page'] >= meta['last_page']) {
              hasMoreData.value = false;
            }
          } else if (newVendors.length < 20) {
            // Fallback if meta is missing
            hasMoreData.value = false;
          }
        }
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToLoadVendors.tr);
      }
    } catch (e) {
      print('Error loading vendors: $e');
      CustomSnackbar.showError(AppTextConstants.errorLoadingVendors.tr);
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> loadVendorDetails(String id) async {
    try {
      isDetailsLoading.value = true;
      final response = await _repository.getVendorDetails(id);
      
      if (response.isSuccess && response.body != null) {
        final data = response.body;
        if (data['vendor'] != null) {
          selectedVendor.value = CompanyModel.fromJson(data['vendor']);
        }
        
        if (data['assigned_vehicles'] is List) {
          assignedVehicles.assignAll(List<Map<String, dynamic>>.from(data['assigned_vehicles']));
        }

        if (data['assigned_drivers'] is List) {
          assignedDrivers.assignAll(List<Map<String, dynamic>>.from(data['assigned_drivers']));
        } else if (data['drivers'] is List) {
          assignedDrivers.assignAll(List<Map<String, dynamic>>.from(data['drivers']));
        }
        
        if (data['billing_history'] is List) {
          billingHistory.assignAll(List<Map<String, dynamic>>.from(data['billing_history']));
        }
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToLoadVendorDetails.tr);
      }
    } catch (e) {
      print('Error loading vendor details: $e');
      CustomSnackbar.showError(AppTextConstants.errorLoadingVendorDetails.tr);
    } finally {
      isDetailsLoading.value = false;
    }
  }

  final RxList<Map<String, dynamic>> availableVehicles = <Map<String, dynamic>>[].obs;
  final RxBool isAvailableVehiclesLoading = false.obs;
  final RxString vehicleSearchQuery = ''.obs;

  Future<void> loadAvailableVehicles(String vendorId, {bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        availableVehicles.clear();
      }
      isAvailableVehiclesLoading.value = true;
      final response = await _repository.getAvailableVehicles(
        vendorId,
        search: vehicleSearchQuery.value,
      );
      
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body is List ? response.body : [];
        availableVehicles.assignAll(List<Map<String, dynamic>>.from(data));
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToLoadAvailableVehicles.tr);
      }
    } catch (e) {
      print('Error loading available vehicles: $e');
      CustomSnackbar.showError(AppTextConstants.errorLoadingAvailableVehicles.tr);
    } finally {
      isAvailableVehiclesLoading.value = false;
    }
  }

  final RxList<Map<String, dynamic>> availableDrivers = <Map<String, dynamic>>[].obs;
  final RxBool isAvailableDriversLoading = false.obs;
  final RxString driverSearchQuery = ''.obs;

  Future<void> loadAvailableDrivers(String vendorId, {bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        availableDrivers.clear();
      }
      isAvailableDriversLoading.value = true;
      final response = await _repository.getAvailableDrivers(
        vendorId,
        search: driverSearchQuery.value,
      );
      
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body is List ? response.body : [];
        availableDrivers.assignAll(List<Map<String, dynamic>>.from(data));
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToLoadAvailableDrivers.tr);
      }
    } catch (e) {
      print('Error loading available drivers: $e');
      CustomSnackbar.showError(AppTextConstants.errorLoadingAvailableDrivers.tr);
    } finally {
      isAvailableDriversLoading.value = false;
    }
  }

  Future<bool> assignDrivers(String vendorId, List<int> staffIds) async {
    try {
      isLoading.value = true;
      final response = await _repository.assignDrivers(vendorId, staffIds);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? AppTextConstants.driversAssignedSuccessfully.tr);
        return true;
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToAssignDrivers.tr);
        return false;
      }
    } catch (e) {
      print('Error assigning drivers: $e');
      CustomSnackbar.showError(AppTextConstants.errorAssigningDrivers.tr);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeDriver(String vendorId, String driverId) async {
    try {
      isLoading.value = true;
      final response = await _repository.removeDriver(vendorId, driverId);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? AppTextConstants.driverRemovedSuccessfully.tr);
        loadVendorDetails(vendorId); // Refresh details list
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToRemoveDriver.tr);
      }
    } catch (e) {
      print('Error removing driver: $e');
      CustomSnackbar.showError(AppTextConstants.errorRemovingDriver.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void updateDriverSearch(String vendorId, String query) {
    driverSearchQuery.value = query;
    loadAvailableDrivers(vendorId);
  }

  void updateVehicleSearch(String vendorId, String query) {
    vehicleSearchQuery.value = query;
    loadAvailableVehicles(vendorId);
  }

  Future<bool> assignVehicles(String vendorId, List<int> vehicleIds) async {
    try {
      isLoading.value = true;
      final response = await _repository.assignVehicles(vendorId, vehicleIds);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? AppTextConstants.vehiclesAssignedSuccessfully.tr);
        return true;
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToAssignVehicles.tr);
        return false;
      }
    } catch (e) {
      print('Error assigning vehicles: $e');
      CustomSnackbar.showError(AppTextConstants.errorAssigningVehicles.tr);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeVehicle(String vendorId, String vehicleId) async {
    try {
      isLoading.value = true;
      final response = await _repository.removeVehicle(vendorId, vehicleId);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? AppTextConstants.vehicleRemovedSuccessfully.tr);
        loadVendorDetails(vendorId); // Refresh details list
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToRemoveVehicle.tr);
      }
    } catch (e) {
      print('Error removing vehicle: $e');
      CustomSnackbar.showError(AppTextConstants.errorRemovingVehicle.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addVendorBill(String vendorId, Map<String, String> body, List<MultipartBody> files) async {
    try {
      isLoading.value = true;
      final response = await _repository.addVendorBill(vendorId, body, files);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? AppTextConstants.billAddedSuccessfully.tr);
        loadVendorDetails(vendorId); // Refresh details and billing history
        return true;
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToAddBill.tr);
        return false;
      }
    } catch (e) {
      print('Error adding bill: $e');
      CustomSnackbar.showError(AppTextConstants.errorAddingBill.tr);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    // Debounce search or just reload
    loadVendors(isRefresh: true);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<bool> createContract(CorporateContractRequestModel request) async {
    try {
      isLoading.value = true;
      final response = await _repository.createContract(request);
      
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message ?? AppTextConstants.contractCreatedSuccessfully.tr);
        return true;
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToCreateContract.tr);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('An error occurred: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleVendorStatus(String id) async {
    try {
      isLoading.value = true;
      final response = await _repository.toggleVendorStatus(id);
      
      if (response.isSuccess) {
        // Update local state
        final index = _companies.indexWhere((c) => c.id == id);
        if (index != -1) {
          final company = _companies[index];
          
          // API returns the new status in data.status
          bool newStatus = false;
          if (response.body is Map && response.body['status'] != null) {
            // Server might return bool or int
            newStatus = response.body['status'] == true || response.body['status'] == 1;
          } else {
            // Fallback: toggle local status if API doesn't return it clearly
            newStatus = !company.isActive;
          }

          _companies[index] = company.copyWith(
            isActive: newStatus,
            status: newStatus ? '1' : '0',
          );
          _companies.refresh();
          CustomSnackbar.showSuccess(response.message ?? AppTextConstants.statusUpdatedSuccessfully.tr);
        }
      } else {
        CustomSnackbar.showError(response.message ?? AppTextConstants.failedToUpdateStatus.tr);
      }
    } catch (e) {
      print('Error toggling status: $e');
      CustomSnackbar.showError(AppTextConstants.errorUpdatingStatus.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleInvoiceStatus(String invNo) {
    final index = invoices.indexWhere((i) => i.invNo == invNo);
    if (index != -1) {
      final inv = invoices[index];
      invoices[index] = InvoiceModel(
        invNo: inv.invNo,
        amount: inv.amount,
        date: inv.date,
        status: inv.status == 'Paid' ? 'Pending' : 'Paid',
      );
      invoices.refresh();
    }
  }
}
