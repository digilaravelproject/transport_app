import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../../../routes/route_helper.dart';
import '../controllers/vehicle_controller.dart';
import '../controllers/vehicle_type_controller.dart';
import '../domain/models/vehicle_model.dart';
import '../../../core/constants/app_text_constants.dart';
import '../../../core/widgets/app_empty_state.dart';

class VehicleListScreen extends GetView<VehicleController> {
  const VehicleListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getAddVehicleRoute()),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Fixed Top Bar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (Navigator.of(context).canPop())
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Iconsax.arrow_left_2,
                          color: AppColors.textColorPrimary, size: 20),
                    ),
                  )
                else
                  const SizedBox(width: 36),
                Obx(() => InkWell(
                  onTap: () => _showFilterBottomSheet(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: controller.activeFiltersCount > 0 
                          ? AppColors.primaryColor.withValues(alpha: 0.1) 
                          : AppColors.slate100,
                      borderRadius: BorderRadius.circular(20),
                      border: controller.activeFiltersCount > 0 
                          ? Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.filter, 
                          color: controller.activeFiltersCount > 0 ? AppColors.primaryColor : AppColors.textColorPrimary, 
                          size: 14
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          controller.activeFiltersCount > 0 
                              ? '${AppTextConstants.filter.tr} (${controller.activeFiltersCount})' 
                              : AppTextConstants.filter.tr,
                          color: controller.activeFiltersCount > 0 ? AppColors.primaryColor : AppColors.textColorPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  controller.fetchVehicles(),
                  controller.fetchVehicleStats(),
                ]);
              },
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            AppTextConstants.vehiclesDashboard.tr,
                            style: AppTextStyle.heading,
                            fontSize: 28,
                            color: AppColors.textColorPrimary,
                          ),
                          SizedBox(height: 4),
                          AppText(
                            AppTextConstants.manageMonitorFleet.tr,
                            style: AppTextStyle.body,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stat Cards
                    Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: AppTextConstants.total.tr,
                                  value: controller.totalVehicles.value.toString(),
                                  color: const Color(0xFF3B82F6),
                                  icon: Iconsax.bus,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: AppTextConstants.active.tr,
                                  value: controller.activeVehicles.value.toString(),
                                  color: const Color(0xFF10B981),
                                  icon: Iconsax.tick_circle5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: AppTextConstants.service.tr,
                                  value: controller.serviceVehicles.value.toString(),
                                  color: const Color(0xFFF59E0B),
                                  icon: Iconsax.setting_25,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AppSearchBar(
                        hint: AppTextConstants.searchVehicleHint.tr,
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
                              AppFilterChip(
                                  label: AppTextConstants.all.tr,
                                  isSelected: controller.selectedFilter.value == 'All',
                                  onTap: () => controller.setFilter('All')),
                              AppFilterChip(
                                  label: AppTextConstants.active.tr,
                                  isSelected: controller.selectedFilter.value == 'Active',
                                  onTap: () => controller.setFilter('Active')),
                              AppFilterChip(
                                  label: AppTextConstants.maintenance.tr,
                                  isSelected: controller.selectedFilter.value == 'Maintenance',
                                  onTap: () => controller.setFilter('Maintenance')),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),

                    // Vehicle List
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(100.0),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primaryColor),
                          ),
                        );
                      }
                      final isSearchingOrFiltering = controller.searchQuery.isNotEmpty || controller.activeFiltersCount > 0;
                      if (controller.filteredVehicles.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: AppEmptyState(
                            title: isSearchingOrFiltering ? AppTextConstants.noResultsFound.tr : AppTextConstants.noVehiclesFound.tr,
                            subtitle: isSearchingOrFiltering 
                                ? AppTextConstants.noResultsFound.tr
                                : AppTextConstants.startAddingVehicle.tr,
                            icon: isSearchingOrFiltering ? Iconsax.search_status : Iconsax.bus,
                            actionLabel: null,
                            onActionPressed: null,
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: controller.filteredVehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = controller.filteredVehicles[index];
                          return _VehicleCard(vehicle: vehicle);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final vehicleTypeController = Get.isRegistered<VehicleTypeController>() 
        ? Get.find<VehicleTypeController>() 
        : Get.put(VehicleTypeController());
    final List<String> typeNames = ['All', ...vehicleTypeController.vehicleTypes.map((e) => e.name)];
    final capacities = ['All', '< 30', '30 - 45', '> 45'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(AppTextConstants.filterVehicles.tr,
                    style: AppTextStyle.subheading, fontSize: 18, fontWeight: FontWeight.bold),
                TextButton(
                  onPressed: () {
                    controller.resetFilters();
                    Get.back();
                  },
                  child: AppText(AppTextConstants.reset.tr,
                      color: AppColors.errorColor, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppText(AppTextConstants.vehicleType.tr,
                style: AppTextStyle.body, fontWeight: FontWeight.bold, fontSize: 15),
            const SizedBox(height: 12),
            Obx(() {
              if (vehicleTypeController.isLoading.value && vehicleTypeController.vehicleTypes.isEmpty) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              
              final typeNames = ['All', ...vehicleTypeController.vehicleTypes.map((e) => e.name)];
              
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: typeNames.map((type) {
                  final isSelected = controller.selectedTypeFilter.value == type;
                  return AppFilterChip(
                    label: type,
                    isSelected: isSelected,
                    onTap: () => controller.selectedTypeFilter.value = type,
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 24),
            AppText(AppTextConstants.seatingCapacity.tr,
                style: AppTextStyle.body, fontWeight: FontWeight.bold, fontSize: 15),
            const SizedBox(height: 12),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: capacities.map((cap) {
                    final isSelected = controller.selectedCapacityFilter.value == cap;
                    return AppFilterChip(
                      label: cap,
                      isSelected: isSelected,
                      onTap: () => controller.selectedCapacityFilter.value = cap,
                    );
                  }).toList(),
                )),
            const SizedBox(height: 32),
            Obx(() => AppButton(
              text: AppTextConstants.applyFilters.tr,
              isLoading: controller.isLoading.value,
              onPressed: () async {
                await controller.fetchVehicles();
                Get.back();
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  const _VehicleCard({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => Get.toNamed(RouteHelper.getVehicleDetailsRoute(), arguments: vehicle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      vehicle.vehicleNumber,
                      style: AppTextStyle.subheading,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      '${AppTextConstants.modelYear.tr}: ${vehicle.modelYear ?? vehicle.year} • ${vehicle.capacity} ${AppTextConstants.seats.tr}',
                      style: AppTextStyle.caption,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showStatusPicker(context, vehicle),
                borderRadius: BorderRadius.circular(20),
                child: AppStatusChip(status: vehicle.status.name, fontSize: 10),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),

          // Driver & Last Service
          // Next Expiry Logic
          () {
            final now = DateTime.now();
            final expiries = [
              if (vehicle.rcExpiry != null) {'name': 'RC', 'date': vehicle.rcExpiry!},
              if (vehicle.insuranceExpiry != null) {'name': 'Insurance', 'date': vehicle.insuranceExpiry!},
              if (vehicle.permitExpiry != null) {'name': 'Permit', 'date': vehicle.permitExpiry!},
            ];

            if (expiries.isEmpty) {
              return Row(
                children: [
                  _buildInfoColumn(AppTextConstants.nextExpiry.tr, 'N/A', Iconsax.calendar, AppColors.textColorHint),
                ],
              );
            }

            // Find the one expiring soonest
            expiries.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
            final next = expiries.first;
            final nextDate = next['date'] as DateTime;
            final daysLeft = nextDate.difference(now).inDays;
            final isExpired = daysLeft < 0;

            return Row(
              children: [
                _buildInfoColumn(
                  '${next['name']} ${isExpired ? AppTextConstants.expired.tr : AppTextConstants.expiry.tr}',
                  isExpired 
                      ? '${nextDate.day}/${nextDate.month}/${nextDate.year} (${AppTextConstants.expired.tr})'
                      : '${nextDate.day}/${nextDate.month}/${nextDate.year} ($daysLeft days left)',
                  Iconsax.calendar_tick,
                  isExpired ? AppColors.errorColor : (daysLeft < 30 ? AppColors.warningColor : AppColors.successColor),
                ),
              ],
            );
          }(),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton.outline(
                text: AppTextConstants.edit.tr,
                width: 80,
                height: 32,
                fontSize: 12,
                onPressed: () =>
                    Get.toNamed(RouteHelper.getEditVehicleRoute(), arguments: vehicle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context, VehicleModel vehicle) {
    final controller = Get.find<VehicleController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(AppTextConstants.changeVehicleStatus.tr,
                style: AppTextStyle.subheading, fontSize: 18, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            AppText('For ${vehicle.vehicleNumber}',
                style: AppTextStyle.body, color: AppColors.textColorSecondary),
            const SizedBox(height: 24),
            ...VehicleStatus.values.map((status) {
              final isSelected = vehicle.status == status;
              return InkWell(
                onTap: () {
                  Get.back();
                  controller.updateVehicleStatus(vehicle, status);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      AppStatusChip(status: status.name, fontSize: 13),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Iconsax.tick_circle5, color: Colors.green, size: 22),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label,
                    style: AppTextStyle.caption,
                    fontSize: 10,
                    color: AppColors.textColorHint,
                    fontWeight: FontWeight.w500),
                const SizedBox(height: 2),
                AppText(value,
                    style: AppTextStyle.body,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          AppText(
            value,
            style: AppTextStyle.heading,
            fontSize: 22,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 4),
          AppText(
            title,
            style: AppTextStyle.label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}
