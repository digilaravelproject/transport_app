import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_text_constants.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../controllers/role_controller.dart';
import '../domain/models/role_model.dart';
import '../../../routes/route_helper.dart';
import '../../../core/widgets/app_filter_chip.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/app_empty_state.dart';

class RoleListScreen extends GetView<RoleController> {
  const RoleListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RoleController>()) {
      Get.put(RoleController());
    }

    return AppScaffold(
      useScaffold: false,
      appBar: AppHeader(
        title: AppTextConstants.rolesPermissions.tr,
        subtitle: AppTextConstants.manageAgencyAccess.tr,
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
              hint: AppTextConstants.searchRolesHint.tr,
              onChanged: (val) => controller.searchQuery.value = val,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Obx(() => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                AppFilterChip(
                  label: AppTextConstants.all.tr,
                  isSelected: controller.selectedFilter.value == 'All',
                  onTap: () => controller.selectedFilter.value = 'All',
                ),
                AppFilterChip(
                  label: AppTextConstants.active.tr,
                  isSelected: controller.selectedFilter.value == 'Active',
                  onTap: () => controller.selectedFilter.value = 'Active',
                ),
                AppFilterChip(
                  label: AppTextConstants.inactive.tr,
                  isSelected: controller.selectedFilter.value == 'Inactive',
                  onTap: () => controller.selectedFilter.value = 'Inactive',
                ),
              ],
            )),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.roles.isEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) => const _RoleShimmer(),
                );
              }
              if (controller.filteredRoles.isEmpty) {
                return AppEmptyState(
                  title: controller.searchQuery.value.isNotEmpty ? AppTextConstants.noResultsFound.tr : AppTextConstants.noResultsFound.tr,
                  subtitle: controller.searchQuery.value.isNotEmpty 
                      ? '${AppTextConstants.noResultsFound.tr} "${controller.searchQuery.value}"'
                      : AppTextConstants.manageAgencyAccess.tr,
                  icon: controller.searchQuery.value.isNotEmpty ? Iconsax.search_status : Iconsax.shield_tick,
                  actionLabel: controller.searchQuery.value.isNotEmpty ? null : AppTextConstants.add.tr,
                  onActionPressed: controller.searchQuery.value.isNotEmpty 
                      ? null 
                      : () => Get.toNamed(RouteHelper.getAddRoleRoute()),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchRoles(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: controller.filteredRoles.length,
                  itemBuilder: (context, index) {
                    final role = controller.filteredRoles[index];
                    return _RoleCard(role: role);
                  },
                ),
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
    final Color iconColor = role.isActive 
        ? (role.roleName.toLowerCase().contains('admin') ? AppColors.errorColor : AppColors.primaryColor)
        : AppColors.textColorHint;
    
    final RoleController controller = Get.find<RoleController>();

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
                        AppStatusChip(status: role.isActive ? 'active' : 'inactive'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(role.description, style: AppTextStyle.body, color: AppColors.textColorSecondary),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5, color: AppColors.borderColor),
          Row(
            children: [
              AppText('${AppTextConstants.access.tr}: ', style: AppTextStyle.caption, color: AppColors.textColorHint),
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
              const SizedBox(width: 12),
              Obx(() => controller.updatingRoleId.value == role.id 
                ? const SizedBox(width: 44, height: 24, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))))
                : CupertinoSwitch(
                    value: role.isActive,
                    activeColor: AppColors.primaryColor,
                    onChanged: (val) => controller.toggleRoleStatus(role),
                  ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
class _RoleShimmer extends StatelessWidget {
  const _RoleShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.slate100,
      highlightColor: AppColors.white,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 150,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 200,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            Row(
              children: [
                Container(
                  height: 20,
                  width: 100,
                  color: AppColors.white,
                ),
                const Spacer(),
                Container(
                  height: 24,
                  width: 24,
                  color: AppColors.white,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
