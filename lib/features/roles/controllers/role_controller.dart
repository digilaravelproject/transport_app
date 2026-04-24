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
      AppConstants.rolesUrl, 
      queryParameters: queryParams,
    );
    if (response.isSuccess && response.json != null) {
      final List<dynamic> data = response.json?['data'] ?? [];
      roles.value = data.map((json) => RoleModel(
        id: json['id']?.toString() ?? '',
        roleName: json['name'] ?? '',
        description: json['description'] ?? '',
        assignedUsersCount: json['users_count'] ?? 0,
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

    final response = await _apiClient.post(AppConstants.rolesUrl, data: payload);
    
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

    final response = await _apiClient.put('${AppConstants.rolesUrl}/${role.id}', data: payload);
    
    isLoading.value = false;
    
    if (response.isSuccess) {
      fetchRoles();
      return true;
    } else {
      Get.snackbar('Error', response.message, backgroundColor: AppColors.errorColor, colorText: Colors.white);
      return false;
    }
  }

  void deleteRole(String id) {
    roles.removeWhere((r) => r.id == id);
  }

  Future<void> toggleRoleStatus(RoleModel role) async {
    isLoading.value = true;
    
    final payload = {
      "name": role.roleName,
      "description": role.description,
      "is_active": !role.isActive,
      "features": role.permissions.map((p) {
        if (p.toLowerCase() == 'vehicles') return 'vehicle';
        return p.toLowerCase();
      }).toList(),
    };

    final response = await _apiClient.put('${AppConstants.rolesUrl}/${role.id}', data: payload);
    
    if (response.isSuccess) {
      await fetchRoles();
      Get.snackbar('Success', 'Role status updated successfully', 
        backgroundColor: AppColors.successColor, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar('Error', response.message, 
        backgroundColor: AppColors.errorColor, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isLoading.value = false;
  }

  Future<void> fetchRoleDetails(String id) async {
    isLoading.value = true;
    final response = await _apiClient.get('${AppConstants.rolesUrl}/$id');
    if (response.isSuccess && response.json != null) {
      final json = response.json?['data'];
      selectedRole.value = RoleModel(
        id: json['id']?.toString() ?? '',
        roleName: json['name'] ?? '',
        description: json['description'] ?? '',
        assignedUsersCount: json['users_count'] ?? 0,
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
