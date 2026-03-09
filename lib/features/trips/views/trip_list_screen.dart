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
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';

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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.filter,
                          color: AppColors.textColorPrimary, size: 14),
                      SizedBox(width: 4),
                      AppText('Filter',
                          color: AppColors.textColorPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                                value: controller.trips.length.toString(),
                                color: const Color(0xFF3B82F6),
                                icon: Iconsax.routing_25,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Ongoing',
                                value: controller.trips
                                    .where((t) =>
                                        t.status == TripStatus.ongoing)
                                    .length
                                    .toString(),
                                color: const Color(0xFF10B981),
                                icon: Iconsax.bus,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Pending',
                                value: controller.trips
                                    .where((t) =>
                                        t.status == TripStatus.pending)
                                    .length
                                    .toString(),
                                color: const Color(0xFFF59E0B),
                                icon: Iconsax.timer_15,
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
                      hint: 'Search trips...',
                      onChanged: (value) =>
                          controller.searchQuery.value = value,
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
                    if (controller.filteredTrips.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child:
                              AppText('No trips found', style: AppTextStyle.body),
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
              AppStatusChip(status: trip.status.name.capitalizeFirst!),
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
                trip.driverName ?? 'Unassigned',
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
