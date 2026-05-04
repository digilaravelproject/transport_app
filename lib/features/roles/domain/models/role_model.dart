class RoleModel {
  final String id;
  final String roleName;
  final String description;
  final int assignedUsersCount;
  final List<String> permissions;
  final bool isActive;
  final String level;

  RoleModel({
    required this.id,
    required this.roleName,
    required this.description,
    required this.assignedUsersCount,
    required this.permissions,
    this.isActive = true,
    this.level = 'Medium',
  });
}
