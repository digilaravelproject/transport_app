import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/role_controller.dart';
import '../domain/models/role_model.dart';
import 'add_edit_role_screen.dart';

class RoleDetailsScreen extends StatelessWidget {
  const RoleDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RoleModel role = Get.arguments as RoleModel;
    final controller = Get.find<RoleController>();
    final bool isAdmin = role.roleName.toLowerCase().contains('admin');
    final Color iconColor = isAdmin ? AppColors.errorColor : AppColors.primaryColor;

    void deleteRole() {
      if (isAdmin) {
        Get.snackbar('Protected', 'Admin roles cannot be deleted', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.warningColor, colorText: AppColors.white);
        return;
      }
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Role'),
          content: Text('Are you sure you want to delete "${role.roleName}"? Users assigned this role will be affected.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                controller.deleteRole(role.id);
                Navigator.of(context).pop(); // Close dialog
                Get.back(); // Go back to list
                Get.snackbar('Deleted', 'Role deleted successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.errorColor, colorText: AppColors.white);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    return AppScaffold(
      useScaffold: false,
      appBar: AppHeader(
        title: 'Role Details',
        trailing: Row(
          children: [
            IconButton(
              icon: const Icon(Iconsax.edit),
              onPressed: () => Get.to(() => AddEditRoleScreen(role: role)),
            ),
            if (!isAdmin)
              IconButton(
                icon: const Icon(Iconsax.trash, color: AppColors.errorColor),
                onPressed: deleteRole,
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Iconsax.shield_tick, color: iconColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(role.roleName, style: AppTextStyle.heading, fontSize: 20),
                        const SizedBox(height: 4),
                        AppText(role.description, style: AppTextStyle.body, color: AppColors.textColorSecondary),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Iconsax.people, size: 14, color: AppColors.textColorHint),
                            const SizedBox(width: 4),
                            AppText('${role.assignedUsersCount} users assigned', style: AppTextStyle.caption, color: AppColors.textColorHint),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Permissions
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Access Permissions', style: AppTextStyle.subheading, fontSize: 16),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: role.permissions.map((p) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.successColor),
                            const SizedBox(width: 6),
                            AppText(p, style: AppTextStyle.caption, fontWeight: FontWeight.w600),
                          ],
                        ),
                      )
                    ).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppButton(
                    text: 'Edit Role',
                    onPressed: () => Get.to(() => AddEditRoleScreen(role: role)),
                  ),
                  if (!isAdmin) ...[
                    const SizedBox(height: 12),
                    AppButton.outline(
                      text: 'Delete Role',
                      color: AppColors.errorColor,
                      onPressed: deleteRole,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
