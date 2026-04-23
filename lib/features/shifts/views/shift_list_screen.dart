import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../controllers/shift_controller.dart';
import '../domain/models/shift_model.dart';
import '../../../routes/route_helper.dart';

class ShiftListScreen extends GetView<ShiftController> {
  const ShiftListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(
        title: 'Shifts',
        rightWidget: IconButton(
          icon: const Icon(Icons.filter_list_rounded, color: AppColors.textColorPrimary),
          onPressed: () {},
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getCreateShiftRoute()),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const AppText('Create Shift', style: AppTextStyle.body, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: AppSearchBar(
              hint: 'Search shifts...',
              onChanged: (v) => controller.updateSearch(v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Row(
              children: [
                AppFilterChip(
                  label: 'All',
                  isSelected: controller.selectedFilter.value == 'All',
                  onTap: () => controller.setFilter('All'),
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'Regular',
                  isSelected: controller.selectedFilter.value == 'Regular',
                  onTap: () => controller.setFilter('Regular'),
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'Overtime',
                  isSelected: controller.selectedFilter.value == 'Overtime',
                  onTap: () => controller.setFilter('Overtime'),
                ),
                const SizedBox(width: 8),
                AppFilterChip(
                  label: 'Special Duty',
                  isSelected: controller.selectedFilter.value == 'Special Duty',
                  onTap: () => controller.setFilter('Special Duty'),
                ),
              ],
            )),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }
              
              if (controller.filteredShifts.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => controller.refreshShifts(),
                  color: AppColors.primaryColor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: AppText('No shifts found.')),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => controller.refreshShifts(),
                color: AppColors.primaryColor,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredShifts.length,
                  itemBuilder: (context, index) {
                    return _buildShiftItem(controller.filteredShifts[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftItem(ShiftModel shift) {
    bool hasDrivers = (shift.driversCount ?? 0) > 0;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed(RouteHelper.getShiftDetailsRoute(), arguments: shift),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(shift.name, style: AppTextStyle.subheading, fontSize: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: shift.type.toLowerCase() == 'overtime' ? AppColors.errorColor.withOpacity(0.1) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  shift.type.replaceFirst(shift.type[0], shift.type[0].toUpperCase()),
                  style: AppTextStyle.caption,
                  color: shift.type.toLowerCase() == 'overtime' ? AppColors.errorColor : AppColors.primaryColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textColorSecondary),
              const SizedBox(width: 8),
              AppText(
                shift.formattedTimeRange ?? '${shift.startTime} - ${shift.endTime}',
                style: AppTextStyle.body
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.group_outlined, size: 16, color: AppColors.textColorSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  hasDrivers ? '${shift.driversCount} Driver(s) Assigned' : 'No drivers assigned',
                  style: AppTextStyle.body,
                  color: hasDrivers ? AppColors.textColorPrimary : AppColors.errorColor,
                  fontWeight: hasDrivers ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
