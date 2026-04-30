import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../controllers/role_controller.dart';
import '../domain/models/role_model.dart';
import 'add_edit_role_screen.dart';

class RoleDetailsScreen extends StatefulWidget {
  const RoleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<RoleDetailsScreen> createState() => _RoleDetailsScreenState();
}

class _RoleDetailsScreenState extends State<RoleDetailsScreen> {
  final controller = Get.find<RoleController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RoleModel initialRole = Get.arguments as RoleModel;
      controller.selectedRole.value = initialRole;
      controller.fetchRoleDetails(initialRole.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useScaffold: false,
      appBar: AppHeader(
        title: 'Role Details',
        trailing: Obx(() {
          final role = controller.selectedRole.value;
          if (role == null) return const SizedBox.shrink();
          
          final bool isAdmin = role.roleName.toLowerCase().contains('admin');
          return Row(
            children: [
              IconButton(
                icon: const Icon(Iconsax.edit),
                onPressed: () => Get.to(() => AddEditRoleScreen(role: role)),
              ),
            ],
          );
        }),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchRoleDetails(Get.arguments.id),
        child: Obx(() {
          final role = controller.selectedRole.value;
          if (controller.isLoading.value && role == null) {
            return const Center(child: CircularProgressIndicator());
          }
  
          if (role == null) {
            return const Center(child: AppText('Role not found'));
          }
  
          final bool isAdmin = role.roleName.toLowerCase().contains('admin');
          final Color iconColor = isAdmin ? AppColors.errorColor : AppColors.primaryColor;
  
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header Card ---
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Iconsax.shield_tick, color: iconColor, size: 40),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(role.roleName, style: AppTextStyle.heading, fontSize: 24),
                                const SizedBox(height: 4),
                                AppStatusChip(status: role.isActive ? 'Active' : 'Inactive'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 20),
                      _buildDetailRow(Iconsax.info_circle, 'Description', role.description),
                      const SizedBox(height: 16),
                      _buildDetailRow(Iconsax.people, 'Assigned Users', '${role.assignedUsersCount} Users'),
                    ],
                  ),
                ),
  
                const SizedBox(height: 24),
  
                // --- Stats Row ---
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Permissions', '${role.permissions.length}', Iconsax.key, AppColors.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard('Level', role.level, Iconsax.hierarchy, AppColors.infoColor),
                    ),
                  ],
                ),
  
                const SizedBox(height: 24),
  
                // --- Permissions Section ---
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: AppText('Access Permissions', 
                    fontSize: 18, 
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColorPrimary,
                  ),
                ),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: role.permissions.map((p) =>
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: AppColors.successColor),
                                const SizedBox(width: 8),
                                AppText(p, 
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColorPrimary,
                                ),
                              ],
                            ),
                          )
                        ).toList(),
                      ),
                      if (role.permissions.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: AppText('No permissions assigned', 
                              style: AppTextStyle.caption,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textColorHint),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label, fontSize: 12, color: AppColors.textColorHint, fontWeight: FontWeight.w500),
              const SizedBox(height: 2),
              AppText(value, fontSize: 14, color: AppColors.textColorPrimary, fontWeight: FontWeight.w600),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          AppText(value, fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          AppText(label, fontSize: 12, color: AppColors.textColorHint),
        ],
      ),
    );
  }

}
