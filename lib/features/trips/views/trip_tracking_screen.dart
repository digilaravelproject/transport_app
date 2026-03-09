import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/trip_controller.dart';
import '../domain/models/trip_model.dart';

class TripTrackingScreen extends GetView<TripController> {
  const TripTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TripModel trip = Get.arguments ?? controller.trips.first;

    return AppScaffold(
      appBar: AppHeader(
        title: 'Track Trip',
        subtitle: trip.route,
      ),
      body: Column(
        children: [
          // Map Placeholder
          Container(
            height: 300,
            width: double.infinity,
            color: AppColors.slate100,
            child: Stack(
              children: [
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.map, size: 64, color: AppColors.slate300),
                      SizedBox(height: 12),
                      AppText('Map View Placeholder', color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 150,
                  child: Icon(Iconsax.location, color: AppColors.primaryColor, size: 40),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(heroTag: null,
                    onPressed: () {},
                    backgroundColor: AppColors.white,
                    child: const Icon(Icons.my_location_rounded, color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDriverCard(trip),
                  const SizedBox(height: 24),
                  AppText('Trip Progress', style: AppTextStyle.subheading, fontSize: 16),
                  const SizedBox(height: 16),
                  _buildVerticalTimeline(),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Call Driver',
                          icon: const Icon(Iconsax.call, size: 18),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton.outline(
                          text: 'Open Map',
                          icon: const Icon(Icons.near_me_rounded, size: 18),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(TripModel trip) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Iconsax.user, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(trip.driverName ?? 'Rajesh Kumar', style: AppTextStyle.subheading, fontSize: 16),
                AppText(trip.vehicleNumber ?? 'DL 01 AB 1234', style: AppTextStyle.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.message_rounded, color: AppColors.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTimeline() {
    return Column(
      children: [
        _buildTimelineStep('Start Point', 'Delhi - 08:00 AM', true, true),
        _buildTimelineStep('Current Location', 'Gurgaon - 09:30 AM', true, false, isCurrent: true),
        _buildTimelineStep('Pickup Point', 'Manesar - 10:15 AM', false, false),
        _buildTimelineStep('Destination', 'Jaipur - 02:00 PM', false, false, isLast: true),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String sub, bool isDone, bool isFirst, {bool isLast = false, bool isCurrent = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 2,
              height: 20,
              color: isFirst ? Colors.transparent : (isDone ? AppColors.successColor : AppColors.slate200),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primaryColor : (isDone ? AppColors.successColor : AppColors.slate300),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrent ? Iconsax.location : (isDone ? Iconsax.tick_circle : Icons.circle),
                size: 12,
                color: AppColors.white,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: isLast ? Colors.transparent : (isDone ? AppColors.successColor : AppColors.slate200),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              AppText(
                title,
                style: AppTextStyle.body,
                fontWeight: isCurrent ? FontWeight.bold : (isDone ? FontWeight.w600 : FontWeight.normal),
                color: isCurrent ? AppColors.primaryColor : AppColors.textColorPrimary,
              ),
              AppText(sub, style: AppTextStyle.caption),
            ],
          ),
        ),
      ],
    );
  }
}
