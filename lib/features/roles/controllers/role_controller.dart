import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/models/role_model.dart';

class RoleController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  final RxList<RoleModel> roles = <RoleModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString updatingRoleId = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final Rxn<RoleModel> selectedRole = Rxn<RoleModel>();

  @override
  void onInit() {
    super.onInit();
    fetchRoles();
    
    // Add listeners for search and filter changes
    debounce(searchQuery, (_) => fetchRoles(), time: const Duration(milliseconds: 500));
    ever(selectedFilter, (_) => fetchRoles());
  }

  Future<void> fetchRoles() async {
    isLoading.value = true;
    
    Map<String, dynamic> queryParams = {};
    if (searchQuery.value.isNotEmpty) {
      queryParams['search'] = searchQuery.value;
    }
    
    if (selectedFilter.value == 'Active') {
      queryParams['is_active'] = 1;
    } else if (selectedFilter.value == 'Inactive') {
      queryParams['is_active'] = 0;
    }

    final response = await _apiClient.get(
      AppConstants.getRolesUrl, 
      queryParameters: queryParams,
    );
    if (response.isSuccess && response.json != null) {
      final List<dynamic> data = response.json?['data'] ?? [];
      roles.value = data.map((json) => RoleModel(
        id: json['id']?.toString() ?? '',
        roleName: json['name'] ?? '',
        description: json['description'] ?? '',
        assignedUsersCount: json['users_count'] ?? 0,
        level: json['level'] ?? (json['name']?.toString().toLowerCase().contains('admin') == true ? 'High' : 'Medium'),
        permissions: (json['features'] as List? ?? []).map((f) {
          String val = f.toString().toLowerCase();
          if (val == 'vehicle') return 'Vehicles';
          return val.capitalizeFirst!;
        }).toList(),
        isActive: json['is_active'] == 1 || json['is_active'] == true,
      )).toList();
    } else {
      roles.clear();
    }
    isLoading.value = false;
  }

  List<RoleModel> get filteredRoles => roles;

  Future<bool> addRole(RoleModel role) async {
    isLoading.value = true;
    
    final features = role.permissions.map((p) {
      if (p.toLowerCase() == 'vehicles') return 'vehicle';
      return p.toLowerCase();
    }).toList();

    final payload = {
      "name": role.roleName,
      "description": role.description,
      "is_active": true,
      "features": features,
    };

    final response = await _apiClient.post(AppConstants.createRoleUrl, data: payload);
    
    isLoading.value = false;
    
    if (response.isSuccess) {
      fetchRoles();
      return true;
    } else {
      Get.snackbar('Error', response.message, backgroundColor: AppColors.errorColor, colorText: Colors.white);
      return false;
    }
  }

  Future<bool> updateRole(RoleModel role) async {
    isLoading.value = true;
    
    final features = role.permissions.map((p) {
      if (p.toLowerCase() == 'vehicles') return 'vehicle';
      return p.toLowerCase();
    }).toList();

    final payload = {
      "name": role.roleName,
      "description": role.description,
      "is_active": true,
      "features": features,
    };

    final response = await _apiClient.put(AppConstants.updateRoleUrl(role.id), data: payload);
    
    isLoading.value = false;
    
    if (response.isSuccess) {
      fetchRoles();
      return true;
    } else {
      Get.snackbar('Error', response.message, backgroundColor: AppColors.errorColor, colorText: Colors.white);
      return false;
    }
  }


  Future<void> toggleRoleStatus(RoleModel role) async {
    final originalStatus = role.isActive;
    final int roleIndex = roles.indexWhere((r) => r.id == role.id);
    
    if (roleIndex != -1) {
      // Soft update: Toggle locally first
      roles[roleIndex] = roles[roleIndex].copyWith(isActive: !originalStatus);
      roles.refresh();
    }
    
    updatingRoleId.value = role.id;
    
    final payload = {
      "name": role.roleName,
      "description": role.description,
      "is_active": !originalStatus,
      "features": role.permissions.map((p) {
        if (p.toLowerCase() == 'vehicles') return 'vehicle';
        return p.toLowerCase();
      }).toList(),
    };

    final response = await _apiClient.put(AppConstants.updateRoleUrl(role.id), data: payload);
    
    if (response.isSuccess) {
      // In soft update, we don't necessarily need to fetch all roles again if we're confident
      // but fetchRoles() ensures consistency with backend.
      // We'll fetch in background without global loader.
      _fetchRolesSilently(); 
      Get.snackbar('Success', 'Role status updated successfully', 
        backgroundColor: AppColors.successColor, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } else {
      // Rollback on failure
      if (roleIndex != -1) {
        roles[roleIndex] = roles[roleIndex].copyWith(isActive: originalStatus);
        roles.refresh();
      }
      Get.snackbar('Error', response.message, 
        backgroundColor: AppColors.errorColor, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    updatingRoleId.value = '';
  }

  Future<void> _fetchRolesSilently() async {
    Map<String, dynamic> queryParams = {};
    if (searchQuery.value.isNotEmpty) queryParams['search'] = searchQuery.value;
    if (selectedFilter.value == 'Active') queryParams['is_active'] = 1;
    else if (selectedFilter.value == 'Inactive') queryParams['is_active'] = 0;

    final response = await _apiClient.get(AppConstants.getRolesUrl, queryParameters: queryParams);
    if (response.isSuccess && response.json != null) {
      final List<dynamic> data = response.json?['data'] ?? [];
      roles.value = data.map((json) => RoleModel(
        id: json['id']?.toString() ?? '',
        roleName: json['name'] ?? '',
        description: json['description'] ?? '',
        assignedUsersCount: json['users_count'] ?? 0,
        level: json['level'] ?? (json['name']?.toString().toLowerCase().contains('admin') == true ? 'High' : 'Medium'),
        permissions: (json['features'] as List? ?? []).map((f) {
          String val = f.toString().toLowerCase();
          if (val == 'vehicle') return 'Vehicles';
          return val.capitalizeFirst!;
        }).toList(),
        isActive: json['is_active'] == 1 || json['is_active'] == true,
      )).toList();
    }
  }

  Future<void> fetchRoleDetails(String id) async {
    isLoading.value = true;
    final response = await _apiClient.get(AppConstants.getRoleByIdUrl(id));
    if (response.isSuccess && response.json != null) {
      final json = response.json?['data'];
      selectedRole.value = RoleModel(
        id: json['id']?.toString() ?? '',
        roleName: json['name'] ?? '',
        description: json['description'] ?? '',
        assignedUsersCount: json['users_count'] ?? 0,
        level: json['level'] ?? (json['name']?.toString().toLowerCase().contains('admin') == true ? 'High' : 'Medium'),
        permissions: (json['features'] as List? ?? []).map((f) {
          String val = f.toString().toLowerCase();
          if (val == 'vehicle') return 'Vehicles';
          return val.capitalizeFirst!;
        }).toList(),
        isActive: json['is_active'] == 1 || json['is_active'] == true,
      );
    }
    isLoading.value = false;
  }
}
