import 'package:get/get.dart';
import '../domain/models/role_model.dart';

class RoleController extends GetxController {
  final RxList<RoleModel> roles = <RoleModel>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    roles.value = [
      RoleModel(
        id: '1',
        roleName: 'Super Admin',
        description: 'Full access to all modules and billing',
        assignedUsersCount: 1,
        permissions: ['All access'],
      ),
      RoleModel(
        id: '2',
        roleName: 'Manager',
        description: 'Can manage trips, staff, and inventory but cannot see financials',
        assignedUsersCount: 4,
        permissions: ['Trips', 'Vehicles', 'Staff', 'Inventory'],
      ),
      RoleModel(
        id: '3',
        roleName: 'Dispatcher',
        description: 'Can only view routes, active trips, and assign drivers',
        assignedUsersCount: 2,
        permissions: ['Trips', 'Routes'],
      ),
      RoleModel(
        id: '4',
        roleName: 'Accountant',
        description: 'Access exclusively to corporate contracts and finance modules',
        assignedUsersCount: 1,
        permissions: ['Corporate', 'Finance', 'Reports'],
      ),
    ];
  }

  List<RoleModel> get filteredRoles {
    if (searchQuery.value.isEmpty) {
      return roles;
    }
    return roles.where((r) => 
      r.roleName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      r.description.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  void addRole(RoleModel role) {
    roles.add(role);
  }

  void updateRole(RoleModel role) {
    int index = roles.indexWhere((r) => r.id == role.id);
    if (index != -1) {
      roles[index] = role;
    }
  }

  void deleteRole(String id) {
    roles.removeWhere((r) => r.id == id);
  }
}
