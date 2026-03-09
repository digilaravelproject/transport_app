import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../controllers/role_controller.dart';
import '../domain/models/role_model.dart';
import '../../../routes/route_helper.dart';

class RoleListScreen extends GetView<RoleController> {
  const RoleListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RoleController>()) {
      Get.put(RoleController());
    }

    return AppScaffold(
      useScaffold: false,
      appBar: const AppHeader(
        title: 'Roles & Permissions',
        subtitle: 'Manage agency access levels',
      ),
      floatingActionButton: FloatingActionButton(heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getAddRoleRoute()),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.add, color: AppColors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              hint: 'Search roles...',
              onChanged: (val) => controller.searchQuery.value = val,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.filteredRoles.isEmpty) {
                return const Center(child: AppText('No roles found', style: AppTextStyle.body));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: controller.filteredRoles.length,
                itemBuilder: (context, index) {
                  final role = controller.filteredRoles[index];
                  return _RoleCard(role: role);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final RoleModel role;
  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = role.roleName.toLowerCase().contains('admin');
    final Color iconColor = isAdmin ? AppColors.errorColor : AppColors.primaryColor;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => Get.toNamed(RouteHelper.getRoleDetailsRoute(), arguments: role),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Iconsax.shield_tick, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(role.roleName, style: AppTextStyle.subheading, fontSize: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.textColorHint.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppText('${role.assignedUsersCount} Users', style: AppTextStyle.caption, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(role.description, style: AppTextStyle.body, color: AppColors.textColorSecondary),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const AppText('Access: ', style: AppTextStyle.caption, color: AppColors.textColorHint),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: role.permissions.map((p) => 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AppText(p, style: AppTextStyle.caption, fontSize: 10),
                    )
                  ).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.edit, size: 20, color: AppColors.primaryColor),
                onPressed: () => Get.toNamed(RouteHelper.getEditRoleRoute(), arguments: role),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          )
        ],
      ),
    );
  }
}
