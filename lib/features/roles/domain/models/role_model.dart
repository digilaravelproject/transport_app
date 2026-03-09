class RoleModel {
  final String id;
  final String roleName;
  final String description;
  final int assignedUsersCount;
  final List<String> permissions;

  RoleModel({
    required this.id,
    required this.roleName,
    required this.description,
    required this.assignedUsersCount,
    required this.permissions,
  });
}
