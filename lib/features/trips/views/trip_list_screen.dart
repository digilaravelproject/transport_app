import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/app_filter_chip.dart';
import '../../../routes/route_helper.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';
import '../../../core/widgets/app_empty_state.dart';

class TripListScreen extends GetView<TripController> {
  const TripListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => Get.toNamed(RouteHelper.getCreateTripRoute()),
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
                
                GestureDetector(
                  onTap: () async {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2027),
                      initialDateRange: controller.fromDate.value != null && controller.toDate.value != null
                        ? DateTimeRange(start: controller.fromDate.value!, end: controller.toDate.value!)
                        : null,
                    );
                    if (picked != null) {
                      controller.setDateFilter(picked.start, picked.end);
                    }
                  },
                  child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (controller.fromDate.value != null) ? AppColors.primaryColor.withOpacity(0.1) : AppColors.slate100,
                      borderRadius: BorderRadius.circular(20),
                      border: (controller.fromDate.value != null) ? Border.all(color: AppColors.primaryColor) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.filter,
                            color: (controller.fromDate.value != null) ? AppColors.primaryColor : AppColors.textColorPrimary, size: 14),
                        const SizedBox(width: 4),
                        AppText(
                          (controller.fromDate.value != null) 
                            ? '${DateFormat('dd MMM').format(controller.fromDate.value!)} - ${DateFormat('dd MMM').format(controller.toDate.value!)}'
                            : 'Filter',
                          color: (controller.fromDate.value != null) ? AppColors.primaryColor : AppColors.textColorPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      ],
                    ),
                  )),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchTrips(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Trips Dashboard',
                            style: AppTextStyle.heading,
                            fontSize: 28,
                            color: AppColors.textColorPrimary,
                          ),
                          SizedBox(height: 4),
                          AppText(
                            'Track and manage all your fleet trips',
                            style: AppTextStyle.body,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dashboard Stat Cards
                    Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Total',
                                  value: controller.totalTrips.value.toString(),
                                  color: const Color(0xFF3B82F6),
                                  icon: Iconsax.routing_2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Ongoing',
                                  value: controller.ongoingTrips.value.toString(),
                                  color: const Color(0xFF10B981),
                                  icon: Iconsax.bus,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Pending',
                                  value: controller.pendingTrips.value.toString(),
                                  color: const Color(0xFFF59E0B),
                                  icon: Iconsax.timer_1,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),

                    // Search Bar
                    Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppSearchBar(
                              hint: 'Search trips...',
                              onChanged: (value) =>
                                  controller.searchQuery.value = value,
                            ),
                          ),
                          if (controller.fromDate.value != null || controller.selectedFilter.value != 'All' || controller.searchQuery.value.isNotEmpty)
                            IconButton(
                              onPressed: () => controller.clearFilters(),
                              icon: const Icon(Iconsax.refresh, color: Colors.red),
                              tooltip: 'Clear Filters',
                            ),
                        ],
                      ),
                    )),

                    // Filter Chips
                    const SizedBox(height: 12),
                    Obx(() => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              AppFilterChip(
                                  label: 'All',
                                  isSelected:
                                      controller.selectedFilter.value == 'All',
                                  onTap: () => controller.setFilter('All')),
                              AppFilterChip(
                                  label: 'Pending',
                                  isSelected: controller.selectedFilter.value ==
                                      'Pending',
                                  onTap: () => controller.setFilter('Pending')),
                              AppFilterChip(
                                  label: 'Ongoing',
                                  isSelected: controller.selectedFilter.value ==
                                      'Ongoing',
                                  onTap: () => controller.setFilter('Ongoing')),
                              AppFilterChip(
                                  label: 'Completed',
                                  isSelected: controller.selectedFilter.value ==
                                      'Completed',
                                  onTap: () =>
                                      controller.setFilter('Completed')),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),

                    // Trip List
                    Obx(() {
                      if (controller.isLoading.value && controller.trips.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 100),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      if (controller.filteredTrips.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: AppEmptyState(
                            title: controller.searchQuery.value.isNotEmpty ? 'No Matching Trips' : 'No Trips Found',
                            subtitle: controller.searchQuery.value.isNotEmpty 
                                ? 'No trips match your search "${controller.searchQuery.value}".'
                                : 'Track and manage all your fleet trips here.',
                            icon: controller.searchQuery.value.isNotEmpty ? Iconsax.search_status : Iconsax.routing,
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: controller.filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = controller.filteredTrips[index];
                          return _TripCard(trip: trip);
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
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => Get.toNamed(RouteHelper.getTripDetailsRoute(), arguments: trip),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trip.tripNumber != null)
                      AppText(
                        trip.tripNumber!,
                        style: AppTextStyle.caption,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    AppText(
                      trip.route,
                      style: AppTextStyle.subheading,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      trip.tripType,
                      style: AppTextStyle.caption,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showStatusBottomSheet(context),
                borderRadius: BorderRadius.circular(8),
                child: AppStatusChip(status: trip.status.name.capitalizeFirst!),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),

          // Date & Vehicle
          Row(
            children: [
              const Icon(Iconsax.calendar_1,
                  size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText(
                '${trip.date.day}/${trip.date.month}/${trip.date.year}',
                style: AppTextStyle.body,
                fontSize: 13,
              ),
              const Spacer(),
              const Icon(Iconsax.bus, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText(
                '${trip.vehicleCount} x ${trip.vehicleType}',
                style: AppTextStyle.body,
                fontSize: 13,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Driver & Amount
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.user,
                    size: 12, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 8),
              AppText(
                trip.allDriverNames,
                style: AppTextStyle.body,
                fontSize: 13,
              ),
              const Spacer(),
              AppText(
                '₹ ${trip.totalAmount.toStringAsFixed(0)}',
                style: AppTextStyle.subheading,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: 'Track',
                width: 80,
                height: 32,
                fontSize: 12,
                onPressed: () =>
                    Get.toNamed(RouteHelper.getTripTrackingRoute(), arguments: trip),
              ),
              const SizedBox(width: 8),
              AppButton.outline(
                text: 'View',
                width: 70,
                height: 32,
                fontSize: 12,
                onPressed: () =>
                    Get.toNamed(RouteHelper.getTripDetailsRoute(), arguments: trip),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context) {
    final controller = Get.find<TripController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText('Update Trip Status', style: AppTextStyle.heading, fontSize: 18),
            const SizedBox(height: 24),
            _buildStatusOption('Pending', 'pending', trip.status.name == 'pending'),
            _buildStatusOption('Ongoing', 'ongoing', trip.status.name == 'ongoing'),
            _buildStatusOption('Completed', 'completed', trip.status.name == 'completed'),
            _buildStatusOption('Cancelled', 'cancelled', trip.status.name == 'cancelled'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String label, String value, bool isSelected) {
    final controller = Get.find<TripController>();
    return ListTile(
      title: AppText(label, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primaryColor) : null,
      onTap: () async {
        Get.back();
        final success = await controller.updateTripStatus(trip.id!, value);
        if (success) {
          Get.snackbar(
            'Success', 
            'Status updated to $label',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
          );
        }
      },
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
