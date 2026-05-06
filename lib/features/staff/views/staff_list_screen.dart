import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../../../routes/route_helper.dart';
import '../controllers/staff_controller.dart';
import '../domain/models/staff_model.dart';

class StaffListScreen extends GetView<StaffController> {
  const StaffListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useScaffold: false,
      appBar: const AppHeader(
        title: 'Staff',
      ),
      floatingActionButton: FloatingActionButton(heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getAddStaffRoute()),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.add, color: AppColors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              hint: 'Search name or role...',
              onChanged: controller.updateSearch,
            ),
          ),
          
          // Filter Chips
          const SizedBox(height: 12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                AppFilterChip(label: 'All', isSelected: controller.selectedFilter.value == 'All', onTap: () => controller.setFilter('All')),
                AppFilterChip(label: 'Driver', isSelected: controller.selectedFilter.value == 'Driver', onTap: () => controller.setFilter('Driver')),
                AppFilterChip(label: 'Manager', isSelected: controller.selectedFilter.value == 'Manager', onTap: () => controller.setFilter('Manager')),
                AppFilterChip(label: 'Helper', isSelected: controller.selectedFilter.value == 'Helper', onTap: () => controller.setFilter('Helper')),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.staffList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredStaff.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.fetchStaff(),
                  child: ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: AppText('No staff members found', style: AppTextStyle.body)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchStaff(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: controller.filteredStaff.length,
                  itemBuilder: (context, index) {
                    final staff = controller.filteredStaff[index];
                    return _StaffCard(staff: staff);
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

class _StaffCard extends StatelessWidget {
  final StaffModel staff;
  const _StaffCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed(RouteHelper.getStaffDetailsRoute(), arguments: staff),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Iconsax.user, color: AppColors.primaryColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(staff.name, style: AppTextStyle.subheading, fontSize: 16, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    AppStatusChip(status: staff.status.name.capitalizeFirst!),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(staff.roleName.toString(), style: AppTextStyle.body, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.call, size: 14, color: AppColors.textColorSecondary),
                    const SizedBox(width: 6),
                    AppText(staff.phone, style: AppTextStyle.caption, color: AppColors.textColorSecondary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textColorHint),
                onPressed: () => Get.toNamed(RouteHelper.getStaffDetailsRoute(), arguments: staff),
              ),
              IconButton(
                icon: const Icon(Iconsax.edit, color: AppColors.primaryColor, size: 20),
                onPressed: () => Get.toNamed(RouteHelper.getEditStaffRoute(), arguments: staff),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
