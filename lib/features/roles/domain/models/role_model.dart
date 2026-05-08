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

  RoleModel copyWith({
    String? id,
    String? roleName,
    String? description,
    int? assignedUsersCount,
    List<String>? permissions,
    bool? isActive,
    String? level,
  }) {
    return RoleModel(
      id: id ?? this.id,
      roleName: roleName ?? this.roleName,
      description: description ?? this.description,
      assignedUsersCount: assignedUsersCount ?? this.assignedUsersCount,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      level: level ?? this.level,
    );
  }
}
